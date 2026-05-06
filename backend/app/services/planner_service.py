from datetime import date, datetime, timedelta

from app.models.domain import CollectionNames
from app.schemas.plans import (
    MarkTaskCompleteRequest,
    RecalculatePlanRequest,
    RecommendationItem,
    StudyDayPlan,
    StudySessionCompleteRequest,
    StudySessionCreateRequest,
    StudySessionResponse,
    StudyPlanGenerateRequest,
    StudyPlanResponse,
    StudyTask,
)
from app.services.firestore_service import FirestoreService
from app.services.openai_service import OpenAIService


class PlannerService:
    def __init__(self) -> None:
        self._store: FirestoreService | None = None
        self.openai = OpenAIService()

    @property
    def store(self) -> FirestoreService:
        if self._store is None:
            self._store = FirestoreService()
        return self._store

    def generate_plan(self, uid: str, payload: StudyPlanGenerateRequest) -> StudyPlanResponse:
        deterministic_plan = self._build_deterministic_plan(payload)
        ai_enhanced = self._enrich_plan(payload, deterministic_plan)
        stored = self.store.create(
            CollectionNames.study_plans,
            {"user_id": uid, **ai_enhanced.model_dump()},
        )
        return StudyPlanResponse.model_validate(stored)

    def get_active_plan(self, uid: str) -> StudyPlanResponse | None:
        plans = self.store.list_for_user(CollectionNames.study_plans, "user_id", uid)
        if not plans:
            return None
        plans.sort(key=lambda item: item.get("updated_at", ""), reverse=True)
        return StudyPlanResponse.model_validate(plans[0])

    def recalculate_plan(self, uid: str, payload: RecalculatePlanRequest) -> StudyPlanResponse:
        base = self._build_deterministic_plan(
            StudyPlanGenerateRequest(
                courses=payload.courses,
                exams=payload.exams,
                assignments=payload.assignments,
                context=payload.context,
            )
        )
        base.headline = "Plan recalculated after schedule changes and missed work."
        base.prioritization_summary.insert(0, payload.reason or "Workload redistributed to stay realistic.")
        stored = self.store.create(CollectionNames.study_plans, {"user_id": uid, **base.model_dump()})
        return StudyPlanResponse.model_validate(stored)

    def mark_task_complete(self, uid: str, request: MarkTaskCompleteRequest) -> dict:
        plan = self.get_active_plan(uid)
        if not plan:
            raise ValueError("No study plan found.")
        for day in plan.daily_plan:
            for task in day.sessions:
                if task.id == request.task_id:
                    task.completed = request.completed
        updated = self.store.upsert(
            CollectionNames.study_plans,
            plan.id or request.task_id,
            {"user_id": uid, **plan.model_dump()},
        )
        return updated

    def recommendations(self, uid: str) -> list[RecommendationItem]:
        plan = self.get_active_plan(uid)
        if plan:
            return plan.recommendations
        return [
            RecommendationItem(
                title="Generate your first plan",
                reason="StudySync needs your deadlines and available hours to prioritize work.",
                urgency="medium",
            )
        ]

    def start_session(self, uid: str, request: StudySessionCreateRequest) -> StudySessionResponse:
        started_at = datetime.utcnow().isoformat()
        stored = self.store.create(
            CollectionNames.study_sessions,
            {
                "user_id": uid,
                "task_id": request.task_id,
                "title": request.title,
                "course_name": request.course_name,
                "planned_minutes": request.planned_minutes,
                "scheduled_start": request.scheduled_start,
                "started_at": started_at,
                "actual_minutes": 0,
                "completed": False,
                "reflection": None,
            },
        )
        return StudySessionResponse.model_validate(stored)

    def complete_session(self, uid: str, request: StudySessionCompleteRequest) -> StudySessionResponse:
        session = self.store.get(CollectionNames.study_sessions, request.session_id)
        if not session or session.get("user_id") != uid:
            raise ValueError("Study session not found.")
        updated = self.store.update(
            CollectionNames.study_sessions,
            request.session_id,
            {
                "actual_minutes": request.actual_minutes,
                "completed": True,
                "reflection": request.reflection,
            },
        )
        return StudySessionResponse.model_validate(updated)

    def list_sessions(self, uid: str) -> list[StudySessionResponse]:
        sessions = self.store.list_for_user(CollectionNames.study_sessions, "user_id", uid)
        sessions.sort(key=lambda item: item.get("started_at", ""), reverse=True)
        return [StudySessionResponse.model_validate(item) for item in sessions]

    def _build_deterministic_plan(self, payload: StudyPlanGenerateRequest) -> StudyPlanResponse:
        today = datetime.utcnow().date()
        study_minutes = int(payload.context.preferred_study_hours * 60)
        subject_scores: list[tuple[str, int, str]] = []

        for course in payload.courses:
            score = (11 - course.confidence) * 10
            reason = "low confidence"
            for exam in payload.exams:
                if exam.course_name == course.name:
                    days_left = max((date.fromisoformat(exam.exam_date) - today).days, 1)
                    score += max(20, 100 - days_left * 8)
                    reason = f"{exam.title} is approaching"
            for assignment in payload.assignments:
                if assignment.course_name == course.name:
                    days_left = max((date.fromisoformat(assignment.due_date) - today).days, 1)
                    score += int(assignment.estimated_hours * 7) + max(10, 70 - days_left * 8)
                    reason = f"{assignment.title} is due soon"
            if course.name in payload.context.weak_subjects:
                score += 25
                reason = "weak subject with upcoming pressure"
            subject_scores.append((course.name, score, reason))

        subject_scores.sort(key=lambda item: item[1], reverse=True)
        priorities = [f"{name}: {reason}" for name, _, reason in subject_scores[:4]]

        daily_plan: list[StudyDayPlan] = []
        revision_intervals: dict[str, list[str]] = {}
        recommendations: list[RecommendationItem] = []

        for day_offset in range(7):
            date_value = today + timedelta(days=day_offset)
            remaining = study_minutes
            sessions: list[StudyTask] = []
            for index, (course_name, score, reason) in enumerate(subject_scores[:3]):
                duration = min(payload.context.preferred_session_length, max(25, remaining // max(1, 3 - index)))
                if remaining < 20:
                    break
                start_label = payload.context.preferred_study_times[index % len(payload.context.preferred_study_times)] if payload.context.preferred_study_times else f"{18 + index}:00"
                end_dt = datetime.combine(date_value, datetime.strptime(start_label, "%H:%M").time()) + timedelta(minutes=duration)
                task = StudyTask(
                    id=f"{date_value.isoformat()}_{course_name.lower().replace(' ', '_')}_{index}",
                    title=f"{course_name} focus block",
                    course_name=course_name,
                    type="study",
                    scheduled_start=f"{date_value.isoformat()}T{start_label}:00",
                    scheduled_end=end_dt.isoformat(),
                    duration_minutes=duration,
                    priority="high" if score > 120 else "medium",
                    rationale=f"Scheduled because {reason}.",
                    linked_resource_ids=[],
                )
                sessions.append(task)
                remaining -= duration + 10
                revision_intervals.setdefault(course_name, []).append((date_value + timedelta(days=2)).isoformat())

            daily_plan.append(
                StudyDayPlan(
                    date=date_value.isoformat(),
                    focus_theme="High urgency + weak-area stabilization" if day_offset < 2 else "Balanced revision and assignment progress",
                    break_strategy="50/10 focus cycles with one longer 20-minute reset after two blocks.",
                    sessions=sessions,
                )
            )

        for course_name, _, reason in subject_scores[:3]:
            recommendations.append(
                RecommendationItem(
                    title=f"Prioritize {course_name}",
                    reason=f"Focus here next because {reason}.",
                    urgency="critical" if "approaching" in reason or "due" in reason else "high",
                )
            )

        return StudyPlanResponse(
            headline="Adaptive weekly study plan generated from deadlines, confidence, and available time.",
            weekly_goal="Finish urgent assignments, protect weak subjects, and avoid burnout with shorter high-value sessions.",
            prioritization_summary=priorities,
            revision_intervals=revision_intervals,
            recommendations=recommendations,
            daily_plan=daily_plan,
        )

    def _enrich_plan(self, payload: StudyPlanGenerateRequest, plan: StudyPlanResponse) -> StudyPlanResponse:
        if not self.openai.client:
            return plan
        prompt = OpenAIService.to_json_prompt(
            StudyPlanResponse,
            "Improve the tone, rationale, and recommendation quality of this study plan without changing the structure.",
        )
        user_prompt = (
            f"Student context:\n{payload.model_dump_json(indent=2)}\n\n"
            f"Current plan:\n{plan.model_dump_json(indent=2)}"
        )
        try:
            enhanced = self.openai.generate_structured(system_prompt=prompt, user_prompt=user_prompt, schema=StudyPlanResponse)
            enhanced.id = None
            return enhanced
        except Exception:  # noqa: BLE001
            return plan
