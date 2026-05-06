from functools import lru_cache
from pathlib import Path

import firebase_admin
from firebase_admin import credentials, firestore

from app.core.config import get_settings


@lru_cache
def get_firebase_app():
    settings = get_settings()
    if firebase_admin._apps:
      return firebase_admin.get_app()

    if settings.firebase_credentials_path:
        cred = credentials.Certificate(Path(settings.firebase_credentials_path).expanduser())
        return firebase_admin.initialize_app(
            cred,
            {
                "projectId": settings.firebase_project_id,
                "storageBucket": settings.firebase_storage_bucket,
            },
        )

    return firebase_admin.initialize_app(
        options={
            "projectId": settings.firebase_project_id,
            "storageBucket": settings.firebase_storage_bucket,
        }
    )


@lru_cache
def get_firestore_client():
    get_firebase_app()
    return firestore.client()
