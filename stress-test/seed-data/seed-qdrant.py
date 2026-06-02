#!/usr/bin/env python3
"""
Seed Qdrant with test journal entries and memories for stress testing.

Usage:
    pip install qdrant_client langchain-google-genai python-dotenv numpy
    python seed-qdrant.py

    # Override Qdrant host if not localhost:
    QDRANT_HOST_SEED=localhost python seed-qdrant.py

Requires GOOGLE_API_KEY (loaded from ../../.env automatically).
If Gemini embedding API is blocked (regional restriction), falls back
to random vectors - fine for stress testing purposes.
"""

import json
import os
import sys
import time
import uuid
import hashlib
import numpy as np
from datetime import datetime, timezone

import dotenv
from qdrant_client import QdrantClient
from qdrant_client.models import Distance, VectorParams, PointStruct
from langchain_core.documents import Document

# Fix Windows console encoding
if sys.platform == "win32":
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")

# -- Load env ---------------------------------------------------------------
ROOT_ENV = os.path.join(os.path.dirname(__file__), '..', '..', '.env')
if os.path.exists(ROOT_ENV):
    dotenv.load_dotenv(ROOT_ENV, override=False)

# Always default to localhost when running from host machine
QDRANT_HOST = os.environ.get("QDRANT_HOST_SEED", "localhost")
QDRANT_PORT = int(os.environ.get("QDRANT_PORT", 6333))
QDRANT_API_KEY = os.environ.get("QDRANT_API_KEY", None)

GOOGLE_API_KEY = os.environ.get("GOOGLE_API_KEY")

# -- Config (must match AI service: database/vector_database.py) -------------
EMBEDDING_MODEL = os.environ.get("EMBEDDING_MODEL", "models/gemini-embedding-001")
VECTOR_SIZE = 3072  # gemini-embedding-001 output dimensions
JOURNAL_COLLECTION = "journal_entries"
MEMORY_COLLECTION = "user_memories"


def get_qdrant_client():
    """Create Qdrant client - same logic as AI service."""
    if QDRANT_API_KEY:
        url = os.environ.get("QDRANT_URL", f"https://{QDRANT_HOST}:{QDRANT_PORT}")
        return QdrantClient(url=url, api_key=QDRANT_API_KEY)
    else:
        return QdrantClient(host=QDRANT_HOST, port=QDRANT_PORT)


def ensure_collections(client):
    """Create collections if they don't exist (matches AI service logic)."""
    for name in [JOURNAL_COLLECTION, MEMORY_COLLECTION]:
        if not client.collection_exists(name):
            client.create_collection(
                collection_name=name,
                vectors_config=VectorParams(size=VECTOR_SIZE, distance=Distance.COSINE),
            )
            print(f"  Created collection: {name}")
        else:
            print(f"  Collection exists: {name}")


def get_embedding_provider():
    """Try to use Gemini embeddings, fall back to random vectors for testing."""
    if GOOGLE_API_KEY:
        try:
            from langchain_google_genai import GoogleGenerativeAIEmbeddings
            embeddings = GoogleGenerativeAIEmbeddings(
                model=EMBEDDING_MODEL,
                google_api_key=GOOGLE_API_KEY,
            )
            # Test with a single embedding
            test_vec = embeddings.embed_query("test")
            print(f"  Using Gemini embeddings (model: {EMBEDDING_MODEL}, dim: {len(test_vec)})")
            return "gemini", embeddings
        except Exception as e:
            print(f"  Gemini embeddings failed: {e}")
            print(f"  Falling back to random vectors (OK for stress testing)")

    print(f"  Using random vectors (dim: {VECTOR_SIZE})")
    return "random", None


# Namespace UUID for deterministic ID conversion
_NS = uuid.UUID("00000000-0000-0000-0000-000000000000")


def to_uuid(fake_id: str) -> str:
    """Convert any string to a valid UUID v5 (deterministic)."""
    return str(uuid.uuid5(_NS, fake_id))


def embed_text(provider, embeddings, text):
    """Get embedding vector for text using the selected provider."""
    if provider == "gemini" and embeddings:
        return embeddings.embed_query(text)
    else:
        # Deterministic random vector based on text content (for consistency)
        seed = hash(text) % (2**31)
        rng = np.random.RandomState(seed)
        vec = rng.randn(VECTOR_SIZE).astype(np.float32)
        # Normalize for cosine similarity
        vec = vec / np.linalg.norm(vec)
        return vec.tolist()


