from typing import Any

from fastapi import Header, HTTPException, status
from firebase_admin import auth

from app.core.firebase import get_firebase_app


async def get_current_user(authorization: str | None = Header(default=None)) -> dict[str, Any]:
    get_firebase_app()

    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Missing bearer token.")

    token = authorization.replace("Bearer ", "", 1).strip()

    try:
        decoded = auth.verify_id_token(token)
    except Exception as exc:  # noqa: BLE001
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid auth token.") from exc

    return decoded
