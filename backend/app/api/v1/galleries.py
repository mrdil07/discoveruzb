"""Galleries router — `/api/v1/galleries/`."""

from __future__ import annotations

import secrets
from uuid import UUID

from fastapi import APIRouter, HTTPException, status
from sqlalchemy import select

from app.api.deps import CurrentUser, DbSession
from app.core.config import settings
from app.models.gallery import Gallery
from app.schemas.common import MessageResponse
from app.schemas.gallery import (
    GalleryAddImages,
    GalleryCreate,
    GalleryRead,
    GalleryShareLink,
    GalleryUpdate,
)

router = APIRouter(prefix="/galleries", tags=["galleries"])


@router.get(
    "/me",
    response_model=list[GalleryRead],
    summary="Joriy user'ning galereyalari",
)
async def list_my_galleries(
    current: CurrentUser,
    db: DbSession,
) -> list[GalleryRead]:
    query = (
        select(Gallery)
        .where(Gallery.owner_id == current.id)
        .order_by(Gallery.created_at.desc())
    )
    galleries = (await db.scalars(query)).all()
    return [GalleryRead.model_validate(g) for g in galleries]


@router.post(
    "",
    response_model=GalleryRead,
    status_code=status.HTTP_201_CREATED,
    summary="Yangi galereya yaratish",
)
async def create_gallery(
    payload: GalleryCreate,
    current: CurrentUser,
    db: DbSession,
) -> GalleryRead:
    gallery = Gallery(owner_id=current.id, **payload.model_dump())
    db.add(gallery)
    await db.commit()
    await db.refresh(gallery)
    return GalleryRead.model_validate(gallery)


@router.get(
    "/{gallery_id}",
    response_model=GalleryRead,
    summary="Galereya tafsilotlari (ega yoki public)",
)
async def get_gallery(
    gallery_id: UUID,
    current: CurrentUser,
    db: DbSession,
) -> GalleryRead:
    gallery = await db.get(Gallery, gallery_id)
    if gallery is None:
        raise HTTPException(status_code=404, detail="Galereya topilmadi")
    if gallery.owner_id != current.id and not gallery.is_public and not current.is_moderator:
        raise HTTPException(status_code=403, detail="Ruxsat yo'q")
    return GalleryRead.model_validate(gallery)


@router.patch(
    "/{gallery_id}",
    response_model=GalleryRead,
    summary="Galereya yangilash (faqat ega)",
)
async def update_gallery(
    gallery_id: UUID,
    payload: GalleryUpdate,
    current: CurrentUser,
    db: DbSession,
) -> GalleryRead:
    gallery = await db.get(Gallery, gallery_id)
    if gallery is None:
        raise HTTPException(status_code=404, detail="Galereya topilmadi")
    if gallery.owner_id != current.id:
        raise HTTPException(status_code=403, detail="Faqat ega yangilashi mumkin")

    for field, value in payload.model_dump(exclude_unset=True).items():
        setattr(gallery, field, value)

    await db.commit()
    await db.refresh(gallery)
    return GalleryRead.model_validate(gallery)


@router.post(
    "/{gallery_id}/images",
    response_model=GalleryRead,
    summary="Galereyaga rasm qo'shish",
)
async def add_images(
    gallery_id: UUID,
    payload: GalleryAddImages,
    current: CurrentUser,
    db: DbSession,
) -> GalleryRead:
    gallery = await db.get(Gallery, gallery_id)
    if gallery is None:
        raise HTTPException(status_code=404, detail="Galereya topilmadi")
    if gallery.owner_id != current.id:
        raise HTTPException(status_code=403, detail="Faqat ega rasm qo'shishi mumkin")

    gallery.images = [*gallery.images, *payload.images]
    await db.commit()
    await db.refresh(gallery)
    return GalleryRead.model_validate(gallery)


@router.delete(
    "/{gallery_id}",
    response_model=MessageResponse,
    summary="Galereyani o'chirish",
)
async def delete_gallery(
    gallery_id: UUID,
    current: CurrentUser,
    db: DbSession,
) -> MessageResponse:
    gallery = await db.get(Gallery, gallery_id)
    if gallery is None:
        raise HTTPException(status_code=404, detail="Galereya topilmadi")
    if gallery.owner_id != current.id and not current.is_moderator:
        raise HTTPException(status_code=403, detail="Ruxsat yo'q")

    await db.delete(gallery)
    await db.commit()
    return MessageResponse(message="Galereya o'chirildi")


@router.post(
    "/{gallery_id}/share-link",
    response_model=GalleryShareLink,
    summary="Public share link yaratish",
)
async def create_share_link(
    gallery_id: UUID,
    current: CurrentUser,
    db: DbSession,
) -> GalleryShareLink:
    gallery = await db.get(Gallery, gallery_id)
    if gallery is None:
        raise HTTPException(status_code=404, detail="Galereya topilmadi")
    if gallery.owner_id != current.id:
        raise HTTPException(status_code=403, detail="Faqat ega yaratishi mumkin")

    if not gallery.share_slug:
        gallery.share_slug = secrets.token_urlsafe(12)
    gallery.is_public = True
    await db.commit()

    base = settings.minio_public_url.rstrip("/")  # vaqtincha — frontend domeniga ko'chiriladi
    return GalleryShareLink(
        slug=gallery.share_slug,
        url=f"{base}/g/{gallery.share_slug}",
    )


@router.get(
    "/share/{slug}",
    response_model=GalleryRead,
    summary="Public share link orqali ochish (auth talab qilmaydi)",
)
async def get_shared_gallery(slug: str, db: DbSession) -> GalleryRead:
    query = select(Gallery).where(
        Gallery.share_slug == slug, Gallery.is_public.is_(True)
    )
    gallery = (await db.scalars(query)).first()
    if gallery is None:
        raise HTTPException(status_code=404, detail="Galereya topilmadi yoki public emas")
    return GalleryRead.model_validate(gallery)
