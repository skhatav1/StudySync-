import asyncio

from fastapi import APIRouter, Depends, HTTPException

from app.core.auth import get_current_user
from app.schemas.common import ApiMessage
from app.schemas.profile import OnboardingPayload, UserProfileCreate, UserProfileResponse, UserProfileUpdate
from app.services.profile_service import ProfileService


router = APIRouter()
service = ProfileService()


@router.post("/", response_model=UserProfileResponse)
async def create_profile(payload: UserProfileCreate, current_user=Depends(get_current_user)):
    if payload.uid != current_user["uid"]:
        raise HTTPException(status_code=403, detail="Profile UID does not match authenticated user.")
    return await asyncio.to_thread(service.ensure_profile, payload)


@router.get("/me", response_model=UserProfileResponse | None)
async def get_profile(current_user=Depends(get_current_user)):
    return await asyncio.to_thread(service.get_profile, current_user["uid"])


@router.put("/me", response_model=UserProfileResponse)
async def update_profile(payload: UserProfileUpdate, current_user=Depends(get_current_user)):
    return await asyncio.to_thread(service.update_profile, current_user["uid"], payload)


@router.post("/onboarding", response_model=ApiMessage)
async def save_onboarding(payload: OnboardingPayload, current_user=Depends(get_current_user)):
    result = await asyncio.to_thread(service.save_onboarding, current_user["uid"], payload)
    return ApiMessage(**result)


@router.get("/onboarding-data")
async def get_onboarding_data(current_user=Depends(get_current_user)):
    return await asyncio.to_thread(service.get_onboarding_data, current_user["uid"])
