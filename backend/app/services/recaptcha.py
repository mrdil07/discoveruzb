"""Google reCAPTCHA v3 verification service.

Hujjat: https://developers.google.com/recaptcha/docs/v3

reCAPTCHA v3 — invisible, score-based (0.0 - bot, 1.0 - inson).
Admin login uchun ishlatamiz: token client tomonida olinadi va shu yerda
backend Google'ga POST qilib tekshiradi.

Dev test kalitlar (har doim success=true, score=0.9 qaytaradi):
    site:   6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI
    secret: 6LeIxAcTAAAAAGG-vFI1TnRWxMZNFuojJ4WifJWe
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import Any

import httpx

from app.core.config import settings
from app.core.logging import get_logger

logger = get_logger(__name__)

RECAPTCHA_VERIFY_URL = "https://www.google.com/recaptcha/api/siteverify"


class RecaptchaError(Exception):
    """reCAPTCHA validation failure."""

    def __init__(self, reason: str, *, details: dict[str, Any] | None = None) -> None:
        self.reason = reason
        self.details = details or {}
        super().__init__(reason)


@dataclass(slots=True, frozen=True)
class RecaptchaResult:
    success: bool
    score: float
    action: str | None
    hostname: str | None
    challenge_ts: str | None


class RecaptchaVerifier:
    """Google reCAPTCHA v3 async klient."""

    def __init__(
        self,
        secret_key: str | None = None,
        *,
        min_score: float | None = None,
        timeout: float = 5.0,
    ) -> None:
        self._secret = secret_key if secret_key is not None else settings.recaptcha_secret_key
        self._min_score = (
            min_score if min_score is not None else settings.recaptcha_min_score
        )
        self._timeout = timeout

    @property
    def is_configured(self) -> bool:
        return bool(self._secret)

    async def verify(
        self,
        token: str,
        *,
        remote_ip: str | None = None,
        expected_action: str | None = None,
    ) -> RecaptchaResult:
        """Tokenni Google'da tekshiradi.

        Sozlanmagan bo'lsa (dev mode, `recaptcha_secret_key=""`) — har doim
        muvaffaqiyatli qaytaradi. Productionda secret bo'lishi shart.
        """
        if not self._secret:
            logger.warning(
                "reCAPTCHA secret sozlanmagan — verification skip qilinmoqda "
                "(dev mode only)"
            )
            return RecaptchaResult(
                success=True,
                score=1.0,
                action=expected_action,
                hostname=None,
                challenge_ts=None,
            )

        if not token:
            raise RecaptchaError("missing-token")

        data: dict[str, str] = {"secret": self._secret, "response": token}
        if remote_ip:
            data["remoteip"] = remote_ip

        try:
            async with httpx.AsyncClient(timeout=self._timeout) as client:
                response = await client.post(RECAPTCHA_VERIFY_URL, data=data)
        except httpx.HTTPError as e:
            logger.error("reCAPTCHA network error: %s", e)
            raise RecaptchaError("network-error", details={"error": str(e)}) from e

        try:
            payload: dict[str, Any] = response.json()
        except ValueError as e:
            raise RecaptchaError("invalid-response") from e

        success = bool(payload.get("success"))
        score = float(payload.get("score", 0.0))
        action = payload.get("action")
        hostname = payload.get("hostname")
        challenge_ts = payload.get("challenge_ts")
        error_codes = payload.get("error-codes") or []

        if not success:
            logger.warning("reCAPTCHA failed: %s", error_codes)
            raise RecaptchaError(
                "verification-failed",
                details={"error-codes": error_codes},
            )

        if expected_action and action != expected_action:
            logger.warning(
                "reCAPTCHA action mismatch: expected=%s actual=%s",
                expected_action,
                action,
            )
            raise RecaptchaError(
                "action-mismatch",
                details={"expected": expected_action, "actual": action},
            )

        if score < self._min_score:
            logger.warning(
                "reCAPTCHA score too low: %.2f < %.2f", score, self._min_score
            )
            raise RecaptchaError(
                "low-score",
                details={"score": score, "min_score": self._min_score},
            )

        return RecaptchaResult(
            success=True,
            score=score,
            action=action,
            hostname=hostname,
            challenge_ts=challenge_ts,
        )


def get_recaptcha_verifier() -> RecaptchaVerifier:
    """FastAPI dependency factory."""
    return RecaptchaVerifier()
