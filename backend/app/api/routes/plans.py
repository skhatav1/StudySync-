from fastapi import APIRouter, Depends, HTTPException, Request

from app.core.auth import get_current_user
from app.core.limiter import limiter
from app.schemas.plans import (
    MarkTaskCompleteRequest,
    RecalculatePlanRequest,
    StudySessionCompleteRequest,
    StudySessionCreateRequest,
    StudySessionResponse,
    StudyPlanGenerateRequest,
    StudyPlanResponse,
)
from app.services.planner_service import PlannerService


router = APIRouter()
planner_service = PlannerService()


@router.post("/generate", response_model=StudyPlanResponse)
@limiter.limit("5/minute")
async def generate_plan(request: Request, payload: StudyPlanGenerateRequest, current_user=Depends(get_current_user)) -> StudyPlanResponse:
    return planner_service.generate_plan(current_user["uid"], payload)


@router.get("/current", response_model=StudyPlanResponse | None)
async def current_plan(current_user=Depends(get_current_user)) -> StudyPlanResponse | None:
    return planner_service.get_active_plan(current_user["uid"])


@router.post("/recalculate", response_model=StudyPlanResponse)
@limiter.limit("5/minute")
async def recalculate_plan(request: Request, payload: RecalculatePlanRequest, current_user=Depends(get_current_user)) -> StudyPlanResponse:
    return planner_service.recalculate_plan(current_user["uid"], payload)


@router.get("/recommendations")
async def get_recommendations(current_user=Depends(get_current_user)):
    return planner_service.recommendations(current_user["uid"])


@router.post("/tasks/complete")
async def mark_task_complete(payload: MarkTaskCompleteRequest, current_user=Depends(get_current_user)):
    try:
        return planner_service.mark_task_complete(current_user["uid"], payload)
    except ValueError as exc:
        raise HTTPException(status_code=404, detail=str(exc)) from exc


@router.get("/sessions", response_model=list[StudySessionResponse])
async def list_sessions(current_user=Depends(get_current_user)):
    return planner_service.list_sessions(current_user["uid"])


@router.post("/sessions/start", response_model=StudySessionResponse)
async def start_session(payload: StudySessionCreateRequest, current_user=Depends(get_current_user)):
    return planner_service.start_session(current_user["uid"], payload)


@router.post("/sessions/complete", response_model=StudySessionResponse)
async def complete_session(payload: StudySessionCompleteRequest, current_user=Depends(get_current_user)):
    try:
        return planner_service.complete_session(current_user["uid"], payload)
    except ValueError as exc:
        raise HTTPException(status_code=404, detail=str(exc)) from exc
