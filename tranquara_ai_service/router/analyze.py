import asyncio
import time
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
    t0 = time.time()
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

        print(
            f"[analyze-journal] user={request.user_id} | "
            f"total={time.time() - t0:.2f}s | "
            f"crisis={result.get('crisis_detected')} | "
            f"direction={request.direction}"
        )
        return result

    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"AI service error: {str(e)}")
