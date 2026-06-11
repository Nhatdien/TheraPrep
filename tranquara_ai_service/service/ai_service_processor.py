import os
import re
import json
import hashlib
import threading
import traceback
import concurrent.futures
from dotenv import load_dotenv
from cachetools import TTLCache
from service.prompts import (
    get_system_prompt, build_user_prompt,
    PREP_PACK_SYSTEM_PROMPT, PREP_PACK_PROMPT,
    PREP_PACK_SECTION_A_PROMPT, PREP_PACK_SECTION_B_PROMPT, PREP_PACK_SECTION_C_PROMPT,
    CRISIS_CHECK_SYSTEM_PROMPT, CRISIS_CHECK_USER_PROMPT
)
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain_core.messages import SystemMessage, HumanMessage
from database.vector_database import (
    search_user_journals, search_user_memories,
    check_memory_duplicate, index_memory, get_top_k_for_direction
)

load_dotenv()

# ─── Config ──────────────────────────────────────────────────────────────────

DEFAULT_LLM_MODEL = "gemini-2.5-flash"

# Shared thread pool for RAG retrieval and crisis checks across all requests.
# Using a single pool avoids the overhead of creating/destroying threads per request.
_SHARED_EXECUTOR = concurrent.futures.ThreadPoolExecutor(max_workers=20)


def _extract_json_from_response(raw: str) -> str:
    """
    Robustly extract JSON from LLM response text.
    Handles markdown code blocks (```json...```), leading/trailing text, etc.
    Works with responses from both OpenAI and Gemini models.
    """
    text = raw.strip()

    # 1. Strip markdown code blocks: ```json ... ``` or ``` ... ```
    text = re.sub(r'^```(?:json|JSON)?\s*\n?', '', text)
    text = re.sub(r'\n?```\s*$', '', text)
    text = text.strip()

    # 2. If the text starts with [ or {, try to parse directly
    if text.startswith('[') or text.startswith('{'):
        return text

    # 3. Look for JSON array or object embedded in text
    # Try to find the outermost [ ... ] or { ... }
    for opener, closer in [('[', ']'), ('{', '}')]:
        start = text.find(opener)
        if start != -1:
            # Find the matching closing bracket
            depth = 0
            for i in range(start, len(text)):
                if text[i] == opener:
                    depth += 1
                elif text[i] == closer:
                    depth -= 1
                if depth == 0:
                    return text[start:i + 1]

    # 4. Fallback: return as-is and let json.loads handle the error
    return text


# ─── Memory Extraction Prompt ──────────────────────────────────────────────

MEMORY_EXTRACTION_PROMPT = """You are analyzing journal entries to extract DURABLE PSYCHOLOGICAL INSIGHTS about the user.

Your goal: extract insights that reveal WHO the user is — NOT what happened to them on a particular day.

═══ DURABILITY TEST (apply to EVERY candidate insight) ═══
Before extracting any insight, ask yourself:
"Would this still be useful to know 6 months from now?"
If the answer is NO → do NOT extract it.

═══ WHAT TO EXTRACT (durable insights) ═══
Each statement should be:
- Written in first person (e.g., "I value...", "I tend to...", "I struggle with...")
- One sentence maximum
- A genuine PSYCHOLOGICAL insight about the user's inner world, NOT a factual summary of events
- Categorized as one of: values, habits, relationships, goals, struggles, preferences, patterns, growth

✅ GOOD examples (extract these):
- "I value honesty over comfort in my relationships" (values)
- "I tend to procrastinate when I feel overwhelmed by expectations" (patterns)
- "My sleep suffers when I'm anxious about deadlines" (patterns — a DURABLE pattern, not a one-time event)
- "I cope with stress by isolating myself from friends" (habits)
- "I find it hard to set boundaries with my family" (relationships)
- "I prefer having a structured routine over spontaneous plans" (preferences)
- "I'm learning to accept imperfection in my work" (growth)
- "I feel anxious when I don't have a clear plan" (struggles)

❌ DO NOT extract these (ephemeral/trivial):
- "I slept 5 hours last night" → one-time event, NOT an insight
- "My phone broke today" → random event, says nothing about the user
- "I had a meeting with my boss" → daily occurrence, no psychological depth
- "I ate pho for lunch" / "I have a cat named Luna" → trivia
- "I felt sad yesterday" → temporary state, NOT a pattern (unless it clearly reveals one)
- "I'm tired today" / "I have a headache" → ephemeral state

═══ THE KEY DISTINCTION ═══
A fact becomes an insight ONLY when it reveals a repeating pattern, a core value, or a psychological tendency:
- FACT (skip): "I slept 5 hours last night"
- INSIGHT (extract): "My sleep suffers when I'm anxious about deadlines"
- FACT (skip): "I argued with my friend today"
- INSIGHT (extract): "I avoid confrontation even when I know I'm right"

LANGUAGE REQUIREMENT (CRITICAL):
{language_instruction}

EXISTING MEMORIES (do NOT duplicate these):
{existing_memories}

JOURNAL ENTRIES TO ANALYZE:
{journal_entries}

Return a JSON array of new insights only:
[
  {{"content": "I value my family.", "category": "values", "confidence": 0.9}},
  {{"content": "My sleep quality drops when I'm stressed about deadlines.", "category": "patterns", "confidence": 0.75}}
]

Rules:
- Only extract genuinely new insights not already covered by existing memories
- Apply the DURABILITY TEST to every candidate — if it won't matter in 6 months, skip it
- Confidence should reflect how clearly the journal supports this insight (0.5-1.0)
- Prefer fewer high-quality insights over many shallow ones — 1-2 excellent insights beats 5 mediocre ones
- Maximum 5 new insights per batch
- If no new durable insights can be extracted, return an empty array []
- Return ONLY valid JSON, no markdown formatting or code blocks"""


