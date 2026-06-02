#!/usr/bin/env python3
"""
Remove all seeded test data from Qdrant after stress testing.
Deletes journal_entries and user_memories for test user IDs.
"""
import json
import os
import sys
from qdrant_client import QdrantClient
from qdrant_client.models import Filter, FieldCondition, MatchValue

SEED_FILE = os.path.join(os.path.dirname(__file__), "..", "seed-data", "seed-test-data.json")
QDRANT_HOST = os.environ.get("QDRANT_HOST", "localhost")
QDRANT_PORT = int(os.environ.get("QDRANT_PORT", 6333))

JOURNAL_COLLECTION = "journal_entries"
MEMORY_COLLECTION = "user_memories"


def main():
    print("=" * 60)
    print("Cleanup Seed Data from Qdrant")
    print("=" * 60)

    client = QdrantClient(host=QDRANT_HOST, port=QDRANT_PORT)
    print(f"Connected to Qdrant at {QDRANT_HOST}:{QDRANT_PORT}")

    with open(SEED_FILE, "r", encoding="utf-8") as f:
        data = json.load(f)

    # Collect all test user IDs
    user_ids = []
    for user in data["users_with_rag"]:
        user_ids.append(user["user_id"])

    print(f"Found {len(user_ids)} test users to clean up")

    for collection in [JOURNAL_COLLECTION, MEMORY_COLLECTION]:
        if not client.collection_exists(collection):
            print(f"  Collection {collection} does not exist, skipping")
            continue

        for uid in user_ids:
            result = client.delete(
                collection_name=collection,
                points_selector=Filter(
                    must=[FieldCondition(key="metadata.user_id", match=MatchValue(value=uid))]
                ),
            )
            print(f"  Deleted {uid} from {collection}")

    print(f"\nCleanup complete!")


if __name__ == "__main__":
    main()