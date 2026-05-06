from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.routes import ai, analytics, groups, plans, profile, resources
from app.core.config import get_settings


settings = get_settings()

app = FastAPI(
    title=settings.app_name,
    version="1.0.0",
    summary="AI-powered collaborative study planning backend for StudySync.",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_origin_regex=settings.api_cors_origin_regex,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/health")
async def health_check() -> dict[str, str]:
    return {"status": "ok", "environment": settings.app_env}


app.include_router(plans.router, prefix="/api/plans", tags=["plans"])
app.include_router(profile.router, prefix="/api/profile", tags=["profile"])
app.include_router(ai.router, prefix="/api/ai", tags=["ai"])
app.include_router(groups.router, prefix="/api/groups", tags=["groups"])
app.include_router(resources.router, prefix="/api/resources", tags=["resources"])
app.include_router(analytics.router, prefix="/api/analytics", tags=["analytics"])
