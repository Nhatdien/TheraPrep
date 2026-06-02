#!/usr/bin/env python3
"""
Generate Postman Collection Runner data files from seed-test-data.json.
Creates 6 CSV files for each test scenario.
"""
import json
import os
import csv

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
DATA_DIR = os.path.join(SCRIPT_DIR, "data")
SEED_FILE = os.path.join(SCRIPT_DIR, "..", "seed-data", "seed-test-data.json")

os.makedirs(DATA_DIR, exist_ok=True)

with open(SEED_FILE, "r", encoding="utf-8") as f:
    seed = json.load(f)

# Build flat list of all test users
all_users = []

# RAG users - use first journal content as the test input
for user in seed["users_with_rag"]:
    last_journal = user["journals"][-1]  # Most recent journal
    all_users.append({
        "user_id": user["user_id"],
        "content": last_journal["content"],
        "mood_score": last_journal["mood_score"],
        "direction": last_journal["mood_label"] and ["why", "emotions", "patterns", "challenge", "growth"][hash(user["user_id"]) % 5],
        "app_language": "vi" if any(ord(c) > 0x0400 for c in last_journal["content"]) else "en",
    })

# No-RAG users
for user in seed["users_without_rag"]:
    all_users.append(user)

# Crisis users
for user in seed["users_crisis"]:
    all_users.append(user)

# Vietnamese users
for user in seed["users_vietnamese"]:
    all_users.append(user)

# Assign directions evenly if not already set
directions = ["why", "emotions", "patterns", "challenge", "growth"]
for i, user in enumerate(all_users):
    if "direction" not in user or not user["direction"]:
        user["direction"] = directions[i % 5]

# Define scenarios
scenarios = {
    "smoke-data.csv": all_users[:1],
    "light-data.csv": all_users[:10],
    "medium-data.csv": all_users[:25],
    "heavy-data.csv": all_users[:50],
    "spike-data.csv": all_users[:50],
    "sustained-data.csv": (all_users[:10] * 6)[:60],  # Repeat 10 users 6 times
}

headers = ["user_id", "content", "mood_score", "direction", "app_language"]

for filename, users in scenarios.items():
    filepath = os.path.join(DATA_DIR, filename)
    with open(filepath, "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=headers)
        writer.writeheader()
        for user in users:
            writer.writerow({
                "user_id": user["user_id"],
                "content": user["content"],
                "mood_score": user["mood_score"],
                "direction": user["direction"],
                "app_language": user.get("app_language", "en"),
            })
    print(f"  Created {filename} ({len(users)} rows)")

print(f"\nDone! All data files saved to: {DATA_DIR}")