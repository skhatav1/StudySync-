from typing import Literal

from pydantic import BaseModel, Field

from app.schemas.profile import AssignmentPayload, CoursePayload, ExamPayload


class StudyPlanContext(BaseModel):
    preferred_study_hours: float = Field(gt=0, le=12)
    preferred_study_times: list[str] = Field(default_factory=list)
    weak_subjects: list[str] = Field(default_factory=list)
    learning_style: str = "mixed"
    preferred_session_length: int = Field(default=50, ge=15, le=180)


class StudyPlanGenerateRequest(BaseModel):
    courses: list[CoursePayload]
    exams: list[ExamPayload]
    assignments: list[AssignmentPayload]
    context: StudyPlanContext


class StudyTask(BaseModel):
    id: str
    title: str
    course_name: str
    type: Literal["study", "assignment", "revision", "collaboration"]
    scheduled_start: str
    scheduled_end: str
    duration_minutes: int
    priority: Literal["high", "medium", "low"]
    completed: bool = False
    rationale: str
    linked_resource_ids: list[str] = Field(default_factory=list)


class StudyDayPlan(BaseModel):
    date: str
    focus_theme: str
    break_strategy: str
    sessions: list[StudyTask]


class RecommendationItem(BaseModel):
    title: str
    reason: str
    urgency: Literal["critical", "high", "medium", "low"]


class StudyPlanResponse(BaseModel):
    id: str | None = None
    headline: str
    weekly_goal: str
    prioritization_summary: list[str]
    revision_intervals: dict[str, list[str]]
    recommendations: list[RecommendationItem]
    daily_plan: list[StudyDayPlan]


class RecalculatePlanRequest(BaseModel):
    courses: list[CoursePayload]
    exams: list[ExamPayload]
    assignments: list[AssignmentPayload]
    context: StudyPlanContext
    missed_task_ids: list[str] = Field(default_factory=list)
    updated_deadlines: list[AssignmentPayload] = Field(default_factory=list)
    reason: str | None = None


class MarkTaskCompleteRequest(BaseModel):
    task_id: str
    completed: bool = True


class StudySessionCreateRequest(BaseModel):
    task_id: str
    title: str
    course_name: str
    planned_minutes: int = Field(gt=0)
    scheduled_start: str


class StudySessionCompleteRequest(BaseModel):
    session_id: str
    actual_minutes: int = Field(ge=0)
    reflection: str | None = None


class StudySessionResponse(BaseModel):
    id: str
    user_id: str
    task_id: str
    title: str
    course_name: str
    planned_minutes: int
    scheduled_start: str
    started_at: str
    actual_minutes: int = 0
    completed: bool = False
    reflection: str | None = None
