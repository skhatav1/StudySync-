from app.models.domain import CollectionNames
from app.schemas.resources import ResourceCommentCreate, ResourceMetadataCreate, ResourceMetadataResponse
from app.services.firestore_service import FirestoreService


class ResourceService:
    def __init__(self) -> None:
        self._store: FirestoreService | None = None

    @property
    def store(self) -> FirestoreService:
        if self._store is None:
            self._store = FirestoreService()
        return self._store

    def create_resource(self, uid: str, payload: ResourceMetadataCreate) -> ResourceMetadataResponse:
        stored = self.store.create(CollectionNames.resources, {**payload.model_dump(), "owner_id": uid})
        return ResourceMetadataResponse.model_validate(stored)

    def list_resources(self, uid: str) -> list[ResourceMetadataResponse]:
        resources = self.store.list_for_user(CollectionNames.resources, "owner_id", uid)
        return [ResourceMetadataResponse.model_validate(item) for item in resources]

    def add_comment(self, uid: str, resource_id: str, payload: ResourceCommentCreate) -> dict:
        return self.store.create(
            CollectionNames.comments,
            {"resource_id": resource_id, "author_id": uid, "text": payload.text},
        )

    def list_comments(self, resource_id: str) -> list[dict]:
        comments = self.store.client.collection(CollectionNames.comments).where("resource_id", "==", resource_id).stream()
        return [{"id": doc.id, **(doc.to_dict() or {})} for doc in comments]
