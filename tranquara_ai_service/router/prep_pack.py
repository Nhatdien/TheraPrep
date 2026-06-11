"""
Prep Pack Router

POST /api/prep-pack — Generates an AI Therapy Session Prep Pack.

Data flow:
  1. Frontend calls this endpoint with user_id + date range
  2. Journals are fetched from the Go backend (PostgreSQL) by date range
  3. AI memories are fetched directly from Qdrant
  4. GPT generates structured prep pack
  5. Returns prep pack JSON to frontend
"""

import asyncio
import os
from datetime import datetime, timezone

import httpx
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel

from database.vector_database import (
    get_user_journals_by_date_range,
    get_all_user_memories,
)
from service.ai_service_processor import AIProcessor

router = APIRouter()

CORE_SERVICE_URL = os.getenv("CORE_SERVICE_URL", "http://core_service:4000")
INTERNAL_API_KEY = os.getenv("INTERNAL_API_KEY", "")


async def _fetch_journals_from_core_service(
    user_id: str, date_start: str, date_end: str
) -> list[dict]:
    """Fetch journals for the user/date range from the canonical Postgres store."""
    if not INTERNAL_API_KEY:
        return []

    try:
        async with httpx.AsyncClient(timeout=30) as client:
            response = await client.get(
                f"{CORE_SERVICE_URL}/v1/internal/user-journals",
                params={
                    "user_id": user_id,
                    "date_start": date_start,
                    "date_end": date_end,
                },
                headers={
                    "X-Internal-Key": INTERNAL_API_KEY,
                },
            )
            response.raise_for_status()
            data = response.json()
            journals = data.get("journals", data.get("data", {}).get("journals", []))
            return [
                {
                    "journal_id": str(j.get("id", "")),
                    "title": j.get("title", "Untitled"),
                    "content": j.get("content_html") or j.get("content", ""),
                    "mood_score": j.get("mood_score"),
                    "mood_label": j.get("mood_label"),
                    "created_at": j.get("created_at", ""),
                }
                for j in journals
            ]
    except Exception as e:
        print(f"[prep-pack] Failed to fetch journals from core service: {e}")
        return []


class PrepPackRequest(BaseModel):
    user_id: str
    date_range_start: str  # ISO date string (e.g. "2026-03-01")
    date_range_end: str    # ISO date string (e.g. "2026-03-11")
    language: str = "en"


import time as _time

@router.post("/api/prep-pack")
async def generate_prep_pack(request: PrepPackRequest):
    """Generate an AI Therapy Session Prep Pack from Qdrant-stored journals + memories."""
    t0 = _time.time()

    # 1. Fetch journals from canonical store (PostgreSQL via Go backend),
    # falling back to Qdrant if the core service is unreachable.
    journals = await _fetch_journals_from_core_service(
        user_id=request.user_id,
        date_start=request.date_range_start,
        date_end=request.date_range_end,
    )
    if not journals:
        journals = get_user_journals_by_date_range(
            user_id=request.user_id,
            date_start=request.date_range_start,
            date_end=request.date_range_end,
        )

    if not journals:
        raise HTTPException(
            status_code=400,
            detail="No journal entries found for the selected date range."
        )

    t1_fetch = _time.time()

    # 2. Fetch AI memories from Qdrant
    raw_memories = get_all_user_memories(request.user_id)
    memories = [
        getattr(point, "payload", {}).get("page_content", "")
        for point in raw_memories
        if getattr(point, "payload", None) and getattr(point, "payload", {}).get("page_content")
    ]

    t2_memories = _time.time()

    # 3. Generate prep pack via GPT (run in thread to avoid blocking event loop)
    try:
        ai_processor = AIProcessor.get_instance()
        prep_pack = await asyncio.to_thread(
            ai_processor.generate_prep_pack,
            journal_entries=journals,
            memories=memories,
            language=request.language,
        )

        t3_done = _time.time()
        print(
            f"[prep-pack] user={request.user_id} | "
            f"fetch={t1_fetch - t0:.2f}s | "
            f"memories={t2_memories - t1_fetch:.2f}s | "
            f"llm={t3_done - t2_memories:.2f}s | "
            f"total={t3_done - t0:.2f}s | "
            f"journals={len(journals)} | memories={len(memories)}"
        )

        return {
            "prep_pack": prep_pack,
            "meta": {
                "journals_analyzed": len(journals),
                "date_range": f"{request.date_range_start} – {request.date_range_end}",
                "generated_at": datetime.now(timezone.utc).isoformat(),
            }
        }

    except ValueError as e:
        raise HTTPException(status_code=500, detail=str(e))
    except Exception as e:
        print(f"[prep-pack] Unexpected error: {e}")
        raise HTTPException(
            status_code=500,
            detail="Failed to generate prep pack. Please try again."
        )
