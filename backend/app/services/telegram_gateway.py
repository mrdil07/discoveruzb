"""Telegram Gateway integratsiyasi.

Hujjat: https://core.telegram.org/gateway/api
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Any

import httpx

from app.core.config import settings
from app.core.logging import get_logger

logger = get_logger(__name__)

GATEWAY_BASE_URL = "https://gateway.telegram.org"


class TelegramGatewayError(Exception):
    """Telegram Gateway 4xx/5xx javoblari uchun."""

    def __init__(self, code: str, message: str) -> None:
        self.code = code
        self.message = message
        super().__init__(f"[{code}] {message}")


@dataclass(slots=True, frozen=True)
class SendOtpResult:
    request_id: str
    delivery_status: str  # "sent" | "delivered" | "read" | "expired" | "revoked"
    is_test: bool


@dataclass(slots=True, frozen=True)
class VerifyOtpResult:
    is_verified: bool
    delivery_status: str | None = None


class TelegramGatewayClient:
    """Telegram Gateway REST API uchun async klient."""

    def __init__(self, token: str | None = None, *, timeout: float = 10.0) -> None:
        self._token = token or settings.telegram_gateway_token
        self._timeout = timeout

    @property
    def is_configured(self) -> bool:
        return bool(self._token)

    async def _post(self, endpoint: str, payload: dict[str, Any]) -> dict[str, Any]:
        if not self._token:
            raise TelegramGatewayError("CONFIG_MISSING", "TELEGRAM_GATEWAY_TOKEN sozlanmagan")

        headers = {
            "Authorization": f"Bearer {self._token}",
            "Content-Type": "application/json",
        }
        url = f"{GATEWAY_BASE_URL}/{endpoint}"
        try:
            async with httpx.AsyncClient(timeout=self._timeout) as client:
                response = await client.post(url, json=payload, headers=headers)
        except httpx.HTTPError as e:
            logger.error("Telegram Gateway network error: %s", e)
            raise TelegramGatewayError("NETWORK", str(e)) from e

        try:
            data: dict[str, Any] = response.json()
        except ValueError as e:
            raise TelegramGatewayError("INVALID_JSON", response.text[:200]) from e

        if not data.get("ok"):
            error_code = str(data.get("error", "UNKNOWN"))
            logger.warning("Telegram Gateway error: %s", error_code)
            raise TelegramGatewayError(error_code, data.get("description", ""))

        return data.get("result", {})

    async def send_verification_message(
        self,
        phone_number: str,
        *,
        code: str | None = None,
        code_length: int | None = None,
        ttl: int | None = None,
        sender_username: str | None = None,
    ) -> SendOtpResult:
        """OTP yuboradi.

        - `code` ni o'zimiz yuboramiz (DB'da xeshlangan), Telegram shu kodni
          jo'natadi.
        - Yoki `code_length` ko'rsatamiz, Telegram o'zi generatsiya qilib,
          `delivery_status` orqali tekshiriladi (bu rejim
          `checkVerificationStatus` va `code` parametri bilan ishlaydi).
        """
        payload: dict[str, Any] = {"phone_number": phone_number}
        if code is not None:
            payload["code"] = code
        if code_length is not None:
            payload["code_length"] = code_length
        if ttl is not None:
            payload["ttl"] = ttl
        if sender_username is not None:
            payload["sender_username"] = sender_username

        result = await self._post("sendVerificationMessage", payload)
        delivery = result.get("delivery_status") or {}
        return SendOtpResult(
            request_id=result["request_id"],
            delivery_status=delivery.get("status", "sent"),
            is_test=bool(result.get("is_refunded", False)),
        )

    async def check_verification_status(
        self,
        request_id: str,
        *,
        code: str | None = None,
    ) -> VerifyOtpResult:
        """OTP statusini tekshiradi (yoki Telegram-generatsiya qilingan kodni)."""
        payload: dict[str, Any] = {"request_id": request_id}
        if code is not None:
            payload["code"] = code

        result = await self._post("checkVerificationStatus", payload)
        verification_status = result.get("verification_status", {})
        status_value = verification_status.get("status")
        is_verified = status_value == "code_valid"
        return VerifyOtpResult(is_verified=is_verified, delivery_status=status_value)

    async def revoke_verification_message(self, request_id: str) -> bool:
        """Foydalanuvchi yangi OTP so'raganda eskini bekor qilish."""
        try:
            await self._post("revokeVerificationMessage", {"request_id": request_id})
        except TelegramGatewayError as e:
            logger.warning("revokeVerificationMessage failed: %s", e)
            return False
        return True


def get_telegram_gateway() -> TelegramGatewayClient:
    """FastAPI dependency factory."""
    return TelegramGatewayClient()
