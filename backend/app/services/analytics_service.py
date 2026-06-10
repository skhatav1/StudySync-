from collections import Counter
from datetime import datetime, timezone

from app.models.domain import CollectionNames
from app.schemas.analytics import AnalyticsSummaryResponse
from app.services.firestore_service import FirestoreService
from app.services.planner_service import PlannerService
from app.services.profile_service import ProfileService


class AnalyticsService:
    def __init__(self) -> None:
        self._store: FirestoreService | None = None
        self.planner = PlannerService()
        self.profile_service = ProfileService()

    @property
    def store(self) -> FirestoreService:
        if self._store is None:
            self._store = FirestoreService()
        return self._store

    def summary(self, uid: str) -> AnalyticsSummaryResponse:
        profile = self.profile_service.get_profile(uid)
        sessions = self.store.list_for_user(CollectionNames.study_sessions, "user_id", uid)
        assignments = self.store.list_for_user(CollectionNames.assignments, "user_id", uid)
        plan = self.planner.get_active_plan(uid)

        tasks_completed = sum(1 for session in sessions if session.get("completed"))
        total_tasks = len(sessions) or sum(len(day.sessions) for day in plan.daily_plan) if plan else 0
        completion_rate = round((tasks_completed / total_tasks) * 100, 1) if total_tasks else 0.0
        upcoming = sorted(
            [f"{item.get('title')} • {item.get('due_date')}" for item in assignments if item.get("due_date")],
            key=lambda item: item,
        )[:5]
        hours = round(sum(float(session.get("actual_minutes", 0)) for session in sessions) / 60, 1)
        productivity = min(98, int(completion_rate * 0.7 + min(hours * 4, 30)))
        recent_courses = Counter(session.get("course_name", "") for session in sessions if session.get("course_name"))
        top_course = recent_courses.most_common(1)[0][0] if recent_courses else "your highest-priority subject"

        # Build per-weekday hours array (Mon=0 … Sun=6) for the current week.
        today = datetime.now(timezone.utc).date()
        week_start = today.toordinal() - today.weekday()
        weekly_hours = [0.0] * 7
        for session in sessions:
            started = session.get("started_at", "")
            if not started:
                continue
            try:
                day_ord = datetime.fromisoformat(started).date().toordinal()
                day_index = day_ord - week_start
                if 0 <= day_index < 7:
                    weekly_hours[day_index] += float(session.get("actual_minutes", 0)) / 60
            except ValueError:
                pass
        weekly_hours = [round(h, 2) for h in weekly_hours]

        return AnalyticsSummaryResponse(
            streak_days=max(1, tasks_completed),
            hours_studied=hours,
            tasks_completed=tasks_completed,
            completion_rate=completion_rate,
            weak_subjects=profile.weak_subjects if profile else [],
            upcoming_deadlines=upcoming,
            productivity_score=productivity,
            weekly_hours=weekly_hours,
            ai_insights=[
                f"You are spending the most logged time on {top_course}.",
                "Shorter active recall blocks work best when your schedule tightens.",
                "Completed sessions now feed directly into your analytics and productivity score.",
                f"Last refreshed at {datetime.now(timezone.utc).isoformat()} UTC.",
            ],
        )
