from typing import Literal

from pydantic import BaseModel, Field


LearningStyle = Literal["visual", "practice", "reading", "audio", "mixed"]


class UserProfileBase(BaseModel):
    name: str = Field(min_length=2, max_length=80)
    email: str = Field(pattern=r".+@.+\..+")
    academic_goals: list[str] = Field(default_factory=list)
    preferred_study_hours: float = Field(gt=0, le=12, default=3)
    learning_style: LearningStyle = "mixed"
    weak_subjects: list[str] = Field(default_factory=list)
    preferred_session_length: int = Field(default=50, ge=15, le=180)
    preferred_study_times: list[str] = Field(default_factory=list)
    target_grades: dict[str, str] = Field(default_factory=dict)
    collaboration_preferences: list[str] = Field(default_factory=list)


class UserProfileCreate(UserProfileBase):
    uid: str


class UserProfileUpdate(BaseModel):
    name: str | None = Field(default=None, min_length=2, max_length=80)
    academic_goals: list[str] | None = None
    preferred_study_hours: float | None = Field(default=None, gt=0, le=12)
    learning_style: LearningStyle | None = None
    weak_subjects: list[str] | None = None
    preferred_session_length: int | None = Field(default=None, ge=15, le=180)
    preferred_study_times: list[str] | None = None
    target_grades: dict[str, str] | None = None
    collaboration_preferences: list[str] | None = None


class CoursePayload(BaseModel):
    id: str | None = None
    name: str
    current_grade: str | None = None
    confidence: int = Field(ge=1, le=10, default=5)


class ExamPayload(BaseModel):
    id: str | None = None
    course_name: str
    title: str
    exam_date: str
    target_score: str | None = None


class AssignmentPayload(BaseModel):
    id: str | None = None
    course_name: str
    title: str
    due_date: str
    estimated_hours: float = Field(gt=0)
    priority: Literal["high", "medium", "low"] = "medium"


class OnboardingPayload(BaseModel):
    profile: UserProfileUpdate
    courses: list[CoursePayload] = Field(default_factory=list)
    exams: list[ExamPayload] = Field(default_factory=list)
    assignments: list[AssignmentPayload] = Field(default_factory=list)


class UserProfileResponse(UserProfileBase):
    uid: str
