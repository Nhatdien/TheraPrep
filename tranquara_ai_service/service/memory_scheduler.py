"""
AI Memory Generation Scheduler

Periodically extracts factual insights from user journals using GPT.
Runs every 12 hours, processes users with new journal activity.

Flow:
  1. Fetch active users (with recent journal activity) from Go backend
  2. For each user: fetch recent journals from Qdrant + existing memories from Qdrant
  3. Send to GPT for extraction → deduplicate → store in PostgreSQL + Qdrant
"""

import os
import traceback
import httpx
from datetime import datetime, timezone, timedelta
from apscheduler.schedulers.asyncio import AsyncIOScheduler
from service.ai_service_processor import AIProcessor
from database.vector_database import (
    index_memory,
    get_all_user_memories,
    get_user_journals_by_date_range,
)

# Go backend internal API base URL (only used for active-users + batch-create)
CORE_SERVICE_URL = os.getenv("CORE_SERVICE_URL", "http://core_service:4000")
INTERNAL_API_KEY = os.getenv("INTERNAL_API_KEY", "")

# Scheduler interval (minutes)
# Prefer MEMORY_INTERVAL_MINUTES; fall back to MEMORY_INTERVAL_HOURS for backward compatibility.
_minutes_env = os.getenv("MEMORY_INTERVAL_MINUTES")
if _minutes_env is not None and _minutes_env != "":
    MEMORY_GENERATION_INTERVAL_MINUTES = int(_minutes_env)
else:
    MEMORY_GENERATION_INTERVAL_MINUTES = int(
        os.getenv("MEMORY_INTERVAL_HOURS", "12")) * 60

# Optional: run a cycle immediately on startup for easier debugging
RUN_ON_STARTUP = os.getenv("MEMORY_RUN_ON_STARTUP", "false").lower() in (
    "1", "true", "yes", "y", "on")

scheduler = AsyncIOScheduler()


async def _fetch_active_users(since: str) -> list[dict]:
    """Fetch users with recent journal activity and their language preferences from Go backend.
    This must call Go because Qdrant doesn't track per-user activity timestamps.
    Returns list of dicts: [{"user_id": "...", "language": "vi"}, ...]
    """
    try:
        async with httpx.AsyncClient(timeout=30) as client:
            response = await client.get(
                f"{CORE_SERVICE_URL}/v1/internal/active-journal-users",
                params={"since": since},
                headers={"X-Internal-Key": INTERNAL_API_KEY},
            )
            response.raise_for_status()
            data = response.json()
            users = data.get("users", [])
            # Support legacy format (just user_ids) for backward compatibility
            if not users and data.get("user_ids"):
                return [{"user_id": uid, "language": "en"} for uid in data["user_ids"]]
            return users
    except Exception as e:
        print(f"[memory-scheduler] Error fetching active users: {e}")
        return []


def _get_user_journals_from_qdrant(user_id: str, since: str) -> list[dict]:
    """Fetch recent journals for a user directly from Qdrant.
    Journals are synced to Qdrant via the RabbitMQ pipeline (journal.index events)."""
    today = datetime.now(timezone.utc).strftime("%Y-%m-%d")
    date_start = since[:10] if since else today
    return get_user_journals_by_date_range(
        user_id=user_id,
        date_start=date_start,
        date_end=today,
    )


def _get_existing_memories_from_qdrant(user_id: str) -> list[str]:
    """Fetch existing memory contents for a user directly from Qdrant.
    Memories are indexed in Qdrant alongside PostgreSQL storage."""
    try:
        raw_memories = get_all_user_memories(user_id, with_vectors=False)
        return [
            point.payload.get("page_content", "")
            for point in raw_memories
            if getattr(point, "payload", None) and point.payload.get("page_content")
        ]
    except Exception as e:
        print(f"[memory-scheduler] Error fetching existing memories for {user_id}: {e}")
        traceback.print_exc()
        return []


async def _store_memories(user_id: str, memories: list[dict]) -> list[dict]:
    """Store new memories in Go backend (PostgreSQL) and return created records with IDs."""
    try:
        async with httpx.AsyncClient(timeout=30) as client:
            response = await client.post(
                f"{CORE_SERVICE_URL}/v1/internal/ai-memories/batch",
                json={"user_id": user_id, "memories": memories},
                headers={
                    "X-Internal-Key": INTERNAL_API_KEY,
                    "Content-Type": "application/json",
                },
            )
            response.raise_for_status()
            data = response.json()
            return data.get("created", [])
    except Exception as e:
        print(f"[memory-scheduler] Error storing memories for {user_id}: {e}")
        return []


