import asyncio
import json
from fastapi import APIRouter, HTTPException
from fastapi.responses import StreamingResponse
from service.ai_service_processor import AIProcessor
from models.messages import AnalyzeJournalRequest

router = APIRouter()


@router.post("/api/analyze-journal")
async def analyze_journal(request: AnalyzeJournalRequest):
    """
    Generate a single follow-up question based on user's journal content.
    Enhanced with RAG: queries Qdrant for the user's past journals
    and includes them as context for richer, personalized guidance.
    """
    try:
        ai_processor = AIProcessor.get_instance()

        # Run the blocking LLM call in a thread to avoid blocking the async event loop
        result = await asyncio.to_thread(
            ai_processor.generate_journal_question,
            user_id=request.user_id,
            content=request.content,
            mood_score=request.mood_score,
            slide_prompt=request.slide_prompt,
            slide_group_context=request.slide_group_context,
            current_slide_id=request.current_slide_id,
            collection_title=request.collection_title,
            direction=request.direction,
            your_story=request.your_story,
            app_language=request.app_language,
        )

        return result

    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"AI service error: {str(e)}")


async def _event_generator(request: AnalyzeJournalRequest):
    """Async generator that yields NDJSON events for the streaming endpoint."""
    try:
        ai_processor = AIProcessor.get_instance()

        async for event in ai_processor.generate_journal_question_stream(
            user_id=request.user_id,
            content=request.content,
            mood_score=request.mood_score,
            slide_prompt=request.slide_prompt,
            slide_group_context=request.slide_group_context,
            current_slide_id=request.current_slide_id,
            collection_title=request.collection_title,
            direction=request.direction,
            your_story=request.your_story,
            app_language=request.app_language,
        ):
            yield json.dumps(event) + "\n"

        yield json.dumps({"type": "done"}) + "\n"

    except Exception as e:
        yield json.dumps({"type": "error", "message": str(e)}) + "\n"


@router.post("/api/analyze-journal/stream")
async def analyze_journal_stream(request: AnalyzeJournalRequest):
    """
    Stream a follow-up question token-by-token using NDJSON.
    Crisis detection and RAG retrieval run first; tokens are streamed only if safe.
    """
    return StreamingResponse(
        _event_generator(request),
        media_type="application/x-ndjson",
    )
