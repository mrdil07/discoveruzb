"""Application settings.

Pydantic Settings — environment'dan o'qib oladi (`.env` yoki real env).
Hech qachon hardcoded sirlar yo'q.
"""

from functools import lru_cache
from typing import Literal

from pydantic import Field, PostgresDsn, RedisDsn
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
        extra="ignore",
    )

    # ===== App =====
    app_name: str = "DiscoverUzb"
    app_env: Literal["development", "staging", "production"] = "development"
    debug: bool = False
    secret_key: str = Field(min_length=32)
    # Pydantic Settings v2 list[str] env'dan JSON parse qiladi —
    # comma-separated string qabul qilish uchun `str` saqlab, property
    # orqali `.split(",")` qilamiz.
    allowed_hosts: str = "localhost,127.0.0.1"
    cors_origins: str = ""

    @property
    def allowed_hosts_list(self) -> list[str]:
        return [x.strip() for x in self.allowed_hosts.split(",") if x.strip()]

    @property
    def cors_origins_list(self) -> list[str]:
        return [x.strip() for x in self.cors_origins.split(",") if x.strip()]

    # ===== Database =====
    database_url: PostgresDsn
    database_pool_size: int = 10
    database_max_overflow: int = 20

    # ===== Redis =====
    redis_url: RedisDsn

    # ===== JWT =====
    jwt_secret_key: str = Field(min_length=32)
    jwt_algorithm: str = "HS256"
    jwt_access_expire_minutes: int = 60
    jwt_refresh_expire_days: int = 30

    # ===== Telegram Gateway =====
    telegram_gateway_token: str = ""
    telegram_otp_length: int = 6
    telegram_otp_ttl_seconds: int = 300
    telegram_otp_max_attempts: int = 5

    # ===== Google OAuth =====
    google_client_id_ios: str = ""
    google_client_id_android: str = ""
    google_client_id_web: str = ""

    @property
    def google_audience(self) -> list[str]:
        """All accepted Google OAuth client IDs (mobile + web)."""
        return [
            cid
            for cid in (
                self.google_client_id_ios,
                self.google_client_id_android,
                self.google_client_id_web,
            )
            if cid
        ]

    # ===== MinIO =====
    minio_endpoint: str = "localhost:9000"
    minio_access_key: str = "minioadmin"
    minio_secret_key: str = "minioadmin"
    minio_bucket_public: str = "media-public"
    minio_bucket_private: str = "media-private"
    minio_public_url: str = "http://localhost:9000"
    minio_use_https: bool = False

    # ===== Rate limiting =====
    rate_limit_otp_per_minute: int = 1
    rate_limit_otp_per_day: int = 10
    rate_limit_api_per_minute: int = 100

    # ===== DevSMS (fallback) =====
    devsms_token: str = ""
    devsms_base_url: str = "https://devsms.uz/api/send_sms.php"

    # ===== reCAPTCHA (admin login) =====
    # Google reCAPTCHA v3 — invisible (UX yaxshi).
    # https://www.google.com/recaptcha/admin
    #
    # Dev test kalitlar (har doim "success" qaytaradi):
    #   site:   6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI
    #   secret: 6LeIxAcTAAAAAGG-vFI1TnRWxMZNFuojJ4WifJWe
    recaptcha_secret_key: str = ""
    recaptcha_site_key: str = ""
    # Eng past skor (v3) — bundan past bo'lsa bot deb hisoblaymiz.
    recaptcha_min_score: float = 0.5

    # ===== External map reviews =====
    # Google Places API (New) — https://developers.google.com/maps/documentation/places/web-service
    google_places_api_key: str = ""
    # Yandex Maps Search/Places API — https://yandex.com/maps-api/products/places-api
    yandex_maps_api_key: str = ""
    # 2GIS Catalog API — https://docs.2gis.com/ru/api/search/places/overview
    gis_api_key: str = ""
    # Cache TTL — necha soatdan keyin reviewlar qayta yig'iladi
    external_reviews_cache_hours: int = 24
    # Har provider'dan maksimal nechta review olinadi
    external_reviews_per_source_limit: int = 20

    @property
    def is_production(self) -> bool:
        return self.app_env == "production"

    @property
    def database_url_sync(self) -> str:
        """Sync URL for Alembic (psycopg2 / psycopg)."""
        return str(self.database_url).replace("+asyncpg", "")


@lru_cache
def get_settings() -> Settings:
    return Settings()  # type: ignore[call-arg]


settings = get_settings()
