"""Unit tests for PlannerService deterministic plan builder."""
from datetime import date, timedelta

import pytest

from app.schemas.plans import StudyPlanGenerateRequest, StudyPlanContext
from app.schemas.profile import CoursePayload, ExamPayload, AssignmentPayload
from app.services.planner_service import PlannerService


def _make_request(
    courses=None,
    exams=None,
    assignments=None,
    weak_subjects=None,
    study_hours=3.0,
    session_length=50,
) -> StudyPlanGenerateRequest:
    today = date.today()
    courses = courses or [
        CoursePayload(name="Calculus", confidence=4),
        CoursePayload(name="Biology", confidence=7),
    ]
    exams = exams or [
        ExamPayload(
            course_name="Calculus",
            title="Midterm",
            exam_date=(today + timedelta(days=3)).isoformat(),
        )
    ]
    assignments = assignments or [
        AssignmentPayload(
            course_name="Biology",
            title="Lab report",
            due_date=(today + timedelta(days=5)).isoformat(),
            estimated_hours=3,
            priority="medium",
        )
    ]
    return StudyPlanGenerateRequest(
        courses=courses,
        exams=exams,
        assignments=assignments,
        context=StudyPlanContext(
            preferred_study_hours=study_hours,
            preferred_study_times=["18:00", "20:00"],
            weak_subjects=weak_subjects or ["Calculus"],
            learning_style="mixed",
            preferred_session_length=session_length,
        ),
    )


@pytest.fixture
def planner():
    svc = PlannerService()
    # Don't touch Firestore or OpenAI in unit tests.
    svc._store = None
    return svc


def test_plan_has_seven_days(planner):
    plan = planner._build_deterministic_plan(_make_request())
    assert len(plan.daily_plan) == 7


def test_high_confidence_course_deprioritized(planner):
    """Lower-confidence course should appear more in sessions than high-confidence one."""
    plan = planner._build_deterministic_plan(_make_request())
    all_sessions = [s for day in plan.daily_plan for s in day.sessions]
    calculus_count = sum(1 for s in all_sessions if s.course_name == "Calculus")
    biology_count = sum(1 for s in all_sessions if s.course_name == "Biology")
    assert calculus_count >= biology_count


def test_missed_tasks_are_excluded(planner):
    req = _make_request()
    plan_fresh = planner._build_deterministic_plan(req)
    first_task_id = plan_fresh.daily_plan[0].sessions[0].id

    plan_recalc = planner._build_deterministic_plan(req, missed_task_ids={first_task_id})
    all_ids = {s.id for day in plan_recalc.daily_plan for s in day.sessions}
    assert first_task_id not in all_ids


def test_recommendations_not_empty(planner):
    plan = planner._build_deterministic_plan(_make_request())
    assert len(plan.recommendations) > 0


def test_sessions_respect_study_hours(planner):
    """Total session minutes per day should not exceed available hours + buffer."""
    req = _make_request(study_hours=2.0, session_length=30)
    plan = planner._build_deterministic_plan(req)
    for day in plan.daily_plan:
        total = sum(s.duration_minutes for s in day.sessions)
        # Allow for small overrun from rounding; 2h = 120 min, a few 10-min breaks.
        assert total <= 180, f"Day {day.date} exceeds reasonable cap: {total} min"