def main():
    print("=" * 60)
    print("Tranquara Stress Test -- Qdrant Seed Script")
    print("=" * 60)
    print(f"  Qdrant:    {QDRANT_HOST}:{QDRANT_PORT}")
    print(f"  Embedding: {EMBEDDING_MODEL}")
    print(f"  Vector sz: {VECTOR_SIZE}")
    print()

    # Connect to Qdrant
    client = get_qdrant_client()
    try:
        collections = client.get_collections()
        print(f"  Connected! Existing collections: {[c.name for c in collections.collections]}")
    except Exception as e:
        print(f"ERROR: Cannot connect to Qdrant at {QDRANT_HOST}:{QDRANT_PORT}")
        print(f"  Detail: {e}")
        print()
        print("Make sure Qdrant is running:")
        print("  docker compose up -d qdrant")
        print("  Or: curl http://localhost:6333/collections")
        sys.exit(1)

    # Ensure collections exist
    print()
    print("Ensuring collections exist...")
    ensure_collections(client)

    # Init embedding provider
    print()
    print("Initializing embeddings...")
    provider, embeddings = get_embedding_provider()

    # Load seed data
    data_path = os.path.join(os.path.dirname(__file__), "seed-test-data.json")
    with open(data_path, "r", encoding="utf-8") as f:
        data = json.load(f)

    users_with_rag = data["users_with_rag"]
    print(f"\n  Loaded {len(users_with_rag)} users with RAG data")
    print()

    # -- Seed journals -------------------------------------------------------
    journal_count = 0
    for user in users_with_rag:
        for journal in user["journals"]:
            try:
                embed_text_content = f"{journal['title']}\n{journal['content']}"
                vector = embed_text(provider, embeddings, embed_text_content)

                point_id = to_uuid(journal["journal_id"])
                client.upsert(
                    collection_name=JOURNAL_COLLECTION,
                    points=[
                        PointStruct(
                            id=point_id,
                            vector=vector,
                            payload={
                                "page_content": embed_text_content,
                                "metadata": {
                                    "journal_id": point_id,
                                    "user_id": user["user_id"],
                                    "title": journal["title"],
                                    "mood_score": journal["mood_score"],
                                    "mood_label": journal.get("mood_label"),
                                    "created_at": journal["created_at"],
                                    "type": "journal",
                                }
                            }
                        )
                    ]
                )

                journal_count += 1
                print(f"  [OK] Journal [{journal_count}]: {journal['title'][:60]}...")
                time.sleep(0.1)
            except Exception as e:
                print(f"  [ERR] Journal {journal['journal_id']}: {e}")

    # -- Seed memories -------------------------------------------------------
    memory_count = 0
    for user in users_with_rag:
        for memory in user["memories"]:
            try:
                vector = embed_text(provider, embeddings, memory["content"])

                mem_point_id = to_uuid(memory["memory_id"])
                client.upsert(
                    collection_name=MEMORY_COLLECTION,
                    points=[
                        PointStruct(
                            id=mem_point_id,
                            vector=vector,
                            payload={
                                "page_content": memory["content"],
                                "metadata": {
                                    "memory_id": mem_point_id,
                                    "user_id": user["user_id"],
                                    "category": memory["category"],
                                    "confidence": memory["confidence"],
                                    "created_at": memory.get("created_at", datetime.now(timezone.utc).isoformat()),
                                    "type": "memory",
                                }
                            }
                        )
                    ]
                )

                memory_count += 1
                print(f"  [OK] Memory [{memory_count}]: {memory['content'][:60]}...")
                time.sleep(0.1)
            except Exception as e:
                print(f"  [ERR] Memory {memory['memory_id']}: {e}")

    # -- Summary -------------------------------------------------------------
    print(f"\n{'=' * 60}")
    print(f"SEED COMPLETE")
    print(f"  Journals seeded: {journal_count}")
    print(f"  Memories seeded: {memory_count}")
    print(f"  Total vectors:   {journal_count + memory_count}")
    print(f"  Embedding mode:  {provider}")
    print(f"{'=' * 60}")

    # Verify
    for name in [JOURNAL_COLLECTION, MEMORY_COLLECTION]:
        info = client.get_collection(name)
        print(f"  {name}: {info.points_count} points")


if __name__ == "__main__":
    main()