# syntax=docker/dockerfile:1.7
FROM python:3.12-slim AS base

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# uv (tezroq paket o'rnatuvchi)
RUN pip install --no-cache-dir uv==0.5.11

WORKDIR /app

# Bog'liqliklarni avval o'rnatish (cache qatlami)
COPY pyproject.toml ./
RUN uv pip install --system --no-cache -r pyproject.toml

# Kod
COPY app ./app
COPY alembic ./alembic
COPY alembic.ini ./alembic.ini

# Non-root user
RUN useradd -m -u 1000 appuser && chown -R appuser:appuser /app
USER appuser

EXPOSE 8000

CMD ["gunicorn", "app.main:app", \
     "--worker-class", "uvicorn.workers.UvicornWorker", \
     "--workers", "4", \
     "--bind", "0.0.0.0:8000", \
     "--access-logfile", "-", \
     "--error-logfile", "-"]
