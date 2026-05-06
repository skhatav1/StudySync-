from app.models.domain import CollectionNames
from app.schemas.profile import OnboardingPayload, UserProfileCreate, UserProfileResponse, UserProfileUpdate
from app.services.firestore_service import FirestoreService


class ProfileService:
    def __init__(self) -> None:
        self._store: FirestoreService | None = None

    @property
    def store(self) -> FirestoreService:
        if self._store is None:
            self._store = FirestoreService()
        return self._store

    def ensure_profile(self, payload: UserProfileCreate) -> UserProfileResponse:
        existing = self.store.get(CollectionNames.users, payload.uid)
        if existing:
            return UserProfileResponse.model_validate(existing)
        stored = self.store.upsert(CollectionNames.users, payload.uid, payload.model_dump())
        return UserProfileResponse.model_validate(stored)

    def get_profile(self, uid: str) -> UserProfileResponse | None:
        stored = self.store.get(CollectionNames.users, uid)
        return UserProfileResponse.model_validate(stored) if stored else None

    def update_profile(self, uid: str, payload: UserProfileUpdate) -> UserProfileResponse:
        stored = self.store.upsert(CollectionNames.users, uid, payload.model_dump(exclude_none=True))
        return UserProfileResponse.model_validate(stored)

    def save_onboarding(self, uid: str, payload: OnboardingPayload) -> dict:
        self.update_profile(uid, payload.profile)
        for course in payload.courses:
            identifier = course.id or f"{uid}_{course.name.lower().replace(' ', '_')}"
            self.store.upsert(CollectionNames.courses, identifier, {**course.model_dump(), "user_id": uid})
        for exam in payload.exams:
            identifier = exam.id or f"{uid}_{exam.title.lower().replace(' ', '_')}"
            self.store.upsert(CollectionNames.exams, identifier, {**exam.model_dump(), "user_id": uid})
        for assignment in payload.assignments:
            identifier = assignment.id or f"{uid}_{assignment.title.lower().replace(' ', '_')}"
            self.store.upsert(CollectionNames.assignments, identifier, {**assignment.model_dump(), "user_id": uid})
        return {"message": "Onboarding saved successfully."}

    def get_onboarding_data(self, uid: str) -> dict:
        return {
            "courses": self.store.list_for_user(CollectionNames.courses, "user_id", uid),
            "exams": self.store.list_for_user(CollectionNames.exams, "user_id", uid),
            "assignments": self.store.list_for_user(CollectionNames.assignments, "user_id", uid),
        }
