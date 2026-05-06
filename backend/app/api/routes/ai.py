from fastapi import APIRouter, Depends

from app.core.auth import get_current_user
from app.schemas.ai import (
    AssistantChatRequest,
    AssistantChatResponse,
    ExplainRequest,
    ExplainResponse,
    FlashcardsResponse,
    QuizResponse,
    SummaryRequest,
    SummaryResponse,
)
from app.services.ai_service import AIService


router = APIRouter()
service = AIService()


@router.post("/summarize", response_model=SummaryResponse)
async def summarize(payload: SummaryRequest, current_user=Depends(get_current_user)):
    return service.summarize(current_user["uid"], payload)


@router.post("/flashcards", response_model=FlashcardsResponse)
async def flashcards(payload: SummaryRequest, current_user=Depends(get_current_user)):
    return service.flashcards(current_user["uid"], payload)


@router.post("/quiz", response_model=QuizResponse)
async def quiz(payload: SummaryRequest, current_user=Depends(get_current_user)):
    return service.quiz(current_user["uid"], payload)


@router.post("/explain", response_model=ExplainResponse)
async def explain(payload: ExplainRequest, current_user=Depends(get_current_user)):
    return service.explain(current_user["uid"], payload)


@router.post("/chat", response_model=AssistantChatResponse)
async def chat(payload: AssistantChatRequest, current_user=Depends(get_current_user)):
    return service.chat(current_user["uid"], payload)
