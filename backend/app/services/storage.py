"""MinIO storage service.

Public va private bucket'lar bilan ishlaydi. Rasm yuklashdan oldin
Pillow orqali optimizatsiya qiladi (WebP, max 1920px).
"""

from __future__ import annotations

import io
import json
import secrets
from dataclasses import dataclass
from datetime import datetime, timedelta
from typing import IO

from minio import Minio
from minio.error import S3Error
from PIL import Image

from app.core.config import settings
from app.core.logging import get_logger

logger = get_logger(__name__)


def _public_read_policy(bucket: str) -> str:
    """Bucket-level policy: anonymous `s3:GetObject` (rasm public URL'lari)."""
    return json.dumps(
        {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Effect": "Allow",
                    "Principal": {"AWS": ["*"]},
                    "Action": ["s3:GetObject"],
                    "Resource": [f"arn:aws:s3:::{bucket}/*"],
                }
            ],
        }
    )

# Image processing
MAX_DIMENSION = 1920
WEBP_QUALITY = 85
JPEG_QUALITY = 88
ALLOWED_IMAGE_TYPES = {"image/jpeg", "image/png", "image/webp", "image/heic"}


@dataclass(slots=True, frozen=True)
class UploadResult:
    key: str
    url: str
    size_bytes: int
    content_type: str


class StorageService:
    """MinIO klient — public/private bucket'lar bilan."""

    def __init__(self) -> None:
        self._client = Minio(
            settings.minio_endpoint,
            access_key=settings.minio_access_key,
            secret_key=settings.minio_secret_key,
            secure=settings.minio_use_https,
        )

    def ensure_buckets(self) -> None:
        """App start'da bucket'larni yaratish/tekshirish.

        Public bucket'ga anonim `s3:GetObject` policy o'rnatamiz — shu
        orqali yuklangan rasmlar to'g'ridan-to'g'ri public URL bilan
        ko'rsatiladi (CDN/proxy'siz). Private bucket'da policy o'rnatilmaydi
        — uning ichidagi obyektlar faqat presigned URL orqali ochiladi.
        """
        for bucket in (settings.minio_bucket_public, settings.minio_bucket_private):
            try:
                if not self._client.bucket_exists(bucket):
                    self._client.make_bucket(bucket)
                    logger.info("Created bucket: %s", bucket)
            except S3Error as e:
                logger.error("Bucket init error %s: %s", bucket, e)
                raise

        # Public bucket policy idempotent ravishda o'rnatiladi
        try:
            self._client.set_bucket_policy(
                settings.minio_bucket_public,
                _public_read_policy(settings.minio_bucket_public),
            )
            logger.info(
                "Public-read policy set on bucket: %s",
                settings.minio_bucket_public,
            )
        except S3Error as e:
            logger.warning(
                "Could not set public-read policy on %s: %s",
                settings.minio_bucket_public,
                e,
            )

    def _process_image(self, data: bytes, content_type: str) -> tuple[bytes, str, str]:
        """Pillow bilan resize + WebP konversiyasi.

        Returns: (processed_bytes, new_content_type, extension)
        """
        try:
            img = Image.open(io.BytesIO(data))
            img = img.convert("RGB") if img.mode in ("RGBA", "P") else img

            # Resize agar katta bo'lsa
            if max(img.size) > MAX_DIMENSION:
                img.thumbnail((MAX_DIMENSION, MAX_DIMENSION), Image.Resampling.LANCZOS)

            # WebP'ga konvert
            buf = io.BytesIO()
            img.save(buf, format="WEBP", quality=WEBP_QUALITY, method=6)
            return buf.getvalue(), "image/webp", "webp"
        except Exception as e:
            logger.warning("Image processing failed (%s) — keeping original", e)
            ext = content_type.split("/")[-1].replace("jpeg", "jpg")
            return data, content_type, ext

    async def upload_image(
        self,
        *,
        data: bytes,
        content_type: str,
        folder: str,
        bucket: str | None = None,
    ) -> UploadResult:
        """Rasm yuklash. Avtomatik resize + WebP."""
        if content_type not in ALLOWED_IMAGE_TYPES:
            raise ValueError(f"Qo'llab-quvvatlanmaydigan format: {content_type}")

        processed, new_type, ext = self._process_image(data, content_type)
        bucket = bucket or settings.minio_bucket_public

        timestamp = int(datetime.now().timestamp() * 1000)
        random_id = secrets.token_hex(4)
        key = f"{folder}/{timestamp}_{random_id}.{ext}"

        self._client.put_object(
            bucket_name=bucket,
            object_name=key,
            data=io.BytesIO(processed),
            length=len(processed),
            content_type=new_type,
        )

        # Public URL (public bucket bo'lsa)
        if bucket == settings.minio_bucket_public:
            url = f"{settings.minio_public_url.rstrip('/')}/{bucket}/{key}"
        else:
            # Private — presigned URL (1 soat)
            url = self._client.presigned_get_object(
                bucket_name=bucket,
                object_name=key,
                expires=timedelta(hours=1),
            )

        return UploadResult(
            key=key,
            url=url,
            size_bytes=len(processed),
            content_type=new_type,
        )

    def delete(self, key: str, *, bucket: str | None = None) -> bool:
        bucket = bucket or settings.minio_bucket_public
        try:
            self._client.remove_object(bucket, key)
            return True
        except S3Error as e:
            logger.warning("Delete failed %s/%s: %s", bucket, key, e)
            return False

    def presigned_get(self, key: str, *, hours: int = 1) -> str:
        return self._client.presigned_get_object(
            bucket_name=settings.minio_bucket_private,
            object_name=key,
            expires=timedelta(hours=hours),
        )


# Singleton
_storage_instance: StorageService | None = None


def get_storage() -> StorageService:
    global _storage_instance
    if _storage_instance is None:
        _storage_instance = StorageService()
    return _storage_instance
