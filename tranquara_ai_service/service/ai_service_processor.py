import os
import re
import asyncio
import hashlib
import threading
import traceback
from dotenv import load_dotenv
from cachetools import TTLCache
from service.prompts import (
    get_system_prompt, build_user_prompt_content,
    CRISIS_CHECK_TEMPLATE, MEMORY_EXTRACTION_TEMPLATE, PREP_PACK_TEMPLATE,
)
from models.llm_output import CrisisCheckResult, MemoryExtractionResult, PrepPackResult
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain_core.globals import set_llm_cache
from langchain_core.caches import InMemoryCache
from database.vector_database import (
    search_user_journals, search_user_memories,
    check_memory_duplicate, get_top_k_for_direction
)

load_dotenv()

# ─── Config ──────────────────────────────────────────────────────────────────

DEFAULT_LLM_MODEL = "gemini-2.5-flash"

# ─── Safe content indicators — skip crisis check for obviously safe content ──
SAFE_CONTENT_PATTERNS = [
    "good day", "great day", "happy", "grateful", "thankful", "blessed",
    "accomplished", "proud of", "celebrated", "wonderful", "amazing",
    "hoàn thành", "tự hào", "hạnh phúc", "vui vẻ", "tuyệt vời",
    "cảm ơn", "biết ơn", "thành công", "đạt được", "tốt lắm",
]


