"""Lokal development uchun sample data seed script.

Yaratadi:
- 1 ta admin user (`+998901111111`)
- 1 ta moderator user (`+998902222222`)
- 1 ta oddiy user (`+998903333333`)
- 8 ta kategoriya (historical, mountain, nature, ...)
- 5 ta realistic O'zbekiston turistik joy posti
  (Registon, Chimgan, Buxoro Ark, Toshkent kuranti, Termiz)
- Har bir post'da real Google place_id (lekin API key bo'lmasa,
  backend `place_id sozlanmagan` xato qaytarmasdan, real HTTP fetch
  qiladi va 403 qaytaradi — bu OK, UI buni `error` summary'da ko'rsatadi).

Foydalanish:
    cd backend && source .venv/bin/activate
    python -m scripts.seed

Yoki repo root'dan:
    make seed
"""

from __future__ import annotations

import asyncio
import sys
from uuid import UUID

from sqlalchemy import select, text
from sqlalchemy.ext.asyncio import async_sessionmaker, create_async_engine

from app.core.config import settings
from app.core.security import hash_password
from app.models import Base, Category, Post, User, UserRole


# ─────────────────────────────────────────────────────────────────────
# Sample data
# ─────────────────────────────────────────────────────────────────────

CATEGORIES = [
    {"slug": "historical", "name_uz": "Tarixiy", "name_ru": "Исторический", "name_en": "Historical", "sort_order": 1},
    {"slug": "mountain",   "name_uz": "Tog'lar",  "name_ru": "Горы",         "name_en": "Mountains",  "sort_order": 2},
    {"slug": "nature",     "name_uz": "Tabiat",   "name_ru": "Природа",      "name_en": "Nature",     "sort_order": 3},
    {"slug": "museum",     "name_uz": "Muzey",    "name_ru": "Музей",        "name_en": "Museum",     "sort_order": 4},
    {"slug": "bazaar",     "name_uz": "Bozor",    "name_ru": "Базар",        "name_en": "Bazaar",     "sort_order": 5},
    {"slug": "religious",  "name_uz": "Diniy",    "name_ru": "Религиозный",  "name_en": "Religious",  "sort_order": 6},
    {"slug": "park",       "name_uz": "Park",     "name_ru": "Парк",         "name_en": "Park",       "sort_order": 7},
    {"slug": "food",       "name_uz": "Oshxona",  "name_ru": "Кафе",         "name_en": "Food",       "sort_order": 8},
]

# Admin panel login uchun: email + password.
# Mobile login uchun: phone (OTP).
USERS = [
    {
        "phone": "+998901111111",
        "email": "admin@discoveruzb.example.com",
        "fullname": "Admin Adminov",
        "role": UserRole.ADMIN.value,
        "language": "uz",
        "password": "admin123",
    },
    {
        "phone": "+998902222222",
        "email": "moderator@discoveruzb.example.com",
        "fullname": "Moderator Moderatorov",
        "role": UserRole.MODERATOR.value,
        "language": "uz",
        "password": "moderator123",
    },
    {
        "phone": "+998903333333",
        "email": None,
        "fullname": "Test Foydalanuvchi",
        "role": UserRole.USER.value,
        "language": "uz",
        "password": None,  # Mobile user — admin panelga kira olmaydi
    },
]

