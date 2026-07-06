"""FastAPI application entry point."""

from __future__ import annotations

from collections.abc import AsyncGenerator
from contextlib import asynccontextmanager

from fastapi import FastAPI, Request, status
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from sqlalchemy.exc import IntegrityError

from app import __version__
from app.api.v1 import (
    auth as auth_router,
    categories as categories_router,
    comments as comments_router,
    external_reviews as external_reviews_router,
    galleries as galleries_router,
    posts as posts_router,
    stats as stats_router,
    uploads as uploads_router,
    users as users_router,
    weather as weather_router,
)
from app.core.config import settings
from app.core.logging import configure_logging, get_logger
from app.services.storage import get_storage

configure_logging()
logger = get_logger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI) -> AsyncGenerator[None, None]:
    logger.info("Starting %s v%s in %s mode", settings.app_name, __version__, settings.app_env)

    # MinIO bucket'larni init qilish
    try:
        get_storage().ensure_buckets()
        logger.info("MinIO buckets ready")
    except Exception as e:
        logger.warning("MinIO init skipped: %s", e)

    yield
    logger.info("Shutting down")


def create_app() -> FastAPI:
    app = FastAPI(
        title=settings.app_name,
        version=__version__,
        docs_url="/docs" if not settings.is_production else None,
        redoc_url="/redoc" if not settings.is_production else None,
        openapi_url="/openapi.json",
        lifespan=lifespan,
    )

    # CORS — admin panel va lokal dev
    if settings.cors_origins_list:
        app.add_middleware(
            CORSMiddleware,
            allow_origins=settings.cors_origins_list,
            allow_credentials=True,
            allow_methods=["*"],
            allow_headers=["*"],
        )

    # ===== Global exception handlers =====

    @app.exception_handler(IntegrityError)
    async def integrity_error_handler(_: Request, exc: IntegrityError) -> JSONResponse:
        # Foydalanuvchiga raw SQL chiqarmaymiz
        logger.warning("DB IntegrityError: %s", exc.orig)
        return JSONResponse(
            status_code=status.HTTP_409_CONFLICT,
            content={
                "detail": "Bu ma'lumot mavjud (unique violation)",
                "code": "INTEGRITY_ERROR",
            },
        )

    @app.exception_handler(RequestValidationError)
    async def validation_error_handler(
        _: Request, exc: RequestValidationError
    ) -> JSONResponse:
        # Sodda 422 javobi
        fields: dict[str, str] = {}
        for err in exc.errors():
            loc = ".".join(str(x) for x in err["loc"][1:])  # skip "body"/"query"
            fields[loc] = err["msg"]
        return JSONResponse(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            content={
                "detail": "Validation xatoligi",
                "code": "VALIDATION_ERROR",
                "fields": fields,
            },
        )

    # ===== Routers =====

    api_v1_routers = [
        auth_router.router,
        users_router.router,
        posts_router.router,
        external_reviews_router.router,
        comments_router.router,
        galleries_router.router,
        categories_router.router,
        stats_router.router,
        uploads_router.router,
        weather_router.router,
    ]
    for r in api_v1_routers:
        app.include_router(r, prefix="/api/v1")

    # ===== Meta =====

    @app.get("/health", tags=["meta"])
    async def health() -> dict[str, str]:
        return {"status": "ok", "version": __version__}

    @app.get("/", tags=["meta"])
    async def root() -> dict[str, str]:
        return {
            "name": settings.app_name,
            "version": __version__,
            "docs": "/docs" if not settings.is_production else "disabled",
        }

    return app


app = create_app()
