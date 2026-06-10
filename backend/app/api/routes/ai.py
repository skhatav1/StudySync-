import asyncio

from fastapi import APIRouter, Depends, Request

from app.core.auth import get_current_user
from app.core.limiter import limiter
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

_AI_RATE = "10/minute"


@router.post("/summarize", response_model=SummaryResponse)
@limiter.limit(_AI_RATE)
async def summarize(request: Request, payload: SummaryRequest, current_user=Depends(get_current_user)):
    return await asyncio.to_thread(service.summarize, current_user["uid"], payload)


@router.post("/flashcards", response_model=FlashcardsResponse)
@limiter.limit(_AI_RATE)
async def flashcards(request: Request, payload: SummaryRequest, current_user=Depends(get_current_user)):
    return await asyncio.to_thread(service.flashcards, current_user["uid"], payload)


@router.post("/quiz", response_model=QuizResponse)
@limiter.limit(_AI_RATE)
async def quiz(request: Request, payload: SummaryRequest, current_user=Depends(get_current_user)):
    return await asyncio.to_thread(service.quiz, current_user["uid"], payload)


@router.post("/explain", response_model=ExplainResponse)
@limiter.limit(_AI_RATE)
async def explain(request: Request, payload: ExplainRequest, current_user=Depends(get_current_user)):
    return await asyncio.to_thread(service.explain, current_user["uid"], payload)


@router.post("/chat", response_model=AssistantChatResponse)
@limiter.limit(_AI_RATE)
async def chat(request: Request, payload: AssistantChatRequest, current_user=Depends(get_current_user)):
    return await asyncio.to_thread(service.chat, current_user["uid"], payload)
