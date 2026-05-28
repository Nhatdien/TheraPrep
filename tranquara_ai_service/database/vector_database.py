from qdrant_client import QdrantClient
from qdrant_client.models import Distance, VectorParams, Filter, FieldCondition, MatchValue
from langchain_qdrant import QdrantVectorStore
from langchain_google_genai import GoogleGenerativeAIEmbeddings
import os
import numpy as np

# Connect to your running Qdrant instance
qdrant_host = os.getenv("QDRANT_HOST", "qdrant")
qdrant_port = int(os.getenv("QDRANT_PORT", 6333))
qdrant_api_key = os.getenv("QDRANT_API_KEY", None)

# Use URL-based connection for Qdrant Cloud (https), host-based for local
if qdrant_api_key:
    # Qdrant Cloud: connect via HTTPS with API key
    qdrant_url = os.getenv(
        "QDRANT_URL", f"https://{qdrant_host}:{qdrant_port}")
    client = QdrantClient(url=qdrant_url, api_key=qdrant_api_key)
else:
    # Local: connect via host/port (no auth)
    client = QdrantClient(host=qdrant_host, port=qdrant_port)

# --- Shared config ---
EMBEDDING_MODEL = os.getenv("EMBEDDING_MODEL", "models/gemini-embedding-001")
VECTOR_SIZE = 3072  # Gemini gemini-embedding-001 default output dimensions
DISTANCE_METRIC = Distance.COSINE

JOURNAL_COLLECTION = "journal_entries"
MEMORY_COLLECTION = "user_memories"

# --- Lazy initialization ---
# QdrantVectorStore validates embeddings at construction time by calling
# the Gemini API. If the API key is invalid or the quota is exhausted, this
# would crash the service on import. Lazy init defers that call until the
# store is actually used, so the service can still start.

_embeddings = None
_journal_vector_store = None
_memory_vector_store = None

DEFAULT_DIRECTION_TOP_K = {
    "why": 5,
    "emotions": 4,
    "challenge": 5,
    "growth": 6,
    "patterns": 8,
    "default": 5,
}


def get_top_k_for_direction(direction: str | None) -> int:
    key = (direction or "").strip().lower()
    return DEFAULT_DIRECTION_TOP_K.get(key, DEFAULT_DIRECTION_TOP_K["default"])


def _get_embeddings():
    """Lazily create the shared GoogleGenerativeAIEmbeddings instance."""
    global _embeddings
    if _embeddings is None:
        _embeddings = GoogleGenerativeAIEmbeddings(
            model=EMBEDDING_MODEL,
            google_api_key=os.environ["GOOGLE_API_KEY"],
        )
    return _embeddings


def _ensure_collection(name: str):
    """Create a Qdrant collection if it doesn't already exist.
    
    If the collection exists but has a different vector size (e.g., migrated
    from OpenAI 1536-dim to Gemini 3072-dim), it will be recreated.
    """
    if not client.collection_exists(name):
        print(f"Creating collection: {name}")
        client.recreate_collection(
            collection_name=name,
            vectors_config=VectorParams(
                size=VECTOR_SIZE, distance=DISTANCE_METRIC),
        )
    else:
        # Check if existing collection has matching vector dimensions
        try:
            collection_info = client.get_collection(name)
            vectors_config = collection_info.config.params.vectors
            # Handle both single VectorParams and dict of named vectors
            if hasattr(vectors_config, 'size'):
                existing_size = vectors_config.size
            elif isinstance(vectors_config, dict) and vectors_config:
                existing_size = next(iter(vectors_config.values())).size
            else:
                print(f"[migration] Collection '{name}' has unexpected vector config. Recreating.")
                client.recreate_collection(
                    collection_name=name,
                    vectors_config=VectorParams(
                        size=VECTOR_SIZE, distance=DISTANCE_METRIC),
                )
                global _journal_vector_store, _memory_vector_store
                if name == JOURNAL_COLLECTION:
                    _journal_vector_store = None
                elif name == MEMORY_COLLECTION:
                    _memory_vector_store = None
                return

            if existing_size != VECTOR_SIZE:
                print(f"[migration] Collection '{name}' has vector size {existing_size}, "
                      f"but expected {VECTOR_SIZE}. Recreating collection.")
                client.recreate_collection(
                    collection_name=name,
                    vectors_config=VectorParams(
                        size=VECTOR_SIZE, distance=DISTANCE_METRIC),
                )
                # Reset vector stores so they re-initialize with the new collection
                global _journal_vector_store, _memory_vector_store
                if name == JOURNAL_COLLECTION:
                    _journal_vector_store = None
                elif name == MEMORY_COLLECTION:
                    _memory_vector_store = None
            else:
                print(f"Collection '{name}' already exists (size={existing_size}).")
        except Exception as e:
            print(f"[qdrant] Error checking collection '{name}': {e}. Will attempt to recreate.")
            client.recreate_collection(
                collection_name=name,
                vectors_config=VectorParams(
                    size=VECTOR_SIZE, distance=DISTANCE_METRIC),
            )
            global _journal_vector_store, _memory_vector_store
            if name == JOURNAL_COLLECTION:
                _journal_vector_store = None
            elif name == MEMORY_COLLECTION:
                _memory_vector_store = None


