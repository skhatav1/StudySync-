from datetime import datetime

from pydantic import BaseModel


class ApiMessage(BaseModel):
    message: str


class Timestamps(BaseModel):
    created_at: datetime | None = None
    updated_at: datetime | None = None
