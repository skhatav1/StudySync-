from datetime import datetime
from typing import Any

from pydantic import BaseModel, Field


class StoredDocument(BaseModel):
    id: str
    data: dict[str, Any]
    created_at: datetime | None = None
    updated_at: datetime | None = None


class CollectionNames:
    users = "users"
    courses = "courses"
    exams = "exams"
    assignments = "assignments"
    study_plans = "study_plans"
    study_sessions = "study_sessions"
    resources = "resources"
    study_groups = "study_groups"
    group_tasks = "group_tasks"
    comments = "comments"
    analytics = "analytics"
    assistant_history = "assistant_history"
    notifications = "notifications"