def _get_journal_vector_store() -> QdrantVectorStore:
    """Lazily create the journal vector store (validates on first use)."""
    global _journal_vector_store
    if _journal_vector_store is None:
        _ensure_collection(JOURNAL_COLLECTION)
        _journal_vector_store = QdrantVectorStore(
            embedding=_get_embeddings(),
            collection_name=JOURNAL_COLLECTION,
            client=client,
        )
    return _journal_vector_store


def _get_memory_vector_store() -> QdrantVectorStore:
    """Lazily create the memory vector store (validates on first use)."""
    global _memory_vector_store
    if _memory_vector_store is None:
        _ensure_collection(MEMORY_COLLECTION)
        _memory_vector_store = QdrantVectorStore(
            embedding=_get_embeddings(),
            collection_name=MEMORY_COLLECTION,
            client=client,
        )
    return _memory_vector_store


def search_user_journals(user_id: str, query: str, top_k: int = 5) -> list:
    """
    Search for past journals by a specific user that are semantically similar to the query.

    Args:
        user_id: The user's UUID string
        query: The text to search for similar journals
        top_k: Number of results to return

    Returns:
        List of matching Documents with metadata
    """
    results = _get_journal_vector_store().similarity_search(
        query=query,
        k=top_k,
        filter=Filter(
            must=[
                FieldCondition(
                    key="metadata.user_id",
                    match=MatchValue(value=user_id)
                )
            ]
        )
    )
    return results


def index_journal(journal_id: str, user_id: str, content: str,
                  content_html: str = None, title: str = "",
                  mood_score: int = None,
                  mood_label: str = None, created_at: str = None):
    """
    Index a journal entry into Qdrant for future RAG retrieval.
    Uses journal_id as the point ID to enable upsert (re-indexing on update).

    Args:
        journal_id: UUID of the journal (used as Qdrant point ID for upsert)
        user_id: UUID of the user who owns this journal
        content: The journal text content (TipTap JSON — not human-readable)
        content_html: Rendered HTML version of content — preferred for embedding
                      because plain `content` is TipTap JSON which is not
                      meaningful for LLM consumption or semantic search.
        title: Journal title
        mood_score: 1-10 mood rating
        mood_label: Mood label (e.g. "Sunny", "Storm")
        created_at: ISO timestamp of journal creation
    """
    import re as _re
    from langchain_core.documents import Document

    # Determine the best text to embed:
    # 1. content_html (rendered HTML, most readable) → strip tags for clean text
    # 2. content (TipTap JSON) → last resort, poor for semantic search
    if content_html:
        # Strip HTML tags to get plain text for embedding
        plain_text = _re.sub(r'<[^>]+>', ' ', content_html)
        plain_text = _re.sub(r'\s+', ' ', plain_text).strip()
        embed_source = "content_html"
    else:
        plain_text = content
        embed_source = "content (raw)"

    # Build the text to embed: title + readable content for richer semantic meaning
    embed_text = f"{title}\n{plain_text}" if title else plain_text

    doc = Document(
        page_content=embed_text,
        metadata={
            "journal_id": journal_id,
            "user_id": user_id,
            "title": title,
            "mood_score": mood_score,
            "mood_label": mood_label,
            "created_at": created_at,
            "type": "journal"
        }
    )

    # Use journal_id as the vector point ID so updates overwrite the old entry
    _get_journal_vector_store().add_documents(
        documents=[doc],
        ids=[journal_id]
    )
    print(f"Indexed journal {journal_id} for user {user_id} "
          f"(embed_source={embed_source}, chars={len(embed_text)})")


