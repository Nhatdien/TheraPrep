import os
import re
import json
import concurrent.futures
from dotenv import load_dotenv
from service.prompts import get_system_prompt, build_user_prompt, PREP_PACK_SYSTEM_PROMPT, PREP_PACK_PROMPT
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain_core.messages import SystemMessage, HumanMessage
from database.vector_database import (
    search_user_journals, search_user_memories,
    check_memory_duplicate, index_memory, get_top_k_for_direction
)

load_dotenv()

# ─── Config ──────────────────────────────────────────────────────────────────

DEFAULT_LLM_MODEL = "gemini-2.5-flash"


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

MEMORY_EXTRACTION_PROMPT = """You are analyzing journal entries to extract factual insights about the user.

Extract SHORT, FACTUAL statements about the user. Each statement should be:
- Written in first person (e.g., "I value...", "I enjoy...", "I struggle with...")
- One sentence maximum
- A genuine insight, NOT a summary of what they wrote
- Categorized as one of: values, habits, relationships, goals, struggles, preferences, patterns, growth

LANGUAGE REQUIREMENT (CRITICAL):
{language_instruction}

EXISTING MEMORIES (do NOT duplicate these):
{existing_memories}

JOURNAL ENTRIES TO ANALYZE:
{journal_entries}

Return a JSON array of new insights only:
[
  {"content": "I value my family.", "category": "values", "confidence": 0.9},
  {"content": "Sleep quality drops when stressed about deadlines.", "category": "patterns", "confidence": 0.75}
]

Rules:
- Only extract genuinely new insights not already covered by existing memories
- Confidence should reflect how clearly the journal supports this insight (0.5-1.0)
- Prefer fewer high-quality insights over many shallow ones
- Maximum 5 new insights per batch
- If no new insights can be extracted, return an empty array []
- Return ONLY valid JSON, no markdown formatting or code blocks"""


