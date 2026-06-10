import asyncio

from fastapi import APIRouter, Depends

from app.core.auth import get_current_user
from app.schemas.analytics import AnalyticsSummaryResponse
from app.services.analytics_service import AnalyticsService


router = APIRouter()
analytics_service = AnalyticsService()


@router.get("/summary", response_model=AnalyticsSummaryResponse)
async def analytics_summary(current_user=Depends(get_current_user)):
    return await asyncio.to_thread(analytics_service.summary, current_user["uid"])
