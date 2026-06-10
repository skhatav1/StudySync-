import asyncio

from fastapi import APIRouter, Depends

from app.core.auth import get_current_user
from app.schemas.groups import (
    GroupCommentRequest,
    GroupCreateRequest,
    GroupTaskCreateRequest,
    GroupTaskUpdateRequest,
    InviteMemberRequest,
)
from app.services.group_service import GroupService


router = APIRouter()
group_service = GroupService()


@router.get("/")
async def list_groups(current_user=Depends(get_current_user)):
    return await asyncio.to_thread(group_service.list_groups, current_user["uid"])


@router.post("/")
async def create_group(payload: GroupCreateRequest, current_user=Depends(get_current_user)):
    return await asyncio.to_thread(group_service.create_group, current_user["uid"], payload)


@router.post("/{group_id}/invite")
async def invite_member(group_id: str, payload: InviteMemberRequest):
    return await asyncio.to_thread(group_service.invite_member, group_id, payload)


@router.post("/{group_id}/tasks")
async def create_task(group_id: str, payload: GroupTaskCreateRequest, current_user=Depends(get_current_user)):
    return await asyncio.to_thread(group_service.create_task, current_user["uid"], group_id, payload)


@router.patch("/tasks/{task_id}")
async def update_task(task_id: str, payload: GroupTaskUpdateRequest):
    return await asyncio.to_thread(group_service.update_task, task_id, payload)


@router.delete("/tasks/{task_id}")
async def delete_task(task_id: str):
    await asyncio.to_thread(group_service.delete_task, task_id)
    return {"message": "Deleted"}


@router.post("/{group_id}/comments")
async def add_group_comment(group_id: str, payload: GroupCommentRequest, current_user=Depends(get_current_user)):
    return await asyncio.to_thread(group_service.add_resource_comment, current_user["uid"], group_id, payload)
