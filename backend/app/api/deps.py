"""FastAPI dependencies — auth, role-based access control."""

from __future__ import annotations

from typing import Annotated
from uuid import UUID

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from jose import JWTError
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.security import decode_access_token
from app.db.session import get_db
from app.models.user import User, UserRole

security = HTTPBearer(auto_error=False)


async def get_current_user_optional(
    credentials: Annotated[HTTPAuthorizationCredentials | None, Depends(security)],
    db: Annotated[AsyncSession, Depends(get_db)],
) -> User | None:
    """Tokenni dekod qiladi, foydalanuvchini qaytaradi. Token bo'lmasa None."""
    if credentials is None:
        return None
    try:
        payload = decode_access_token(credentials.credentials)
    except JWTError:
        return None
    user_id_str = payload.get("sub")
    if not user_id_str:
        return None
    try:
        user_id = UUID(user_id_str)
    except ValueError:
        return None
    user = await db.get(User, user_id)
    if user is None or user.is_banned:
        return None
    return user


async def get_current_user(
    user: Annotated[User | None, Depends(get_current_user_optional)],
) -> User:
    """Authenticated foydalanuvchi. 401 agar yo'q."""
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authentifikatsiya talab qilinadi",
            headers={"WWW-Authenticate": "Bearer"},
        )
    return user


def require_role(*allowed: UserRole):
    """Role-based dependency: faqat ko'rsatilgan rollarga ruxsat."""

    allowed_set = {r.value for r in allowed}

    async def _checker(user: Annotated[User, Depends(get_current_user)]) -> User:
        if user.role not in allowed_set:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Bu amalni bajarish uchun ruxsat yo'q",
            )
        return user

    return _checker


# Sintaktik shortcut'lar
require_admin = require_role(UserRole.ADMIN)
require_moderator = require_role(UserRole.MODERATOR, UserRole.ADMIN)


# Type aliaslar — kod o'qish uchun qulay
DbSession = Annotated[AsyncSession, Depends(get_db)]
CurrentUser = Annotated[User, Depends(get_current_user)]
CurrentUserOptional = Annotated[User | None, Depends(get_current_user_optional)]
CurrentAdmin = Annotated[User, Depends(require_admin)]
CurrentModerator = Annotated[User, Depends(require_moderator)]
