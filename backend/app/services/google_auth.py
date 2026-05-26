"""Google Sign-In ID token verifikatsiyasi (Firebase'siz)."""

from __future__ import annotations

from dataclasses import dataclass

from google.auth.transport import requests as google_requests
from google.oauth2 import id_token as google_id_token

from app.core.config import settings
from app.core.logging import get_logger

logger = get_logger(__name__)


class GoogleAuthError(Exception):
    pass


@dataclass(slots=True, frozen=True)
class GoogleUserInfo:
    """Google'dan kelgan tasdiqlangan foydalanuvchi ma'lumoti."""

    sub: str            # Google user ID (stable, primary key)
    email: str
    email_verified: bool
    name: str
    picture: str | None
    locale: str | None


def verify_google_id_token(token: str) -> GoogleUserInfo:
    """Google ID tokenni tekshiradi va `GoogleUserInfo` qaytaradi.

    Yaroqsiz/eskirgan/noto'g'ri audience bo'lsa `GoogleAuthError` tashlaydi.
    """
    audiences = settings.google_audience
    if not audiences:
        raise GoogleAuthError("GOOGLE_CLIENT_ID_* sozlanmagan")

    request = google_requests.Request()
    last_error: Exception | None = None
    for audience in audiences:
        try:
            payload = google_id_token.verify_oauth2_token(token, request, audience)
            break
        except ValueError as e:
            last_error = e
            continue
    else:
        logger.warning("Google ID token verify failed: %s", last_error)
        raise GoogleAuthError("Google tokeni yaroqli emas") from last_error

    if payload.get("iss") not in ("accounts.google.com", "https://accounts.google.com"):
        raise GoogleAuthError("Token issuer noto'g'ri")

    if not payload.get("email_verified"):
        raise GoogleAuthError("Email tasdiqlanmagan")

    return GoogleUserInfo(
        sub=payload["sub"],
        email=payload["email"],
        email_verified=bool(payload.get("email_verified")),
        name=payload.get("name") or payload["email"],
        picture=payload.get("picture"),
        locale=payload.get("locale"),
    )