class AIProcessor():
    """
    AI processor focused on generating RAG-enhanced journal follow-up questions.
    Uses Qdrant to retrieve user's past journals for richer, personalized guidance.
    
    All prompt text lives in prompts.py — this class only handles:
    - RAG retrieval (past journals + memories)
    - Building prompts via prompts.py functions
    - Calling the LLM
    - Post-processing responses
    
    Uses singleton pattern — call AIProcessor.get_instance() instead of AIProcessor().
    """

    _instance = None

    def __init__(self):
        self.model = ChatGoogleGenerativeAI(
            google_api_key=os.environ['GOOGLE_API_KEY'],
            model=os.environ.get('LLM_MODEL', DEFAULT_LLM_MODEL),
            temperature=0.7,
            streaming=False
        )

    @classmethod
    def get_instance(cls) -> "AIProcessor":
        """Get or create the singleton AIProcessor instance."""
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

    def extract_memories(self, user_id: str, journal_entries: list[dict],
                         existing_memories: list[str], language: str = "en") -> list[dict]:
        """
        Extract new factual insights from journal entries using GPT.
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

        # Format journal entries for the prompt
        formatted_journals = []
        for i, entry in enumerate(journal_entries, 1):
            title = entry.get("title", "Untitled")
            content = entry.get("content", "")[:1000]  # Truncate long entries
            date = entry.get("created_at", "Unknown date")
            formatted_journals.append(f"{i}. [{date}] \"{title}\"\n{content}")
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
            response = self.model.invoke([
                SystemMessage(
                    content="You are a precise data extraction assistant. Return only valid JSON."),
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
            print(f"[memories] JSON parse error: {e}")
            return []
        except Exception as e:
            print(f"[memories] Error extracting memories: {e}")
            return []

    def generate_journal_question(self, user_id: str, content: str, mood_score: int,
                                  slide_prompt: str = None, slide_group_context: dict = None,
                                  current_slide_id: str = None, collection_title: str = None,
                                  direction: str = None, your_story: str = None,
                                  app_language: str = None) -> str:
        """
        Generate a single follow-up question based on journal content.
        Enhanced with RAG retrieval of past journals for personalized questions.

        Args:
            user_id: User's UUID for Qdrant filtering
            content: User's current journal text
            mood_score: User's mood rating (1-10)
            slide_prompt: Current slide question/prompt
            slide_group_context: Full slide group data including all slides
            current_slide_id: ID of the current slide being worked on
            collection_title: Name of the collection (e.g., "Daily Reflection")
            direction: Reflection direction ('why', 'emotions', 'patterns', 'challenge', 'growth')
            your_story: User's personal story/context
        """
        # Get system prompt (with optional direction enhancement)
        system_prompt = get_system_prompt(direction)

        depth = get_top_k_for_direction(direction)
        memory_depth = max(5, depth)

        # --- RAG: Retrieve journals + memories IN PARALLEL to reduce latency ---
        with concurrent.futures.ThreadPoolExecutor(max_workers=2) as executor:
            journals_future = executor.submit(
                self._retrieve_past_journals, user_id, content, depth
            )
            memories_future = executor.submit(
                self._retrieve_user_memories, user_id, content, memory_depth
            )
            past_journals_context = journals_future.result()
            user_memories_context = memories_future.result()

        # --- Debug: Log retrieved RAG context ---
        print(f"[RAG-DEBUG] User {user_id} | Direction: {direction} | top_k: {depth}")
        if past_journals_context:
            print(f"[RAG-DEBUG] Past journals retrieved:\n{past_journals_context}")
        else:
            print(f"[RAG-DEBUG] No past journals retrieved for this query.")

        if user_memories_context:
            print(f"[RAG-DEBUG] User memories retrieved:\n{user_memories_context}")
        else:
            print(f"[RAG-DEBUG] No user memories retrieved for this query.")

        # --- Build user prompt (all prompt text lives in prompts.py) ---
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

        # --- Debug: Log the final prompt sent to LLM ---
        print(f"[RAG-DEBUG] === SYSTEM PROMPT (first 500 chars) ===\n{system_prompt[:500]}...")
        print(f"[RAG-DEBUG] === USER PROMPT ===\n{user_prompt}")

        # --- Call LLM ---
        response = self.model.invoke([
            SystemMessage(content=system_prompt),
            HumanMessage(content=user_prompt)
        ])

        question = response.content.strip()
        print(f"[RAG-DEBUG] === GENERATED QUESTION ===\n{question}")

        # Remove quotes if LLM added them
        if question.startswith('"') and question.endswith('"'):
            question = question[1:-1]
        if question.startswith("'") and question.endswith("'"):
            question = question[1:-1]

        return question

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

        # Format journal entries
        entries_text = "\n\n".join([
            f"Date: {e.get('created_at', 'unknown')}\n"
            f"Title: {e.get('title', 'Untitled')}\n"
            f"Mood: {e.get('mood_score', 'N/A')}/10\n"
            f"Content: {e.get('content', '')[:800]}"
            for e in journal_entries
        ]) or "(no journal entries)"

        # Format memories
        memories_text = "\n".join(
            f"- {m}" for m in memories
        ) if memories else "(no known patterns yet)"

        prompt = PREP_PACK_PROMPT.format(
            journal_entries=entries_text,
            memories=memories_text,
            language_instruction=language_instruction,
        )

        try:
            response = self.model.invoke([
                SystemMessage(content=PREP_PACK_SYSTEM_PROMPT),
                HumanMessage(content=prompt),
            ])

            raw = _extract_json_from_response(response.content)

            result = json.loads(raw)

            # Validate required top-level keys
            required_keys = {"mood_overview", "key_themes", "emotional_highlights",
                             "patterns", "discussion_points", "growth_moments"}
            missing = required_keys - set(result.keys())
            if missing:
                print(
                    f"[prep-pack] Warning: missing keys in AI response: {missing}")

            return result

        except json.JSONDecodeError as e:
            print(f"[prep-pack] JSON parse error: {e}")
            print(f"[prep-pack] Raw response: {raw[:500]}")
            raise ValueError(f"AI returned invalid JSON: {e}")
        except Exception as e:
            print(f"[prep-pack] Error generating prep pack: {e}")
            raise