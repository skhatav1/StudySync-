from pydantic import BaseModel, Field


class ResourceMetadataCreate(BaseModel):
    title: str
    subject: str
    topic: str
    storage_path: str
    download_url: str
    mime_type: str
    tags: list[str] = Field(default_factory=list)
    favorite: bool = False
    linked_session_id: str | None = None


class ResourceMetadataResponse(ResourceMetadataCreate):
    id: str
    owner_id: str


class ResourceCommentCreate(BaseModel):
    text: str = Field(min_length=1, max_length=1000)
