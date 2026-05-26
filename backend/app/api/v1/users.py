"""Users router — `/api/v1/users/`."""

from __future__ import annotations

from typing import Annotated
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import or_, select

from app.api.deps import CurrentAdmin, CurrentUser, DbSession
from app.models.user import User, UserRole
from app.schemas.common import MessageResponse, Page
from app.schemas.user import UserAdmin, UserAdminUpdate, UserMe, UserPublic, UserUpdate
from app.utils.pagination import PageParams, get_page_params, paginate

router = APIRouter(prefix="/users", tags=["users"])


# =====================================================
# Self
# =====================================================


@router.get("/me", response_model=UserMe, summary="Joriy foydalanuvchi profili")
async def get_me(user: CurrentUser) -> UserMe:
    return UserMe.model_validate(user)


@router.patch("/me", response_model=UserMe, summary="O'z profilini yangilash")
async def update_me(
    payload: UserUpdate,
    user: CurrentUser,
    db: DbSession,
) -> UserMe:
    update_data = payload.model_dump(exclude_unset=True)
    if not update_data:
        return UserMe.model_validate(user)

    # Email noyob bo'lishi shart — boshqa user'da ishlatilmagan bo'lsa
    if "email" in update_data and update_data["email"] != user.email:
        new_email = update_data["email"]
        if new_email is not None:
            exists = await db.scalar(
                select(User.id).where(User.email == new_email, User.id != user.id)
            )
            if exists is not None:
                raise HTTPException(
                    status_code=status.HTTP_409_CONFLICT,
                    detail="Bu email boshqa hisobda ishlatilmoqda",
                )

    for field, value in update_data.items():
        setattr(user, field, value)
    await db.commit()
    await db.refresh(user)
    return UserMe.model_validate(user)


@router.post(
    "/me/avatar",
    response_model=UserMe,
    summary="Profil rasmini o'rnatish (URL bilan)",
    description=(
        "Foydalanuvchi avval `POST /uploads/avatar` orqali rasmni MinIO'ga "
        "yuklaydi va qaytgan URL'ni shu yerga yuboradi."
    ),
)
async def set_avatar_url(
    payload: dict[str, str],
    user: CurrentUser,
    db: DbSession,
) -> UserMe:
    img_url = payload.get("img_url")
    if not img_url:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="`img_url` field talab qilinadi",
        )
    user.img_url = img_url
    await db.commit()
    await db.refresh(user)
    return UserMe.model_validate(user)


# =====================================================
# Public profile
# =====================================================


@router.get(
    "/{user_id}",
    response_model=UserPublic,
    summary="Boshqa foydalanuvchining public profili",
)
async def get_user_public(user_id: UUID, db: DbSession) -> UserPublic:
    user = await db.get(User, user_id)
    if user is None:
        raise HTTPException(status_code=404, detail="Foydalanuvchi topilmadi")
    return UserPublic.model_validate(user)


# =====================================================
# Admin endpoints
# =====================================================


@router.get(
    "",
    response_model=Page[UserAdmin],
    summary="(Admin) Foydalanuvchilar ro'yxati",
)
async def list_users(
    _admin: CurrentAdmin,
    db: DbSession,
    params: Annotated[PageParams, Depends(get_page_params)],
    q: Annotated[str | None, Query(description="Search: fullname/phone/email")] = None,
    role: Annotated[UserRole | None, Query()] = None,
    is_banned: Annotated[bool | None, Query()] = None,
) -> Page[UserAdmin]:
    query = select(User).order_by(User.created_at.desc())

    if q:
        like = f"%{q}%"
        query = query.where(
            or_(
                User.fullname.ilike(like),
                User.phone.ilike(like),
                User.email.ilike(like),
            )
        )
    if role is not None:
        query = query.where(User.role == role.value)
    if is_banned is not None:
        query = query.where(User.is_banned == is_banned)

    return await paginate(db, query, params=params, schema=UserAdmin)


@router.get(
    "/admin/{user_id}",
    response_model=UserAdmin,
    summary="(Admin) Foydalanuvchining to'liq profili",
)
async def admin_get_user(
    user_id: UUID,
    _admin: CurrentAdmin,
    db: DbSession,
) -> UserAdmin:
    user = await db.get(User, user_id)
    if user is None:
        raise HTTPException(status_code=404, detail="Foydalanuvchi topilmadi")
    return UserAdmin.model_validate(user)


@router.patch(
    "/admin/{user_id}",
    response_model=UserAdmin,
    summary="(Admin) Rol yoki ban holatini o'zgartirish",
)
async def admin_update_user(
    user_id: UUID,
    payload: UserAdminUpdate,
    admin: CurrentAdmin,
    db: DbSession,
) -> UserAdmin:
    user = await db.get(User, user_id)
    if user is None:
        raise HTTPException(status_code=404, detail="Foydalanuvchi topilmadi")

    # Adminni ban qilish yoki rolini olib tashlash — faqat boshqa admin qila oladi.
    if user.id == admin.id and payload.role is not None and payload.role != UserRole.ADMIN:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="O'z rolingizni o'zgartira olmaysiz",
        )

    if payload.role is not None:
        user.role = payload.role.value
    if payload.is_banned is not None:
        user.is_banned = payload.is_banned

    await db.commit()
    await db.refresh(user)
    return UserAdmin.model_validate(user)


@router.delete(
    "/admin/{user_id}",
    response_model=MessageResponse,
    summary="(Admin) Foydalanuvchini o'chirish (cascade postlar/galereyalar)",
)
async def admin_delete_user(
    user_id: UUID,
    admin: CurrentAdmin,
    db: DbSession,
) -> MessageResponse:
    if user_id == admin.id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="O'z hisobingizni o'chira olmaysiz",
        )

    user = await db.get(User, user_id)
    if user is None:
        raise HTTPException(status_code=404, detail="Foydalanuvchi topilmadi")

    await db.delete(user)
    await db.commit()
    return MessageResponse(message="Foydalanuvchi o'chirildi")
