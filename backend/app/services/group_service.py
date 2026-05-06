from app.models.domain import CollectionNames
from app.schemas.groups import (
    GroupCommentRequest,
    GroupCreateRequest,
    GroupTaskCreateRequest,
    GroupTaskUpdateRequest,
    InviteMemberRequest,
)
from app.services.firestore_service import FirestoreService


class GroupService:
    def __init__(self) -> None:
        self._store: FirestoreService | None = None

    @property
    def store(self) -> FirestoreService:
        if self._store is None:
            self._store = FirestoreService()
        return self._store

    def create_group(self, uid: str, payload: GroupCreateRequest) -> dict:
        return self.store.create(
            CollectionNames.study_groups,
            {
                "name": payload.name,
                "subject": payload.subject,
                "shared_goal": payload.shared_goal,
                "created_by": uid,
                "member_ids": [uid],
                "member_emails": [],
            },
        )

    def list_groups(self, uid: str) -> list[dict]:
        return self.store.list_for_user(CollectionNames.study_groups, "created_by", uid)

    def invite_member(self, group_id: str, payload: InviteMemberRequest) -> dict:
        group = self.store.get(CollectionNames.study_groups, group_id)
        if not group:
            raise ValueError("Group not found.")
        emails = list(group.get("member_emails", []))
        if payload.email not in emails:
            emails.append(payload.email)
        return self.store.upsert(CollectionNames.study_groups, group_id, {"member_emails": emails})

    def create_task(self, uid: str, group_id: str, payload: GroupTaskCreateRequest) -> dict:
        return self.store.create(
            CollectionNames.group_tasks,
            {**payload.model_dump(), "group_id": group_id, "created_by": uid},
        )

    def update_task(self, task_id: str, payload: GroupTaskUpdateRequest) -> dict:
        return self.store.update(CollectionNames.group_tasks, task_id, payload.model_dump(exclude_none=True))

    def delete_task(self, task_id: str) -> None:
        self.store.delete(CollectionNames.group_tasks, task_id)

    def add_resource_comment(self, uid: str, group_id: str, payload: GroupCommentRequest) -> dict:
        return self.store.create(
            CollectionNames.comments,
            {
                "group_id": group_id,
                "resource_id": payload.resource_id,
                "author_id": uid,
                "text": payload.text,
            },
        )
