from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from slowapi.errors import RateLimitExceeded

from app.api.routes import ai, analytics, groups, plans, profile, resources
from app.core.config import get_settings
from app.core.limiter import limiter


settings = get_settings()

app = FastAPI(
    title=settings.app_name,
    version="1.0.0",
    summary="AI-powered collaborative study planning backend for StudySync.",
)

app.state.limiter = limiter

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_origin_regex=settings.api_cors_origin_regex,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.exception_handler(RateLimitExceeded)
async def rate_limit_handler(request: Request, exc: RateLimitExceeded) -> JSONResponse:
    return JSONResponse(
        status_code=429,
        content={"detail": "Too many requests. Please wait a moment and try again."},
    )


@app.middleware("http")
async def inject_uid(request: Request, call_next):
    auth = request.headers.get("authorization", "")
    if auth.startswith("Bearer "):
        from firebase_admin import auth as fb_auth
        from app.core.firebase import get_firebase_app
        try:
            get_firebase_app()
            decoded = fb_auth.verify_id_token(auth.split(" ", 1)[1])
            request.state.uid = decoded.get("uid")
        except Exception:  # noqa: BLE001
            request.state.uid = None
    return await call_next(request)


@app.get("/health")
async def health_check() -> dict[str, str]:
    return {"status": "ok", "environment": settings.app_env}


app.include_router(plans.router, prefix="/api/plans", tags=["plans"])
app.include_router(profile.router, prefix="/api/profile", tags=["profile"])
app.include_router(ai.router, prefix="/api/ai", tags=["ai"])
app.include_router(groups.router, prefix="/api/groups", tags=["groups"])
app.include_router(resources.router, prefix="/api/resources", tags=["resources"])
app.include_router(analytics.router, prefix="/api/analytics", tags=["analytics"])
