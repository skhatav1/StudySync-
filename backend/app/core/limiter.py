from slowapi import Limiter
from slowapi.util import get_remote_address

# Keyed by the Firebase UID header when present, falls back to IP.
def _get_uid_or_ip(request) -> str:  # type: ignore[no-untyped-def]
    uid = getattr(request.state, "uid", None)
    return uid or get_remote_address(request)


limiter = Limiter(key_func=_get_uid_or_ip)