# ─── Safe content indicators — skip crisis check for obviously safe content ──
SAFE_CONTENT_PATTERNS = [
    "good day", "great day", "happy", "grateful", "thankful", "blessed",
    "accomplished", "proud of", "celebrated", "wonderful", "amazing",
    "hoàn thành", "tự hào", "hạnh phúc", "vui vẻ", "tuyệt vời",
    "cảm ơn", "biết ơn", "thành công", "đạt được", "tốt lắm",
]

# ─── Retry settings for Gemini API calls ──────────────────────────────────
LLM_MAX_RETRIES = int(os.getenv("LLM_MAX_RETRIES", "3"))
LLM_RETRY_BASE_DELAY = float(os.getenv("LLM_RETRY_BASE_DELAY", "2.0"))


class AIProcessor():
    """
    AI processor focused on generating RAG-enhanced journal follow-up questions.
    Uses Qdrant to retrieve user's past journals for richer, personalized guidance.

    All prompt text lives in prompts.py — this class only handles:
    - RAG retrieval (past journals + memories)
    - Building prompts via prompts.py functions
    - Calling the LLM (with rate limiting + retry)
    - Post-processing responses

    Performance features:
    - Crisis check caching (TTL 5 min) to skip redundant LLM calls
    - Safe content shortcut to bypass crisis check for positive content
    - Automatic retry with exponential backoff on transient API failures

    Uses singleton pattern — call AIProcessor.get_instance() instead of AIProcessor().
    """

    _instance = None
    _instance_lock = threading.Lock()

    def __init__(self):
        self.model = ChatGoogleGenerativeAI(
            google_api_key=os.environ['GOOGLE_API_KEY'],
            model=os.environ.get('LLM_MODEL', DEFAULT_LLM_MODEL),
            temperature=0.7,
            streaming=False
        )

        # Lightweight model for crisis checks — faster TTFT and lower latency.
        # Using a smaller model for this simple binary-classification task
        # saves ~2-3s per request vs the main model.
        self._crisis_model = ChatGoogleGenerativeAI(
            google_api_key=os.environ['GOOGLE_API_KEY'],
            model=os.environ.get('CRISIS_LLM_MODEL', 'gemini-2.5-flash'),
            temperature=0.0,
            streaming=False,
        )

        # Crisis check cache: 5 min TTL, up to 1000 entries
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

    # ─── Rate-limited LLM invocation with retry ───────────────────────────

    def _invoke_with_retry(self, messages: list, max_retries: int = None, model=None) -> object:
        """
        Call the LLM with exponential backoff retry on transient failures.

        Retries on rate limit (429), timeout, quota, and server errors (5xx).
        Uses backoff (2s → 4s → 8s) to give Gemini API breathing room on overload.

        Args:
            messages: List of langchain messages
            max_retries: Override default retry count
            model: Specific model instance to use (defaults to self.model)
        """
        import time
        if max_retries is None:
            max_retries = LLM_MAX_RETRIES
        target_model = model or self.model

        last_error = None
        for attempt in range(max_retries):
            try:
                return target_model.invoke(messages)
            except Exception as e:
                last_error = e
                error_str = str(e).lower()
                # Retry on rate limit (429), timeout, or server errors (5xx)
                is_retryable = any(code in error_str for code in
                                   ["429", "rate", "quota", "timeout", "503", "500"])
                if not is_retryable or attempt == max_retries - 1:
                    raise

                delay = LLM_RETRY_BASE_DELAY * (2 ** attempt)
                print(f"[llm-retry] Attempt {attempt + 1}/{max_retries} failed: {e}. "
                      f"Retrying in {delay:.1f}s...")
                time.sleep(delay)

        raise last_error

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

        # Build prompt
        prompt = MEMORY_EXTRACTION_PROMPT.format(
            existing_memories=existing_text,
            journal_entries=journals_text,
            language_instruction=lang_instruction,
        )

        try:
            response = self._invoke_with_retry([
                SystemMessage(
                    content="You are an insightful psychological analyst. Extract only DURABLE insights about the user's inner world — skip trivial facts and ephemeral events. Return only valid JSON."),
                HumanMessage(content=prompt)
            ])

            raw = _extract_json_from_response(response.content)

            candidates = json.loads(raw)

            if not isinstance(candidates, list):
                print(f"[memories] LLM returned non-list: {type(candidates)}")
                return []

            # Validate and deduplicate
            valid_categories = {"values", "habits", "relationships", "goals",
                                "struggles", "preferences", "patterns", "growth"}
            new_memories = []

            for candidate in candidates[:5]:  # Max 5 per batch
                content = candidate.get("content", "").strip()
                category = candidate.get("category", "preferences")
                confidence = candidate.get("confidence", 0.5)

                if not content or len(content) < 5:
                    continue
                if category not in valid_categories:
                    category = "preferences"
                if not isinstance(confidence, (int, float)):
                    confidence = 0.5
                confidence = max(0.0, min(1.0, float(confidence)))

                # Semantic dedup against Qdrant vectors
                if check_memory_duplicate(user_id, content):
                    continue

                new_memories.append({
                    "content": content,
                    "category": category,
                    "confidence": confidence,
                })

            print(f"[memories] User {user_id}: extracted {len(new_memories)} new memories "
                  f"from {len(journal_entries)} journals ({len(candidates) - len(new_memories)} duplicates skipped)")
            return new_memories

        except json.JSONDecodeError as e:
            print(f"[memories] JSON parse error for user {user_id}: {e}")
            print(
                f"[memories] Raw LLM response (first 500 chars): {raw[:500]}")
            return []
        except Exception as e:
            print(
                f"[memories] Error extracting memories for user {user_id}: {e}")
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

    def check_crisis(self, content: str) -> dict:
        """
        Dedicated lightweight LLM call to check if content is crisis-related.
        Runs in parallel with RAG retrieval to minimize added latency.

        Performance optimizations:
        1. Safe content shortcut — skip LLM for obviously positive content
        2. TTL cache — avoid re-checking identical content within 5 minutes

        Returns:
            {"is_crisis": bool, "confidence": float, "message": str|None}
        """
        # --- Shortcut 1: Skip LLM for obviously safe content ---
        if self._is_likely_safe_content(content):
            print(f"[crisis-check] Skipped LLM call (safe content detected)")
            return {"is_crisis": False, "confidence": 0.0, "message": None}

        # --- Shortcut 2: Check cache for identical/similar content ---
        cache_key = hashlib.md5(content[:500].encode()).hexdigest()
        with self._crisis_cache_lock:
            cached = self._crisis_cache.get(cache_key)
            if cached is not None:
                print(
                    f"[crisis-check] Cache hit (result={cached['is_crisis']})")
                return cached

        # --- Full LLM-based crisis check ---
        try:
            user_prompt = CRISIS_CHECK_USER_PROMPT.format(
                content=content[:1500])

            response = self._invoke_with_retry([
                SystemMessage(content=CRISIS_CHECK_SYSTEM_PROMPT),
                HumanMessage(content=user_prompt),
            ], model=self._crisis_model)

            raw = _extract_json_from_response(response.content)
            result = json.loads(raw)

            is_crisis = result.get("is_crisis", False)
            confidence = float(result.get("confidence", 0.0))
            message = result.get("message")

            # Apply confidence threshold
            if is_crisis and confidence < self.CRISIS_CONFIDENCE_THRESHOLD:
                print(
                    f"[crisis-check] Below threshold ({confidence:.2f} < {self.CRISIS_CONFIDENCE_THRESHOLD}), treating as safe")
                is_crisis = False

            print(
                f"[crisis-check] is_crisis={is_crisis}, confidence={confidence:.2f}")

            crisis_result = {
                "is_crisis": is_crisis,
                "confidence": confidence,
                "message": message if is_crisis else None,
            }

            # Cache the result
            with self._crisis_cache_lock:
                self._crisis_cache[cache_key] = crisis_result

            return crisis_result

        except (json.JSONDecodeError, Exception) as e:
            # On error, be conservative — don't block the user
            print(f"[crisis-check] Error (defaulting to safe): {e}")
            return {"is_crisis": False, "confidence": 0.0, "message": None}

    def _generate_question_llm(self, system_prompt: str, user_prompt: str) -> str:
        """Internal helper: call the main LLM for question generation."""
        response = self._invoke_with_retry([
            SystemMessage(content=system_prompt),
            HumanMessage(content=user_prompt)
        ])
        question = response.content.strip()
        # Remove quotes if LLM added them
        if question.startswith('"') and question.endswith('"'):
            question = question[1:-1]
        if question.startswith("'") and question.endswith("'"):
            question = question[1:-1]
        return question

    def generate_journal_question(self, user_id: str, content: str, mood_score: int,
                                  slide_prompt: str = None, slide_group_context: dict = None,
                                  current_slide_id: str = None, collection_title: str = None,
                                  direction: str = None, your_story: str = None,
                                  app_language: str = None) -> dict:
        """
        Generate a single follow-up question based on journal content.
        Uses SPECULATIVE PARALLEL EXECUTION:
          - Crisis check runs on the fast model in parallel with RAG retrieval.
          - As soon as RAG data arrives, the question-generation LLM call is
            fired SPECULATIVELY on the main model.
          - When the crisis check finishes:
              * If crisis → abort the speculative question, return crisis response.
              * If safe → wait for the speculative question and return it.
        This overlaps the slow question-generation call with the crisis check,
        cutting total latency from ~10s to ~5-6s in the common safe-content case.

        Returns:
            {
                "question": str | None,
                "crisis_detected": bool,
                "crisis_message": str | None
            }
        """
        import time
        t_start = time.time()

        depth = get_top_k_for_direction(direction)
        memory_depth = max(5, depth)

        # ── Phase 1: Fire crisis check + RAG retrieval in parallel ──
        crisis_future = _SHARED_EXECUTOR.submit(self.check_crisis, content)
        journals_future = _SHARED_EXECUTOR.submit(
            self._retrieve_past_journals, user_id, content, depth
        )
        memories_future = _SHARED_EXECUTOR.submit(
            self._retrieve_user_memories, user_id, content, memory_depth
        )

        # Wait for RAG data (needed to build the prompt).
        # Crisis check is still running in parallel.
        past_journals_context = journals_future.result()
        user_memories_context = memories_future.result()

        t_rag_done = time.time()

        # ── Phase 2: Build prompt and fire SPECULATIVE question generation ──
        system_prompt = get_system_prompt(direction)
        user_prompt = build_user_prompt(
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

        # Fire the speculative question-generation call.
        # If crisis is later detected, this result is simply discarded.
        question_future = _SHARED_EXECUTOR.submit(
            self._generate_question_llm, system_prompt, user_prompt
        )

        t_question_fired = time.time()

        # ── Phase 3: Wait for crisis result ──
        crisis_result = crisis_future.result()
        t_crisis_done = time.time()

        # --- If crisis detected, abort speculative question and return ---
        if crisis_result["is_crisis"]:
            print(f"[crisis] Crisis detected (confidence={crisis_result['confidence']:.2f}), "
                  f"aborting speculative question generation")
            # We can't truly cancel the future, but we ignore the result.
            return {
                "question": None,
                "crisis_detected": True,
                "crisis_message": crisis_result["message"],
            }

        # ── Phase 4: Safe — collect the speculative question result ──
        question = question_future.result()
        t_done = time.time()

        print(f"[analyze-journal] user={user_id} | "
              f"rag={t_rag_done - t_start:.2f}s | "
              f"speculative-fired={t_question_fired - t_start:.2f}s | "
              f"crisis-done={t_crisis_done - t_start:.2f}s | "
              f"question-done={t_done - t_start:.2f}s | "
              f"total={t_done - t_start:.2f}s")

        return {
            "question": question,
            "crisis_detected": False,
            "crisis_message": None,
        }

    @staticmethod
    def _format_journal_entries_for_prep_pack(journal_entries: list[dict]) -> tuple[str, bool]:
        """Format and summarize journal entries for prep-pack prompts."""
        sorted_entries = sorted(
            journal_entries,
            key=lambda e: e.get("created_at", ""),
            reverse=True,
        )
        MAX_ENTRIES = 20
        truncated = len(sorted_entries) > MAX_ENTRIES
        selected_entries = sorted_entries[:MAX_ENTRIES]

        sanitized_entries = []
        for e in selected_entries:
            raw = e.get("content", "")
            clean = AIProcessor._sanitize_journal_content(raw) if raw else ""
            summary = clean[:200].strip()
            if len(clean) > 200:
                summary += "..."
            sanitized_entries.append(
                f"Date: {e.get('created_at', 'unknown')}\n"
                f"Title: {e.get('title', 'Untitled')}\n"
                f"Mood: {e.get('mood_score', 'N/A')}/10\n"
                f"Content: {summary}"
            )
        entries_text = "\n\n".join(sanitized_entries) or "(no journal entries)"
        if truncated:
            entries_text = (
                f"[Note: {len(sorted_entries)} journal entries were available; "
                f"the {MAX_ENTRIES} most recent are summarized below.]\n\n"
                + entries_text
            )
        return entries_text, truncated

    @staticmethod
    def _format_memories_for_prep_pack(memories: list[str]) -> str:
        """Format memories for prep-pack prompts."""
        MAX_MEMORIES = 20
        selected_memories = memories[:MAX_MEMORIES]
        memories_text = "\n".join(
            f"- {m}" for m in selected_memories
        ) if selected_memories else "(no known patterns yet)"
        if len(memories) > MAX_MEMORIES:
            memories_text = (
                f"[Note: {len(memories)} patterns/memories are known; "
                f"the {MAX_MEMORIES} most relevant are shown below.]\n" +
                memories_text
            )
        return memories_text

    def _generate_prep_pack_section(self, system_prompt: str, user_prompt: str) -> dict:
        """Internal helper: call LLM for a single prep-pack section.
        Validates that the response is a dict, not a string or other type."""
        response = self._invoke_with_retry([
            SystemMessage(content=system_prompt),
            HumanMessage(content=user_prompt),
        ])
        raw = _extract_json_from_response(response.content)
        parsed = json.loads(raw)
        if not isinstance(parsed, dict):
            raise ValueError(
                f"LLM returned {type(parsed).__name__} instead of dict: {str(parsed)[:200]}")
        return parsed

    def _generate_prep_pack_monolithic(self, journal_entries: list[dict],
                                       memories: list[str], language: str = "en") -> dict:
        """Fallback: generate the entire prep pack in one monolithic LLM call.
        Used when parallel section generation fails."""
        if language == 'vi':
            language_instruction = (
                "Write ALL free-text content in Vietnamese (tiếng Việt). "
                "Use natural, conversational Vietnamese — not word-for-word translations from English. "
                "EXCEPTION: The following JSON field values are system identifiers and MUST remain in English exactly as shown: "
                "trend ('improving', 'declining', 'stable') and category ('triggers', 'patterns', 'coping', 'relationships', 'growth')."
            )
        else:
            language_instruction = "Write all content in English."

        entries_text, _ = self._format_journal_entries_for_prep_pack(
            journal_entries)
        memories_text = self._format_memories_for_prep_pack(memories)

        prompt = PREP_PACK_PROMPT.format(
            journal_entries=entries_text,
            memories=memories_text,
            language_instruction=language_instruction,
        )

        response = self._invoke_with_retry([
            SystemMessage(content=PREP_PACK_SYSTEM_PROMPT),
            HumanMessage(content=prompt),
        ])

        raw = _extract_json_from_response(response.content)
        result = json.loads(raw)

        required_keys = {"mood_overview", "key_themes", "emotional_highlights",
                         "patterns", "discussion_points", "growth_moments"}
        missing = required_keys - set(result.keys())
        if missing:
            print(
                f"[prep-pack] Warning: missing keys in monolithic response: {missing}")

        return result

    def generate_prep_pack(self, journal_entries: list[dict],
                           memories: list[str], language: str = "en") -> dict:
        """
        Generate a structured Therapy Session Prep Pack from journal entries and AI memories.
        Uses PARALLEL SECTION GENERATION: splits the work into 3 focused LLM calls
        that run simultaneously, cutting latency from ~30s to ~5-8s.
        Falls back to monolithic generation if parallel sections fail.

        Args:
            journal_entries: List of dicts with 'title', 'content', 'mood_score', 'created_at'
            memories: List of memory content strings
            language: 'en' or 'vi'

        Returns:
            Structured prep pack dict matching the PrepPack TypeScript type
        """
        import time
        t_start = time.time()

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

        entries_text, _ = self._format_journal_entries_for_prep_pack(
            journal_entries)
        memories_text = self._format_memories_for_prep_pack(memories)

        # Build the 3 section prompts
        prompt_a = PREP_PACK_SECTION_A_PROMPT.format(
            language_instruction=language_instruction,
            journal_entries=entries_text,
            memories=memories_text,
        )
        prompt_b = PREP_PACK_SECTION_B_PROMPT.format(
            language_instruction=language_instruction,
            journal_entries=entries_text,
            memories=memories_text,
        )
        prompt_c = PREP_PACK_SECTION_C_PROMPT.format(
            language_instruction=language_instruction,
            journal_entries=entries_text,
            memories=memories_text,
        )

        # Fire all 3 section generations in parallel
        future_a = _SHARED_EXECUTOR.submit(
            self._generate_prep_pack_section, PREP_PACK_SYSTEM_PROMPT, prompt_a
        )
        future_b = _SHARED_EXECUTOR.submit(
            self._generate_prep_pack_section, PREP_PACK_SYSTEM_PROMPT, prompt_b
        )
        future_c = _SHARED_EXECUTOR.submit(
            self._generate_prep_pack_section, PREP_PACK_SYSTEM_PROMPT, prompt_c
        )

        # Collect results
        errors = []
        section_a = {}
        section_b = {}
        section_c = {}

        try:
            section_a = future_a.result()
        except Exception as e:
            errors.append(f"section_a: {e}")
            print(f"[prep-pack] Section A failed: {e}")

        try:
            section_b = future_b.result()
        except Exception as e:
            errors.append(f"section_b: {e}")
            print(f"[prep-pack] Section B failed: {e}")

        try:
            section_c = future_c.result()
        except Exception as e:
            errors.append(f"section_c: {e}")
            print(f"[prep-pack] Section C failed: {e}")

        t_done = time.time()
        print(
            f"[prep-pack] parallel-sections | "
            f"total={t_done - t_start:.2f}s | "
            f"errors={len(errors)} | "
            f"journals={len(journal_entries)} | memories={len(memories)}"
        )

        # If all 3 sections failed, fall back to monolithic generation
        if len(errors) == 3:
            print(
                f"[prep-pack] All parallel sections failed; falling back to monolithic generation")
            return self._generate_prep_pack_monolithic(journal_entries, memories, language)

        # Merge sections into final structure
        result = {
            "crisis_warning": section_a.get("crisis_warning", False),
            "crisis_message": section_a.get("crisis_message"),
            "mood_overview": section_a.get("mood_overview", {}),
            "key_themes": section_a.get("key_themes", []),
            "emotional_highlights": section_b.get("emotional_highlights", []),
            "patterns": section_b.get("patterns", []),
            "discussion_points": section_c.get("discussion_points", []),
            "growth_moments": section_c.get("growth_moments", []),
        }

        # Validate
        required_keys = {"mood_overview", "key_themes", "emotional_highlights",
                         "patterns", "discussion_points", "growth_moments"}
        missing = required_keys - {k for k, v in result.items() if v}
        if missing:
            print(
                f"[prep-pack] Warning: missing keys in merged response: {missing}")
            # If critical sections are missing, fall back to monolithic
            if missing & {"mood_overview", "key_themes", "emotional_highlights", "patterns"}:
                print(
                    f"[prep-pack] Critical sections missing; falling back to monolithic generation")
                return self._generate_prep_pack_monolithic(journal_entries, memories, language)

        return result
