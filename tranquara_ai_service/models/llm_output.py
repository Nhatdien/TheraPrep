from typing import Optional
from pydantic import BaseModel, Field


# ─── Crisis Detection ─────────────────────────────────────────────────────

class CrisisCheckResult(BaseModel):
    is_crisis: bool = Field(description="Whether the content shows signs of psychological crisis")
    confidence: float = Field(description="Confidence score from 0.0 to 1.0")
    message: Optional[str] = Field(
        default=None,
        description="Warm supportive message in the same language as the text, or null if not crisis"
    )


# ─── Memory Extraction ────────────────────────────────────────────────────

class MemoryCandidate(BaseModel):
    content: str = Field(description="Durable psychological insight written in first person")
    category: str = Field(
        description="One of: values, habits, relationships, goals, struggles, preferences, patterns, growth"
    )
    confidence: float = Field(
        description="How clearly the journal entries support this insight, from 0.5 to 1.0"
    )


class MemoryExtractionResult(BaseModel):
    memories: list[MemoryCandidate] = Field(
        description="New durable psychological insights extracted from the journal entries. Empty list if none found."
    )


# ─── Therapy Prep Pack ────────────────────────────────────────────────────

class MoodDataPoint(BaseModel):
    date: str = Field(description="ISO date string")
    score: float = Field(description="Mood score from 1 to 10")


class MoodHighlight(BaseModel):
    score: float = Field(description="Mood score from 1 to 10")
    date: str = Field(description="ISO date string")
    title: str = Field(description="Journal entry title in the target language")


class MoodOverview(BaseModel):
    average: float = Field(description="Average mood score across all entries, from 1 to 10")
    trend: str = Field(description="Overall mood trend: 'improving', 'declining', or 'stable'")
    data_points: list[MoodDataPoint] = Field(description="Mood score per journal entry, chronologically ordered")
    highest: MoodHighlight = Field(description="Entry with the highest mood score")
    lowest: MoodHighlight = Field(description="Entry with the lowest mood score")


class EmotionalHighlight(BaseModel):
    date: str = Field(description="ISO date string")
    title: str = Field(description="Journal entry title in the target language")
    mood: float = Field(description="Mood score from 1 to 10")
    excerpt: str = Field(
        description="Brief excerpt in target language — use gentle language for painful content, no graphic details"
    )
    significance: str = Field(description="Why this entry is emotionally significant, in the target language")


class JournalPattern(BaseModel):
    pattern: str = Field(
        description="Observed psychological pattern in target language — describe gently without re-narrating traumatic details"
    )
    category: str = Field(description="One of: triggers, patterns, coping, relationships, growth")
    confidence: float = Field(description="Confidence score from 0.5 to 1.0")


class PrepPackResult(BaseModel):
    crisis_warning: bool = Field(
        description="True if any journal entry shows signs of crisis (suicidal thoughts, self-harm, hopeless despair)"
    )
    crisis_message: Optional[str] = Field(
        default=None,
        description="Warm supportive message in target language if crisis_warning is true, otherwise null"
    )
    mood_overview: MoodOverview
    key_themes: list[str] = Field(description="3-5 recurring topics across entries, in the target language")
    emotional_highlights: list[EmotionalHighlight] = Field(
        description="2-3 most emotionally significant journal entries"
    )
    patterns: list[JournalPattern] = Field(
        description="Observed patterns, cross-referenced with known memories"
    )
    discussion_points: list[str] = Field(
        description="2-3 open-ended therapy discussion questions in the target language"
    )
    growth_moments: list[str] = Field(
        description="Positive changes, self-awareness moments, and healthy coping behaviors, in the target language"
    )
