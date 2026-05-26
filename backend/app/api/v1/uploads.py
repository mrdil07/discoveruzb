"""Uploads router — `/api/v1/uploads/`.

Mobile va admin panel'dan rasmlar shu yerga yuklanadi. Backend MinIO'ga
yuklab, public URL qaytaradi. URL'larni keyin postga/galereyaga
saqlaydi.
"""

from __future__ import annotations

from typing import Annotated, Literal

from fastapi import APIRouter, Depends, File, HTTPException, UploadFile, status
from pydantic import BaseModel

from app.api.deps import CurrentUser
from app.core.config import settings
from app.services.storage import StorageService, get_storage

router = APIRouter(prefix="/uploads", tags=["uploads"])

MAX_UPLOAD_SIZE = 10 * 1024 * 1024  # 10 MB


class UploadResponse(BaseModel):
    url: str
    key: str
    size_bytes: int
    content_type: str


async def _read_and_validate(file: UploadFile) -> bytes:
    if file.content_type not in {"image/jpeg", "image/png", "image/webp", "image/heic"}:
        raise HTTPException(
            status_code=status.HTTP_415_UNSUPPORTED_MEDIA_TYPE,
            detail=f"Qo'llab-quvvatlanmaydigan format: {file.content_type}",
        )

    data = await file.read()
    if len(data) > MAX_UPLOAD_SIZE:
        raise HTTPException(
            status_code=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
            detail=f"Maksimal hajm: {MAX_UPLOAD_SIZE // (1024 * 1024)} MB",
        )
    return data


async def _upload(
    file: UploadFile,
    folder: Literal["avatars", "posts", "galleries"],
    storage: StorageService,
    *,
    private: bool = False,
) -> UploadResponse:
    data = await _read_and_validate(file)
    bucket = settings.minio_bucket_private if private else settings.minio_bucket_public
    result = await storage.upload_image(
        data=data,
        content_type=file.content_type or "application/octet-stream",
        folder=folder,
        bucket=bucket,
    )
    return UploadResponse(
        url=result.url,
        key=result.key,
        size_bytes=result.size_bytes,
        content_type=result.content_type,
    )


@router.post(
    "/avatar",
    response_model=UploadResponse,
    summary="Profil rasmini yuklash",
)
async def upload_avatar(
    _user: CurrentUser,
    storage: Annotated[StorageService, Depends(get_storage)],
    file: UploadFile = File(...),
) -> UploadResponse:
    return await _upload(file, "avatars", storage)


@router.post(
    "/post-image",
    response_model=UploadResponse,
    summary="Post rasmini yuklash",
)
async def upload_post_image(
    _user: CurrentUser,
    storage: Annotated[StorageService, Depends(get_storage)],
    file: UploadFile = File(...),
) -> UploadResponse:
    return await _upload(file, "posts", storage)


@router.post(
    "/gallery-image",
    response_model=UploadResponse,
    summary="Galereya rasmini yuklash (private bucket)",
)
async def upload_gallery_image(
    _user: CurrentUser,
    storage: Annotated[StorageService, Depends(get_storage)],
    file: UploadFile = File(...),
) -> UploadResponse:
    return await _upload(file, "galleries", storage, private=True)