# Real O'zbekiston joylari + realistic Google Place ID'lar.
# Place ID lar har xil joylar uchun real (Google Maps'dan olingan), lekin
# GOOGLE_PLACES_API_KEY sozlanmagan bo'lsa, fetch HTTP error qaytaradi va
# UI buni `error` summary'da ko'rsatadi.
POSTS = [
    {
        "place_name": "Registon maydoni",
        "place_info": (
            "Samarqand shahridagi mashhur tarixiy maydon. XV-XVII asrlarda "
            "qurilgan uchta madrasa: Ulug'bek, Sher-Dor va Tilla-Kori. "
            "O'zbekiston eng mashhur arxitektura yodgorliklaridan biri va "
            "UNESCO jahon merosi ro'yxatiga kiritilgan."
        ),
        "address": "Samarqand, Registon ko'chasi",
        "type": "historical",
        "source": "Wikipedia",
        "price": "Bepul kirish (madrasalar ichkari $5)",
        "phone_numbers": ["+998662330147"],
        "images": [
            "https://upload.wikimedia.org/wikipedia/commons/thumb/4/49/Samarkand_Registan_Square.jpg/1280px-Samarkand_Registan_Square.jpg",
        ],
        "lat": 39.654594,
        "lon": 66.975731,
        "google_place_id": "ChIJp_AnsiBKMzkRPTOaCKWzObI",
        "yandex_place_id": "",
        "gis_place_id": "",
    },
    {
        "place_name": "Chimgan tog'lari",
        "place_info": (
            "Toshkent viloyatidagi Tien Shan tog' tizmasining bir qismi. "
            "Yozda piyoda yurish, qishda chang'ida sirpanish uchun mashhur. "
            "Eng baland nuqtasi Beshtor cho'qqisi - 4299 metr."
        ),
        "address": "Toshkent viloyati, Bo'stonliq tumani",
        "type": "mountain",
        "source": "uzbekistan.travel",
        "price": "Bepul (Charvoq cho'milish $3)",
        "phone_numbers": [],
        "images": [
            "https://upload.wikimedia.org/wikipedia/commons/thumb/9/9a/Chimgan_Mountains.jpg/1280px-Chimgan_Mountains.jpg",
        ],
        "lat": 41.560,
        "lon": 70.030,
        "google_place_id": "ChIJq_QXgSjLNDkRKEDkUx3qBR4",
        "yandex_place_id": "",
        "gis_place_id": "",
    },
    {
        "place_name": "Buxoro Ark qal'asi",
        "place_info": (
            "Buxoroning eng qadimgi obidasi. V asrda qurilgan amir saroyi. "
            "Hozir muzey sifatida ishlaydi. Ichkarida amir taxti, qabul "
            "zali va mahallariy hayot eksponatlari joylashgan."
        ),
        "address": "Buxoro, Afrosiyob ko'chasi",
        "type": "historical",
        "source": "Lonely Planet",
        "price": "30 000 so'm",
        "phone_numbers": ["+998365221234"],
        "images": [
            "https://upload.wikimedia.org/wikipedia/commons/thumb/2/2a/Bukhara_Ark.jpg/1280px-Bukhara_Ark.jpg",
        ],
        "lat": 39.776,
        "lon": 64.414,
        "google_place_id": "ChIJk6Ggn2dHQjkRxFmKQ4dEhJI",
        "yandex_place_id": "",
        "gis_place_id": "",
    },
    {
        "place_name": "Toshkent kuranti",
        "place_info": (
            "Toshkent markazidagi mashhur soat minorasi. 1947 yilda qurilgan. "
            "Atrofda fontanlar, parklar va mashhur restoranlar."
        ),
        "address": "Toshkent, Amir Temur ko'chasi",
        "type": "park",
        "source": "Tashkent City",
        "price": "Bepul",
        "phone_numbers": [],
        "images": [
            "https://upload.wikimedia.org/wikipedia/commons/thumb/1/13/Tashkent_kurant.jpg/800px-Tashkent_kurant.jpg",
        ],
        "lat": 41.311,
        "lon": 69.279,
        "google_place_id": "ChIJ7VHWzGUH_z4RAJSwLPyA-Eo",
        "yandex_place_id": "",
        "gis_place_id": "",
    },
    {
        "place_name": "Termiz arxeologik muzeyi",
        "place_info": (
            "Surxondaryo viloyati markazi Termiz shahridagi yirik muzey. "
            "Buddizm va islom artefaktlari, Kushon imperiyasi davriga oid "
            "tangalar, haykallar va sopol idishlar to'plami."
        ),
        "address": "Termiz, Al-Hakim at-Termiziy ko'chasi",
        "type": "museum",
        "source": "Min. madaniyat",
        "price": "20 000 so'm",
        "phone_numbers": ["+998762282030"],
        "images": [
            "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d6/Termez_archaeological_museum.jpg/1024px-Termez_archaeological_museum.jpg",
        ],
        "lat": 37.224,
        "lon": 67.278,
        "google_place_id": "ChIJN5_TgGNUMTkRRfMd5dcdLqU",
        "yandex_place_id": "",
        "gis_place_id": "",
    },
]


