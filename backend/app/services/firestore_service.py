from datetime import datetime, timezone
from typing import Any

from google.cloud.firestore import Client, FieldFilter

from app.core.firebase import get_firestore_client


class FirestoreService:
    def __init__(self, client: Client | None = None) -> None:
        self.client = client or get_firestore_client()

    def upsert(self, collection: str, document_id: str, payload: dict[str, Any]) -> dict[str, Any]:
        now = datetime.now(timezone.utc).isoformat()
        ref = self.client.collection(collection).document(document_id)
        snapshot = ref.get()
        existing = snapshot.to_dict() or {}
        merged = {
            **existing,
            **payload,
            "updated_at": now,
            "created_at": existing.get("created_at", now),
        }
        ref.set(merged)
        return {"id": document_id, **merged}

    def create(self, collection: str, payload: dict[str, Any], document_id: str | None = None) -> dict[str, Any]:
        now = datetime.now(timezone.utc).isoformat()
        normalized = {**payload, "created_at": now, "updated_at": now}
        if document_id:
            self.client.collection(collection).document(document_id).set(normalized)
            return {"id": document_id, **normalized}
        ref = self.client.collection(collection).document()
        ref.set(normalized)
        return {"id": ref.id, **normalized}

    def get(self, collection: str, document_id: str) -> dict[str, Any] | None:
        snapshot = self.client.collection(collection).document(document_id).get()
        if not snapshot.exists:
            return None
        return {"id": snapshot.id, **(snapshot.to_dict() or {})}

    def list_for_user(
        self,
        collection: str,
        user_field: str,
        user_id: str,
        limit: int = 50,
        cursor: str | None = None,
    ) -> list[dict[str, Any]]:
        query = (
            self.client.collection(collection)
            .where(filter=FieldFilter(user_field, "==", user_id))
            .order_by("created_at", direction="DESCENDING")
            .limit(limit)
        )
        if cursor:
            cursor_doc = self.client.collection(collection).document(cursor).get()
            if cursor_doc.exists:
                query = query.start_after(cursor_doc)
        docs = query.stream()
        return [{"id": doc.id, **(doc.to_dict() or {})} for doc in docs]

    def update(self, collection: str, document_id: str, payload: dict[str, Any]) -> dict[str, Any]:
        now = datetime.now(timezone.utc).isoformat()
        ref = self.client.collection(collection).document(document_id)
        ref.update({**payload, "updated_at": now})
        return self.get(collection, document_id) or {}

    def delete(self, collection: str, document_id: str) -> None:
        self.client.collection(collection).document(document_id).delete()
