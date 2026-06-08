import asyncio
from fastapi import APIRouter, HTTPException
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

        # Call the async method directly — FastAPI's event loop handles concurrency,
        # no asyncio.to_thread() needed (eliminates per-request thread overhead)
        result = await ai_processor.agenerate_journal_question(
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