def delete_journal(journal_id: str):
    """
    Delete a journal entry vector from Qdrant.
    Called when a user deletes a journal so it no longer appears in RAG results.

    Args:
        journal_id: UUID of the journal (the Qdrant point ID)
    """
    from qdrant_client.models import PointIdsList

    client.delete(
        collection_name=JOURNAL_COLLECTION,
        points_selector=PointIdsList(points=[journal_id])
    )
    print(f"Deleted journal {journal_id} from Qdrant")


def get_user_journals_by_date_range(user_id: str, date_start: str,
                                    date_end: str, limit: int = 200) -> list[dict]:
    """
    Scroll ALL journal entries for a user within a date range from Qdrant.
    Unlike search_user_journals (similarity-based), this retrieves all matching entries.

    Qdrant doesn't natively support date range filters, so we scroll all user
    journals and filter by created_at in Python.

    Args:
        user_id: The user's UUID string
        date_start: ISO date string (e.g. "2026-03-01")
        date_end: ISO date string (e.g. "2026-03-11")
        limit: Maximum number of points to scroll

    Returns:
        List of dicts with journal metadata + content
    """
    try:
        results, _ = client.scroll(
            collection_name=JOURNAL_COLLECTION,
            scroll_filter=Filter(
                must=[
                    FieldCondition(
                        key="metadata.user_id",
                        match=MatchValue(value=user_id)
                    )
                ]
            ),
            limit=limit,
            with_payload=True,
            with_vectors=False,
        )

        # Filter by date range in Python
        filtered = []
        for point in results:
            try:
                payload = getattr(point, "payload", None) or {}
                if not isinstance(payload, dict):
                    continue
                metadata = payload.get("metadata") or {}
                if not isinstance(metadata, dict):
                    metadata = {}
                created_at = metadata.get("created_at", "")
                if not isinstance(created_at, str):
                    created_at = str(created_at) if created_at is not None else ""

                # Compare date portion only (ISO format sorts lexicographically)
                entry_date = created_at[:10] if created_at else ""
                if date_start <= entry_date <= date_end:
                    filtered.append({
                        "journal_id": metadata.get("journal_id", ""),
                        "title": metadata.get("title", "Untitled"),
                        "content": payload.get("page_content", ""),
                        "mood_score": metadata.get("mood_score"),
                        "mood_label": metadata.get("mood_label"),
                        "created_at": created_at,
                    })
            except Exception as point_err:
                print(f"[qdrant] Error processing journal point: {point_err}")
                continue

        print(f"[qdrant] Found {len(filtered)} journals for user {user_id} "
              f"in range {date_start} \u2013 {date_end} (scrolled {len(results)} total)")
        return filtered

    except Exception as e:
        print(f"[qdrant] Error scrolling user journals: {e}")
        return []


# ═══════════════════════════════════════════════════════════════════════════
# Memory Functions
# ═══════════════════════════════════════════════════════════════════════════

def search_user_memories(user_id: str, query: str, top_k: int = 10) -> list:
    """
    Retrieve a user's AI memories from Qdrant for RAG injection.
    Used during journal follow-up question generation to provide stable user context.

    Args:
        user_id: The user's UUID string
        query: The text to search for similar memories
        top_k: Number of results to return

    Returns:
        List of matching Documents with metadata
    """
    results = _get_memory_vector_store().similarity_search(
        query=query,
        k=top_k,
        filter=Filter(
            must=[
                FieldCondition(
                    key="metadata.user_id",
                    match=MatchValue(value=user_id)
                )
            ]
        )
    )
    return results