class AIProcessor():
    """
    AI processor for RAG-enhanced journal follow-up questions and therapy prep packs.
    Uses Qdrant to retrieve user's past journals and memories for richer, personalized guidance.

    All prompt text lives in prompts.py — this class only handles:
    - RAG retrieval (past journals + memories)
    - Building prompts via prompts.py functions
    - Invoking LCEL chains (prompt | llm with structured output + retry)
    - Post-processing responses

    Performance features:
    - LangChain InMemoryCache: identical LLM prompts return cached responses (~0ms on 2nd+ hit)
    - asyncio.gather() for concurrent crisis check + RAG retrieval (zero thread overhead)
    - Separate semaphores: crisis (fast, lighter model) vs journal (heavier generation)
    - Lighter CRISIS_LLM_MODEL (default: gemini-2.0-flash) for fast deterministic classification
    - TTL cache on crisis check to skip redundant LLM calls
    - Safe content shortcut to bypass crisis check for positive content
    - with_retry() for automatic exponential backoff on transient API failures

    Uses singleton pattern — call AIProcessor.get_instance() instead of AIProcessor().
    """

    _instance = None
    _instance_lock = threading.Lock()

    def __init__(self):
        _model_name = os.environ.get('LLM_MODEL', DEFAULT_LLM_MODEL)
        # Crisis uses a lighter, faster model — simple binary classification doesn't need
        # the full reasoning power of gemini-2.5-flash (~5-8s). gemini-2.0-flash takes ~1-2s.
        _crisis_model_name = os.environ.get('CRISIS_LLM_MODEL', 'gemini-2.0-flash')
        _api_key = os.environ['GOOGLE_API_KEY']

        # Enable LangChain global LLM cache. Identical prompts (same content + same model params)
        # return cached responses in ~0ms instead of a full API round-trip. This is especially
        # effective for crisis checks (temperature=0 → fully deterministic → perfect cache key)
        # and for k6 / load tests where the same TEST_USER content repeats across iterations.
        set_llm_cache(InMemoryCache())

        # Creative model for journal questions (temperature=0.7 — varied, empathetic output)
        self.model = ChatGoogleGenerativeAI(
            google_api_key=_api_key,
            model=_model_name,
            temperature=0.7,
            streaming=False
        )

        # Deterministic model for crisis detection:
        # - temperature=0: same content always produces same is_crisis result (no inconsistency)
        # - lighter model: crisis is classification, not generation — faster + cheaper
        self._model_crisis = ChatGoogleGenerativeAI(
            google_api_key=_api_key,
            model=_crisis_model_name,
            temperature=0,
            streaming=False
        )

        _retry_kwargs = dict(stop_after_attempt=3, wait_exponential_jitter=True)

        self._llm_with_retry = self.model.with_retry(**_retry_kwargs)

        self.crisis_chain = (
            CRISIS_CHECK_TEMPLATE
            | self._model_crisis.with_structured_output(CrisisCheckResult).with_retry(**_retry_kwargs)
        )
        self.memory_chain = (
            MEMORY_EXTRACTION_TEMPLATE
            | self.model.with_structured_output(MemoryExtractionResult).with_retry(**_retry_kwargs)
        )
        self.prep_pack_chain = (
            PREP_PACK_TEMPLATE
            | self.model.with_structured_output(PrepPackResult).with_retry(**_retry_kwargs)
        )

        # Separate semaphores so fast crisis checks don't compete with slow journal generation.
        # Crisis: lighter model + short prompt → more concurrent slots safe (default: 8).
        # Journal: heavier generation → fewer concurrent slots to stay under rate limits (default: 5).
        # Both are tunable via env vars.
        self._crisis_semaphore = asyncio.Semaphore(int(os.getenv("LLM_CRISIS_MAX_CONCURRENT", "8")))
        self._journal_semaphore = asyncio.Semaphore(int(os.getenv("LLM_JOURNAL_MAX_CONCURRENT", "5")))

        # Crisis result cache: 5 min TTL, up to 1000 entries
        self._crisis_cache = TTLCache(maxsize=1000, ttl=300)
        self._crisis_cache_lock = threading.Lock()

    @classmethod
    def get_instance(cls) -> "AIProcessor":
        """Get or create the singleton AIProcessor instance (thread-safe)."""
        if cls._instance is None:
            with cls._instance_lock:
                if cls._instance is None:
                    cls._instance = cls()
        return cls._instance

    def _retrieve_past_journals(self, user_id: str, current_content: str, top_k: int = 5) -> str:
        """
        Query Qdrant for the user's past journal entries that are semantically
        similar to what they're currently writing about.

        Returns a formatted string of past journal excerpts for prompt injection.
        """
        try:
            results = search_user_journals(
                user_id=user_id,
                query=current_content,
                top_k=top_k
            )

            if not results:
                return ""

            past_entries = []
            for i, doc in enumerate(results, 1):
                title = doc.metadata.get("title", "Untitled")
                mood = doc.metadata.get("mood_label") or doc.metadata.get(
                    "mood_score") or "N/A"
                date = doc.metadata.get("created_at", "Unknown date")
                # Truncate long content to keep prompt manageable
                excerpt = doc.page_content[:500]
                if len(doc.page_content) > 500:
                    excerpt += "..."

                past_entries.append(
                    f"  {i}. [{date}] \"{title}\" (mood: {mood})\n     {excerpt}"
                )

            return "\n".join(past_entries)

        except Exception as e:
            print(f"[RAG] Error retrieving past journals: {e}")
            return ""

    def _retrieve_user_memories(self, user_id: str, current_content: str, top_k: int = 10) -> str:
        """
        Query Qdrant for the user's AI-generated memories that are relevant
        to the current journal content.

        Returns a formatted string of memory insights for prompt injection.
        """
        try:
            results = search_user_memories(
                user_id=user_id,
                query=current_content,
                top_k=top_k
            )

            if not results:
                return ""

            memory_lines = []
            for doc in results:
                category = doc.metadata.get("category", "general")
                memory_lines.append(f"  - [{category}] {doc.page_content}")

            return "\n".join(memory_lines)

        except Exception as e:
            print(f"[RAG] Error retrieving user memories: {e}")
            return ""

    async def _aretrieve_past_journals(self, user_id: str, current_content: str, top_k: int = 5) -> str:
        """Async wrapper: runs sync Qdrant journal search in a thread (langchain-qdrant has no async client)."""
        return await asyncio.to_thread(self._retrieve_past_journals, user_id, current_content, top_k)

    async def _aretrieve_user_memories(self, user_id: str, current_content: str, top_k: int = 10) -> str:
        """Async wrapper: runs sync Qdrant memory search in a thread (langchain-qdrant has no async client)."""
        return await asyncio.to_thread(self._retrieve_user_memories, user_id, current_content, top_k)

    @staticmethod
    def _sanitize_journal_content(text: str) -> str:
        """
        Clean journal content for LLM consumption.
        Strips HTML tags and detects TipTap JSON (returns empty string
        because TipTap JSON is not human-readable).
        """
        if not text:
            return ""

        stripped = text.strip()

        # Detect TipTap JSON: starts with {"type":"doc" — not useful for LLM
        if stripped.startswith('{"type"') and '"content"' in stripped[:200]:
            return ""

        # Strip HTML tags if present
        if '<' in stripped and '>' in stripped:
            plain = re.sub(r'<[^>]+>', ' ', stripped)
            plain = re.sub(r'\s+', ' ', plain).strip()
            return plain

        return stripped

    def extract_memories(self, user_id: str, journal_entries: list[dict],
                         existing_memories: list[str], language: str = "en") -> list[dict]:
        """
        Extract DURABLE PSYCHOLOGICAL INSIGHTS from journal entries using LLM.
        Only extracts insights that pass the "durability test" — would still be
        useful 6 months from now. Trivial/ephemeral facts are filtered out.
        Performs semantic deduplication against existing memories.

        Args:
            user_id: User's UUID
            journal_entries: List of dicts with 'title', 'content', 'created_at'
            existing_memories: List of existing memory content strings (for prompt context)
            language: 'en' or 'vi' — the user's preferred language for extracted memories

        Returns:
            List of new unique memories: [{"content": "...", "category": "...", "confidence": 0.x}, ...]
        """
        if not journal_entries:
            return []

        # Format journal entries for the prompt (sanitize content)
        formatted_journals = []
        for i, entry in enumerate(journal_entries, 1):
            title = entry.get("title", "Untitled")
            raw_content = entry.get("content", "")[:1000]
            content = self._sanitize_journal_content(raw_content)
            if not content:
                # Skip entries with no usable content (e.g. TipTap JSON)
                continue
            date = entry.get("created_at", "Unknown date")
            formatted_journals.append(f"{i}. [{date}] \"{title}\"\n{content}")

        if not formatted_journals:
            print(f"[memories] User {user_id}: all {len(journal_entries)} journals had "
                  f"no usable content (TipTap JSON or empty)")
            return []

        journals_text = "\n\n".join(formatted_journals)

        # Format existing memories for dedup context
        existing_text = "\n".join(
            f"- {m}" for m in existing_memories) if existing_memories else "(none yet)"

        # Build language instruction
        if language == 'vi':
            lang_instruction = (
                "Extract ALL memories in Vietnamese (tiếng Việt). "
                "Even if the journal contains English, translate the insight into natural Vietnamese. "
                "Use first-person pronouns naturally in Vietnamese."
            )
        else:
            lang_instruction = "Extract ALL memories in English."

        try:
            result: MemoryExtractionResult = self.memory_chain.invoke({
                "existing_memories": existing_text,
                "journal_entries": journals_text,
                "language_instruction": lang_instruction,
            })
            candidates = result.memories  # list[MemoryCandidate]

            if not candidates:
                print(f"[memories] User {user_id}: no new insights extracted")
                return []

            # Validate and deduplicate
            valid_categories = {"values", "habits", "relationships", "goals",
                                "struggles", "preferences", "patterns", "growth"}
            new_memories = []

            for candidate in candidates[:5]:  # Max 5 per batch
                mem_content = candidate.content.strip()
                category = candidate.category
                confidence = candidate.confidence

                if not mem_content or len(mem_content) < 5:
                    continue
                if category not in valid_categories:
                    category = "preferences"
                confidence = max(0.0, min(1.0, float(confidence)))

                # Semantic dedup against Qdrant vectors
                if check_memory_duplicate(user_id, mem_content):
                    continue

                new_memories.append({
                    "content": mem_content,
                    "category": category,
                    "confidence": confidence,
                })

            print(f"[memories] User {user_id}: extracted {len(new_memories)} new memories "
                  f"from {len(journal_entries)} journals ({len(candidates) - len(new_memories)} duplicates skipped)")
            return new_memories

        except Exception as e:
            print(f"[memories] Error extracting memories for user {user_id}: {e}")
            traceback.print_exc()
            return []

    # ─── Crisis Detection (Layer 2: AI-based) ──────────────────────────────

    # Minimum confidence threshold to trigger crisis response
    CRISIS_CONFIDENCE_THRESHOLD = 0.7

    # Crisis-related keywords that OVERRIDE the safe content shortcut.
    # If ANY of these appear, we ALWAYS run the full crisis check —
    # even if the content also contains positive words like "tuyệt vời".
    # This prevents false negatives like "một ngày tuyệt vời để rời khỏi thế giới này".
    CRISIS_OVERRIDE_PATTERNS = [
        # English crisis signals
        "don't want to wake up", "not waking up", "better off without me",
        "world without me", "end it all", "end my life", "take my life",
        "no reason to live", "no point", "want to disappear", "want to die",
        "kill myself", "hurt myself", "harming myself", "self-harm",
        "suicide", "suicidal", "give up on life", "giving up on life",
        "last day", "final goodbye", "not being here", "not here anymore",
        "can't go on", "cant go on", "can't take it", "can't do this anymore",
        "tired of everything", "tired of living", "don't deserve",
        "no hope", "hopeless", "no future",
        # Vietnamese crisis signals
        "rời khỏi thế giới", "rời khỏi cuộc đời", "rời đi mãi mãi",
        "không muốn thức dậy", "không muốn tỉnh dậy", "không muốn sống",
        "không còn lý do", "không còn điểm", "thế giới không có mình",
        "thế giới tốt hơn không có", "muốn biến mất", "muốn đi xa",
        "muốn chết", "tự tử", "tự hại", "làm đau bản thân",
        "kết thúc cuộc đời", "kết thúc mọi thứ", "hủy hoại bản thân",
        "mình mệt mỏi", "mệt mỏi cuộc sống", "mệt mỏi tất cả",
        "không còn sức", "buông bỏ tất cả", "không đáng sống",
        "không xứng đáng", "không có tương lai", "vô vọng",
        "ngày cuối", "tạm biệt vĩnh viễn",
    ]

    @staticmethod
    def _is_likely_safe_content(content: str) -> bool:
        """
        Quick heuristic check: if content contains clearly positive/safe indicators,
        we can skip the crisis check LLM call entirely.
        
        SAFETY: Crisis override keywords ALWAYS take priority. If any crisis-related
        phrase is detected, the shortcut is bypassed and the full LLM crisis check runs.
        This prevents false negatives like "một ngày tuyệt vời để rời khỏi thế giới này".
        
        This saves ~5-10s and 1 Gemini API call per request for genuinely safe content,
        which significantly reduces load under high concurrency.
        """
        content_lower = content.lower()
        
        # CRITICAL: Check crisis overrides FIRST — if ANY match, never shortcut
        for pattern in AIProcessor.CRISIS_OVERRIDE_PATTERNS:
            if pattern in content_lower:
                return False  # Must run full crisis check
        
        positive_count = sum(1 for pattern in SAFE_CONTENT_PATTERNS
                            if pattern in content_lower)
        # If 2+ positive indicators and no crisis overrides, likely safe
        if positive_count >= 2:
            return True
        # Short content with 1+ positive indicator and no crisis overrides
        if positive_count >= 1 and len(content) < 200:
            return True
        return False

    async def acheck_crisis(self, content: str) -> dict:
        """
        Async crisis detection. Runs concurrently with RAG retrieval inside
        agenerate_journal_question() via asyncio.gather().

        Returns:
            {"is_crisis": bool, "confidence": float, "message": str|None}
        """
        # --- Shortcut 1: Skip LLM for obviously safe content ---
        if self._is_likely_safe_content(content):
            print(f"[crisis-check] Skipped LLM call (safe content detected)")
            return {"is_crisis": False, "confidence": 0.0, "message": None}

        # --- Shortcut 2: Check cache ---
        cache_key = hashlib.md5(content[:500].encode()).hexdigest()
        with self._crisis_cache_lock:
            cached = self._crisis_cache.get(cache_key)
            if cached is not None:
                print(f"[crisis-check] Cache hit (result={cached['is_crisis']})")
                return cached

        # --- Full LLM-based crisis check via crisis_chain (async) ---
        try:
            async with self._crisis_semaphore:
                llm_result: CrisisCheckResult = await self.crisis_chain.ainvoke({"content": content[:1500]})

            is_crisis = llm_result.is_crisis
            confidence = llm_result.confidence
            message = llm_result.message

            if is_crisis and confidence < self.CRISIS_CONFIDENCE_THRESHOLD:
                print(f"[crisis-check] Below threshold ({confidence:.2f} < {self.CRISIS_CONFIDENCE_THRESHOLD}), treating as safe")
                is_crisis = False

            print(f"[crisis-check] is_crisis={is_crisis}, confidence={confidence:.2f}")

            crisis_result = {
                "is_crisis": is_crisis,
                "confidence": confidence,
                "message": message if is_crisis else None,
            }

            with self._crisis_cache_lock:
                self._crisis_cache[cache_key] = crisis_result

            return crisis_result

        except Exception as e:
            print(f"[crisis-check] Error (defaulting to safe): {e}")
            return {"is_crisis": False, "confidence": 0.0, "message": None}

    async def agenerate_journal_question(self, user_id: str, content: str, mood_score: int,
                                         slide_prompt: str = None, slide_group_context: dict = None,
                                         current_slide_id: str = None, collection_title: str = None,
                                         direction: str = None, your_story: str = None,
                                         app_language: str = None) -> dict:
        """
        Generate a follow-up journal question with RAG context and crisis detection.

        Execution timeline (optimistic parallel):
          t=0:    crisis_task starts + RAG retrieval starts (all parallel)
          t~0.5:  RAG done → build prompt → journal_task starts IMMEDIATELY
          t~1-2:  crisis_task done (gemini-2.0-flash, overlaps with journal generation)
          t~5-8:  journal_task done → check crisis result → return

        Crisis check no longer blocks journal generation. For the ~95%+ of non-crisis
        content, total latency = journal_generation_time only (~5-8s with gemini-2.5-flash,
        ~2-4s with gemini-2.0-flash). Use LLM_MODEL=gemini-2.0-flash for <5s responses.

        Returns:
            {"question": str|None, "crisis_detected": bool, "crisis_message": str|None}
        """
        depth = get_top_k_for_direction(direction)
        memory_depth = max(5, depth)

        # Phase 1: Start crisis check as a background task immediately (don't await yet).
        # It will run concurrently with RAG retrieval AND journal generation.
        crisis_task = asyncio.create_task(self.acheck_crisis(content))

        # Phase 1: RAG retrieval — runs in parallel with crisis check.
        past_journals_context, user_memories_context = await asyncio.gather(
            self._aretrieve_past_journals(user_id, content, depth),
            self._aretrieve_user_memories(user_id, content, memory_depth),
        )

        print(f"[RAG-DEBUG] User {user_id} | Direction: {direction} | top_k: {depth}")
        if past_journals_context:
            print(f"[RAG-DEBUG] Past journals retrieved:\n{past_journals_context}")
        else:
            print("[RAG-DEBUG] No past journals retrieved.")
        if user_memories_context:
            print(f"[RAG-DEBUG] Memories retrieved:\n{user_memories_context}")
        else:
            print("[RAG-DEBUG] No memories retrieved.")

        # Phase 2: Build prompt (sync, ~0ms) and fire journal generation IMMEDIATELY.
        # Crisis check is still running — journal overlaps with it completely.
        user_prompt_content = build_user_prompt_content(
            content=content,
            mood_score=mood_score,
            slide_prompt=slide_prompt,
            slide_group_context=slide_group_context,
            current_slide_id=current_slide_id,
            collection_title=collection_title,
            direction=direction,
            past_journals_context=past_journals_context,
            your_story=your_story,
            user_memories_context=user_memories_context,
            app_language=app_language,
        )
        print(f"[RAG-DEBUG] === USER PROMPT ===\n{user_prompt_content}")

        journal_chain = get_system_prompt(direction) | self._llm_with_retry

        async def _run_journal():
            async with self._journal_semaphore:
                return await journal_chain.ainvoke({"user_prompt": user_prompt_content})

        journal_task = asyncio.create_task(_run_journal())

        # Phase 3: Await both — crisis check should finish well before journal does.
        # If crisis is detected, the journal result is discarded (safety takes priority).
        crisis_result, response = await asyncio.gather(crisis_task, journal_task)

        if crisis_result["is_crisis"]:
            print(f"[crisis] Detected (confidence={crisis_result['confidence']:.2f}), discarding journal response")
            return {
                "question": None,
                "crisis_detected": True,
                "crisis_message": crisis_result["message"],
            }

        question = response.content.strip()
        print(f"[RAG-DEBUG] === GENERATED QUESTION ===\n{question}")

        if question.startswith('"') and question.endswith('"'):
            question = question[1:-1]
        if question.startswith("'") and question.endswith("'"):
            question = question[1:-1]

        return {
            "question": question,
            "crisis_detected": False,
            "crisis_message": None,
        }

    def generate_prep_pack(self, journal_entries: list[dict],
                           memories: list[str], language: str = "en") -> dict:
        """
        Generate a structured Therapy Session Prep Pack from journal entries and AI memories.

        Args:
            journal_entries: List of dicts with 'title', 'content', 'mood_score', 'created_at'
            memories: List of memory content strings
            language: 'en' or 'vi'

        Returns:
            Structured prep pack dict matching the PrepPack TypeScript type
        """
        # Build language instruction
        if language == 'vi':
            language_instruction = (
                "Write ALL free-text content in Vietnamese (tiếng Việt). "
                "Use natural, conversational Vietnamese — not word-for-word translations from English. "
                "EXCEPTION: The following JSON field values are system identifiers and MUST remain in English exactly as shown: "
                "trend ('improving', 'declining', 'stable') and category ('triggers', 'patterns', 'coping', 'relationships', 'growth')."
            )
        else:
            language_instruction = "Write all content in English."

        # Format journal entries (sanitize content for LLM readability)
        sanitized_entries = []
        for e in journal_entries:
            raw = e.get("content", "")[:800]
            clean = AIProcessor._sanitize_journal_content(raw) if raw else ""
            sanitized_entries.append(
                f"Date: {e.get('created_at', 'unknown')}\n"
                f"Title: {e.get('title', 'Untitled')}\n"
                f"Mood: {e.get('mood_score', 'N/A')}/10\n"
                f"Content: {clean}"
            )
        entries_text = "\n\n".join(sanitized_entries) or "(no journal entries)"

        # Format memories
        memories_text = "\n".join(
            f"- {m}" for m in memories
        ) if memories else "(no known patterns yet)"

        try:
            result: PrepPackResult = self.prep_pack_chain.invoke({
                "journal_entries": entries_text,
                "memories": memories_text,
                "language_instruction": language_instruction,
            })
            return result.model_dump()

        except Exception as e:
            print(f"[prep-pack] Error generating prep pack: {e}")
            raise