def _detect_dominant_language(journals: list[dict]) -> str:
    """Heuristic: detect dominant language from journal content."""
    if not journals:
        return "en"
    try:
        total_chars = 0
        vi_chars = 0
        for entry in journals:
            if not isinstance(entry, dict):
                continue
            text = entry.get("content", "") + " " + entry.get("title", "")
            for ch in text:
                total_chars += 1
                if "\u00c0" <= ch <= "\u1ef9" or ch in "àáảãạăắằẳẵặâấầẩẫậđèéẻẽẹêếềểễệìíỉĩịòóỏõọôốồổỗộơớờởỡợùúủũụưứừửữựỳýỷỹỵ":
                    vi_chars += 1
        if total_chars == 0:
            return "en"
        return "vi" if (vi_chars / total_chars) > 0.3 else "en"
    except Exception as e:
        print(f"[memory-scheduler] Error detecting language: {e}")
        traceback.print_exc()
        return "en"


async def process_user_memories(user_id: str, since: str, preferred_language: str = "") -> bool:
    """
    Process a single user: fetch journals, extract memories, store + index.

    Args:
        user_id: The user's UUID
        since: ISO timestamp to fetch journals from
        preferred_language: User's preferred language from settings (e.g. 'vi', 'en').
                           If provided, this overrides journal language detection.

    Returns True on success, False on error (so the caller can count errors).
    Raises exceptions so the caller can differentiate success vs failure.
    """
    # 1. Fetch recent journals from Qdrant
    journals = _get_user_journals_from_qdrant(user_id, since)
    if not journals:
        return True  # No journals is not an error

    # 2. Fetch existing memories from Qdrant (for dedup prompt context)
    existing_contents = _get_existing_memories_from_qdrant(user_id)

    # 3. Determine language for memory extraction
    # Use user's preferred language from settings if available, otherwise detect from journals
    if preferred_language and preferred_language in ("vi", "en"):
        language = preferred_language
        print(f"[memory-scheduler] User {user_id}: using preferred language '{language}' from settings")
    else:
        language = _detect_dominant_language(journals)
        print(f"[memory-scheduler] User {user_id}: detected language '{language}' from journal content")

    # 4. Extract new memories via GPT (reuse singleton)
    ai_processor = AIProcessor.get_instance()
    new_memories = ai_processor.extract_memories(
        user_id=user_id,
        journal_entries=journals,
        existing_memories=existing_contents,
        language=language,
    )

    if not new_memories:
        return True  # No new memories is not an error

    # 5. Store in PostgreSQL via Go backend
    created = await _store_memories(user_id, new_memories)

    # 6. Index in Qdrant for RAG
    indexed_count = 0
    for memory in created:
        try:
            memory_id = memory.get("id")
            content = memory.get("content", "")
            if memory_id and content:
                index_memory(
                    memory_id=memory_id,
                    user_id=user_id,
                    content=content,
                    category=memory.get("category", "preferences"),
                    confidence=memory.get("confidence", 0.5),
                    created_at=memory.get("created_at"),
                )
                indexed_count += 1
        except Exception as e:
            print(f"[memory-scheduler] Error indexing memory for {user_id}: {e}")
            traceback.print_exc()

    print(
        f"[memory-scheduler] User {user_id}: {len(created)} memories created, {indexed_count} indexed")
    return True


async def run_memory_generation():
    """
    Main periodic job: find active users and extract memories.
    Runs every 12 hours.
    """
    print(
        f"[memory-scheduler] Starting memory generation cycle at {datetime.now(timezone.utc).isoformat()}")

    since = (datetime.now(timezone.utc) -
             timedelta(minutes=5)).isoformat()

    # 1. Get users with recent journal activity and their language preferences
    users = await _fetch_active_users(since)
    if not users:
        print("[memory-scheduler] No active users found, skipping cycle")
        return

    print(f"[memory-scheduler] Processing {len(users)} active users")

    # 2. Process each user (sequentially to avoid rate limits)
    success_count = 0
    error_count = 0
    for user in users:
        try:
            user_id = user.get("user_id", "")
            preferred_language = user.get("language", "")
            if not user_id:
                continue
            await process_user_memories(user_id, since, preferred_language)
            success_count += 1
        except Exception as e:
            error_count += 1
            user_id_str = user.get("user_id", "unknown") if isinstance(user, dict) else str(user)
            print(f"[memory-scheduler] Failed for user {user_id_str}: {e}")
            traceback.print_exc()

    print(
        f"[memory-scheduler] Cycle complete: {success_count} success, {error_count} errors")


def start_scheduler():
    """Initialize and start the memory generation scheduler."""
    job = scheduler.add_job(
        run_memory_generation,
        trigger="interval",
        minutes=MEMORY_GENERATION_INTERVAL_MINUTES,
        id="memory_generation",
        name="AI Memory Generation",
        replace_existing=True,
        next_run_time=datetime.now(timezone.utc) if RUN_ON_STARTUP else None,
    )
    scheduler.start()
    next_run = job.next_run_time.isoformat() if job.next_run_time else "unscheduled"
    print(
        f"[memory-scheduler] Scheduler started (every {MEMORY_GENERATION_INTERVAL_MINUTES}m); next run at {next_run}")


def stop_scheduler():
    """Gracefully stop the scheduler."""
    if scheduler.running:
        scheduler.shutdown(wait=False)
        print("[memory-scheduler] Scheduler stopped")
