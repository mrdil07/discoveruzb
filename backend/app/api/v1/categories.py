"""Categories router — `/api/v1/categories/`."""

from __future__ import annotations

from fastapi import APIRouter, HTTPException, Query, status
from typing import Annotated

from sqlalchemy import select

from app.api.deps import CurrentAdmin, DbSession
from app.models.category import Category
from app.schemas.category import CategoryCreate, CategoryRead, CategoryUpdate
from app.schemas.common import MessageResponse

router = APIRouter(prefix="/categories", tags=["categories"])


@router.get(
    "",
    response_model=list[CategoryRead],
    summary="Kategoriyalar ro'yxati (public)",
)
async def list_categories(
    db: DbSession,
    only_active: Annotated[bool, Query()] = True,
) -> list[CategoryRead]:
    query = select(Category).order_by(Category.sort_order, Category.slug)
    if only_active:
        query = query.where(Category.is_active.is_(True))
    return [CategoryRead.model_validate(c) for c in (await db.scalars(query)).all()]


@router.post(
    "",
    response_model=CategoryRead,
    status_code=status.HTTP_201_CREATED,
    summary="(Admin) Yangi kategoriya yaratish",
)
async def create_category(
    payload: CategoryCreate,
    _admin: CurrentAdmin,
    db: DbSession,
) -> CategoryRead:
    exists = await db.get(Category, payload.slug)
    if exists is not None:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail=f"`{payload.slug}` slug allaqachon mavjud",
        )
    category = Category(**payload.model_dump())
    db.add(category)
    await db.commit()
    await db.refresh(category)
    return CategoryRead.model_validate(category)


@router.patch(
    "/{slug}",
    response_model=CategoryRead,
    summary="(Admin) Kategoriya yangilash",
)
async def update_category(
    slug: str,
    payload: CategoryUpdate,
    _admin: CurrentAdmin,
    db: DbSession,
) -> CategoryRead:
    category = await db.get(Category, slug)
    if category is None:
        raise HTTPException(status_code=404, detail="Kategoriya topilmadi")

    for field, value in payload.model_dump(exclude_unset=True).items():
        setattr(category, field, value)

    await db.commit()
    await db.refresh(category)
    return CategoryRead.model_validate(category)


@router.delete(
    "/{slug}",
    response_model=MessageResponse,
    summary="(Admin) Kategoriya o'chirish",
)
async def delete_category(
    slug: str,
    _admin: CurrentAdmin,
    db: DbSession,
) -> MessageResponse:
    category = await db.get(Category, slug)
    if category is None:
        raise HTTPException(status_code=404, detail="Kategoriya topilmadi")
    await db.delete(category)
    await db.commit()
    return MessageResponse(message="Kategoriya o'chirildi")