def get_all_user_memories(user_id: str, limit: int = 100) -> list:
    """
    Get ALL memories for a user (not similarity-based, just list all).
    Used for deduplication during memory generation.

    Args:
        user_id: The user's UUID string
        limit: Maximum number of memories to return

    Returns:
        List of matching Documents with metadata
    """
    try:
        results, _ = client.scroll(
            collection_name=MEMORY_COLLECTION,
            scroll_filter=Filter(
                must=[
                    FieldCondition(
                        key="metadata.user_id",
                        match=MatchValue(value=user_id)
                    )
                ]
            ),
            limit=limit,
            with_payload=True,
            with_vectors=True,
        )
        return results if results else []
    except Exception as e:
        print(f"[qdrant] Error scrolling user memories: {e}")
        return []


def index_memory(memory_id: str, user_id: str, content: str,
                 category: str, confidence: float = 0.5,
                 created_at: str = None):
    """
    Index an AI memory into Qdrant for RAG retrieval.
    Uses memory_id as the point ID for upsert.

    Args:
        memory_id: UUID of the memory (used as Qdrant point ID)
        user_id: UUID of the user who owns this memory
        content: The memory text (e.g., "I value my family.")
        category: Memory category (values, habits, patterns, etc.)
        confidence: AI confidence score (0.0 - 1.0)
        created_at: ISO timestamp
    """
    from langchain_core.documents import Document

    doc = Document(
        page_content=content,
        metadata={
            "memory_id": memory_id,
            "user_id": user_id,
            "category": category,
            "confidence": confidence,
            "created_at": created_at,
            "type": "memory"
        }
    )

    _get_memory_vector_store().add_documents(
        documents=[doc],
        ids=[memory_id]
    )
    print(f"Indexed memory {memory_id} for user {user_id}: {content[:50]}")


def delete_memory(memory_id: str):
    """
    Delete a memory vector from Qdrant.
    Called when a user deletes a memory from the UI.

    Args:
        memory_id: UUID of the memory (the Qdrant point ID)
    """
    from qdrant_client.models import PointIdsList

    client.delete(
        collection_name=MEMORY_COLLECTION,
        points_selector=PointIdsList(points=[memory_id])
    )
    print(f"Deleted memory {memory_id} from Qdrant")


def check_memory_duplicate(user_id: str, candidate_text: str,
                           threshold: float = 0.85) -> bool:
    """
    Check if a candidate memory is semantically similar to any existing memory.
    Uses cosine similarity of embeddings.

    Args:
        user_id: The user's UUID
        candidate_text: The candidate memory text
        threshold: Similarity threshold (0.85 = very similar)

    Returns:
        True if a duplicate exists (should skip), False if unique
    """
    try:
        # Get existing memories with their vectors
        existing = get_all_user_memories(user_id)
        if not existing:
            return False

        # Embed the candidate
        candidate_embedding = _get_embeddings().embed_query(candidate_text)
        candidate_vec = np.array(candidate_embedding)

        # Compare against all existing memory vectors
        for point in existing:
            if point.vector is not None:
                existing_vec = np.array(point.vector)
                # Cosine similarity
                similarity = np.dot(candidate_vec, existing_vec) / (
                    np.linalg.norm(candidate_vec) *
                    np.linalg.norm(existing_vec)
                )
                if similarity >= threshold:
                    existing_content = point.payload.get("page_content", "")
                    print(
                        f"[dedup] Duplicate found: '{candidate_text[:40]}' ≈ '{existing_content[:40]}' (sim={similarity:.3f})")
                    return True

        return False

    except Exception as e:
        print(f"[dedup] Error checking duplicate: {e}")
        # On error, allow the memory (better to have duplicate than miss)
        return False