# ─────────────────────────────────────────────────────────────────────
# Seeder
# ─────────────────────────────────────────────────────────────────────


async def seed() -> None:
    print(f"→ Connecting to {str(settings.database_url).split('@')[-1]}")
    engine = create_async_engine(str(settings.database_url), echo=False)
    Session = async_sessionmaker(engine, expire_on_commit=False)

    async with Session() as db:
        # Categories — idempotent (PK = slug)
        print("→ Upserting categories...")
        existing_slugs = set(
            (await db.scalars(select(Category.slug))).all()
        )
        for cat in CATEGORIES:
            if cat["slug"] not in existing_slugs:
                db.add(Category(**cat))
        await db.commit()
        print(f"  ✓ {len(CATEGORIES)} ta kategoriya")

        # Users
        print("→ Upserting users...")
        users_by_phone: dict[str, User] = {}
        for u_data in USERS:
            raw = dict(u_data)
            plain_password = raw.pop("password", None)
            password_hash = hash_password(plain_password) if plain_password else None

            existing = await db.scalar(select(User).where(User.phone == raw["phone"]))
            if existing is None:
                user = User(**raw, password_hash=password_hash)
                db.add(user)
                await db.commit()
                await db.refresh(user)
                users_by_phone[raw["phone"]] = user
                cred = f" | parol: {plain_password}" if plain_password else ""
                print(
                    f"  ✓ {raw['fullname']} ({raw['role']}) — "
                    f"{raw['phone']}{cred}"
                )
            else:
                # Update role / email / password if changed
                changed = False
                if existing.role != raw["role"]:
                    existing.role = raw["role"]
                    changed = True
                if raw.get("email") and existing.email != raw["email"]:
                    existing.email = raw["email"]
                    changed = True
                # Faqat password yo'q bo'lsa o'rnatamiz (idempotent — mavjud
                # parolni qayta-qayta xeshlab almashtirmaymiz).
                if password_hash and not existing.password_hash:
                    existing.password_hash = password_hash
                    changed = True
                if changed:
                    await db.commit()
                users_by_phone[raw["phone"]] = existing
                print(f"  • {raw['fullname']} ({raw['role']}) — mavjud")

        admin = users_by_phone["+998901111111"]

        # Posts — idempotent by place_name (oddiy heuristika)
        print("→ Upserting posts...")
        existing_names = set(
            (await db.scalars(select(Post.place_name))).all()
        )
        for p_data in POSTS:
            if p_data["place_name"] in existing_names:
                print(f"  • {p_data['place_name']} — mavjud")
                continue
            post = Post(author_id=admin.id, **p_data)
            db.add(post)
            print(f"  ✓ {p_data['place_name']}")
        await db.commit()

    await engine.dispose()
    print("\n✅ Seed muvaffaqiyatli tugadi!\n")
    print("📱 Mobile login (OTP):")
    print("   Phone: +998901111111 (admin)")
    print("   Phone: +998902222222 (moderator)")
    print("   Phone: +998903333333 (user)")
    print("   OTP: backend logiga qarang (dev rejim — OTP stdout'ga chiqadi)\n")
    print("🌐 Admin panel: http://localhost:3000/login")
    print("   admin@discoveruzb.example.com      / admin123")
    print("   moderator@discoveruzb.example.com  / moderator123")
    print("   (telefon raqami bilan ham bo'ladi: +998901111111 / admin123)\n")


if __name__ == "__main__":
    try:
        asyncio.run(seed())
    except KeyboardInterrupt:
        print("\n❌ Bekor qilindi")
        sys.exit(1)
