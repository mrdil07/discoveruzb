"""Strukturalashgan logging konfiguratsiya."""

from __future__ import annotations

import logging
import sys

from app.core.config import settings


def configure_logging() -> None:
    """Application boshlanishida bir marta chaqiriladi."""
    level = logging.DEBUG if settings.debug else logging.INFO

    formatter = logging.Formatter(
        fmt="%(asctime)s | %(levelname)-7s | %(name)s | %(message)s",
        datefmt="%Y-%m-%d %H:%M:%S",
    )

    handler = logging.StreamHandler(sys.stdout)
    handler.setFormatter(formatter)

    root = logging.getLogger()
    root.setLevel(level)
    # uvicorn / gunicorn handler'larini olib tashlash (dublikat log'lar)
    root.handlers.clear()
    root.addHandler(handler)

    # 3rd party log'larni jimroq qilish
    for noisy in ("httpx", "httpcore", "asyncio", "passlib"):
        logging.getLogger(noisy).setLevel(logging.WARNING)


def get_logger(name: str) -> logging.Logger:
    return logging.getLogger(name)
