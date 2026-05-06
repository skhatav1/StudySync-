from pydantic import BaseModel, Field


class GroupCreateRequest(BaseModel):
    name: str = Field(min_length=2, max_length=80)
    subject: str
    shared_goal: str


class InviteMemberRequest(BaseModel):
    email: str = Field(pattern=r".+@.+\..+")


class GroupTaskCreateRequest(BaseModel):
    title: str
    due_date: str
    assigned_to: list[str] = Field(default_factory=list)
    completed: bool = False


class GroupTaskUpdateRequest(BaseModel):
    title: str | None = None
    due_date: str | None = None
    assigned_to: list[str] | None = None
    completed: bool | None = None


class GroupCommentRequest(BaseModel):
    resource_id: str
    text: str = Field(min_length=1, max_length=1000)
