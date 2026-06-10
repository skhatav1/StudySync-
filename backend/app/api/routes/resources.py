import asyncio

from fastapi import APIRouter, Depends

from app.core.auth import get_current_user
from app.schemas.resources import ResourceCommentCreate, ResourceMetadataCreate, ResourceMetadataResponse
from app.services.resource_service import ResourceService


router = APIRouter()
resource_service = ResourceService()


@router.get("/", response_model=list[ResourceMetadataResponse])
async def list_resources(current_user=Depends(get_current_user)):
    return await asyncio.to_thread(resource_service.list_resources, current_user["uid"])


@router.post("/", response_model=ResourceMetadataResponse)
async def create_resource(payload: ResourceMetadataCreate, current_user=Depends(get_current_user)):
    return await asyncio.to_thread(resource_service.create_resource, current_user["uid"], payload)


@router.post("/{resource_id}/comments")
async def add_comment(resource_id: str, payload: ResourceCommentCreate, current_user=Depends(get_current_user)):
    return await asyncio.to_thread(resource_service.add_comment, current_user["uid"], resource_id, payload)


@router.get("/{resource_id}/comments")
async def list_comments(resource_id: str, current_user=Depends(get_current_user)):
    return await asyncio.to_thread(resource_service.list_comments, resource_id)
