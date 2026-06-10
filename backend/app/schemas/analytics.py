from pydantic import BaseModel, Field


class AnalyticsSummaryResponse(BaseModel):
    streak_days: int
    hours_studied: float
    tasks_completed: int
    completion_rate: float
    weak_subjects: list[str] = Field(default_factory=list)
    upcoming_deadlines: list[str] = Field(default_factory=list)
    productivity_score: int
    ai_insights: list[str] = Field(default_factory=list)
    weekly_hours: list[float] = Field(default_factory=lambda: [0.0] * 7)
