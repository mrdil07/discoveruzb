# Lokal development yo'l-yo'riq

Butun DiscoverUzb stack-ni mahalliy kompyuterda ishga tushirish va
sinash qo'llanmasi.

> **Diqqat:** Bu hujjat dasturchilar uchun. Production deploy uchun
> alohida hujjat tayyorlanadi (Sprint 13).

---

## 1. Tizim talablari

| Asbob | Versiya | O'rnatish |
|---|---|---|
| **macOS / Linux** | macOS 14+, Ubuntu 24+ | — |
| **PostgreSQL** | 15+ | `brew install postgresql@15` |
| **Python** | 3.12+ | `brew install python@3.12` |
| **uv** | latest | `brew install uv` |
| **Node.js** | 22+ | `brew install node` |
| **pnpm** | 10+ | `brew install pnpm` |
| **Flutter** | 3.27+ | <https://flutter.dev/docs/get-started/install> |
| **Xcode** (iOS) | 15+ | App Store |
| **Android Studio** (Android) | latest | <https://developer.android.com/studio> |

Tekshirish:
```bash
brew services list | grep postgres   # started bo'lishi kerak
python3 --version                     # 3.12.x
uv --version
pnpm --version
flutter doctor                        # iOS + Android toolchain
```

---

## 2. Bir buyruqda setup (eng tez yo'l)

```bash
git clone https://github.com/Dilshodbek007/discoveruzb.git
cd discoveruzb
make setup    # DB yaratadi + backend install + migrations + seed + admin install
```

Bu quyidagilarni qiladi:
1. `discoveruzb` va `discoveruzb_test` DB yaratadi.
2. `backend/.venv` virtual env yaratadi va paketlarni o'rnatadi.
3. Alembic migrations (`0001_initial`, `0002_external_reviews`).
4. Seed: 3 ta user + 8 ta kategoriya + 5 ta sample post.
5. Admin paketlarini o'rnatadi (`pnpm install`).

Tugagandan keyin **3 ta terminal** oching va har birida:

```bash
make backend       # T1 — http://localhost:8000
make admin         # T2 — http://localhost:3000
make mobile-ios    # T3 — iOS simulator
```

---

## 3. Bosqichma-bosqich qo'lda setup

### 3.1. PostgreSQL

```bash
brew install postgresql@15
brew services start postgresql@15

# DB user va databaselar
make db-create
```

### 3.2. Backend (`backend/`)

```bash
make backend-install     # uv venv + paketlar
make migrate             # schema yaratish
make seed                # sample data

make backend             # uvicorn :8000
```

Tekshirish:
```bash
curl http://localhost:8000/health
# {"status":"ok","version":"0.1.0"}
```

API hujjat: <http://localhost:8000/docs>

### 3.3. Admin panel (`admin/`)

```bash
make admin-install       # pnpm install
make admin               # next dev :3000
```

Brauzer: <http://localhost:3000>

### 3.4. Mobile (Flutter)

`.env` fayl repo root'da bor (Sprint 0'da yaratilgan). Ichida:
```env
API_BASE_URL=http://localhost:8000
SUPABASE_URL=...   # eski — endi ishlatilmaydi
```

`API_BASE_URL` muhim — mobile shu manzilga so'rov yuboradi.

```bash
make mobile-codegen      # Freezed regen (modellar o'zgarganda)
make mobile-l10n         # Localization regen (ARB o'zgarganda)

make mobile-ios          # iPhone simulator
# yoki
make mobile-android      # Android emulator
```

> **Android Studio JBR** Android build uchun zarur. Agar Java
> topilmasa: `export JAVA_HOME=/Applications/Android\ Studio.app/Contents/jbr/Contents/Home`.

---

## 4. Login va test foydalanuvchilari

Seed 3 ta foydalanuvchi yaratadi:

| Phone | Role | Maqsad |
|---|---|---|
| `+998901111111` | `admin` | Admin panelga kirish + barcha CRUD |
| `+998902222222` | `moderator` | Moderatsiya (post o'chirish, hide) |
| `+998903333333` | `user` | Oddiy mobile user |

### Login oqimi (Telegram OTP)

`TELEGRAM_GATEWAY_TOKEN` `.env`'da bo'sh bo'lsa, backend **dev rejimga**
o'tadi va OTP'ni stdout'ga chiqaradi. SMS yuborilmaydi.

**Admin panel login:**
1. <http://localhost:3000/login>
2. Telefon: `+998901111111`
3. **Backend terminal'ga qarang:**
   ```
   WARNING | app.services.auth | [DEV] Telegram Gateway not configured. OTP for +998901111111: 526450
   ```
4. OTP'ni admin panel'ga kiritasiz → login amalga oshadi.

**Mobile login:** xuddi shu oqim.

### Google Sign-In

Bo'sh `GOOGLE_CLIENT_ID_*` env bilan ishlamaydi. Sozlash uchun:
`docs/google-signin-setup.md` ga qarang.

---

## 5. Tashqi xarita sharhlari (Google / Yandex / 2GIS)

`.env`'da `GOOGLE_PLACES_API_KEY` va boshqalar bo'sh. Endpoint ishlaydi,
lekin har source uchun `error: "API_KEY sozlanmagan"` qaytadi va
mobile/admin UI buni "Place ID sozlanmagan / API key sozlanmagan"
qoplab ko'rsatadi.

Real test uchun:
- `docs/external-reviews-setup.md` ga qarang
- Google Cloud Console'da Places API yoqing va API key oling
- `.env`'ga qo'shing va `make backend` qayta ishga tushiring

---

## 6. Tezkor buyruqlar (`make help`)

```bash
make help              # barcha buyruqlar
make status            # Postgres + backend holatini tekshirish
make stop              # backend va admin process'larini to'xtatish

# Backend
make backend           # uvicorn :8000
make seed              # sample data
make test              # 77 integration test
make test-cov          # + coverage
make migrate           # alembic upgrade head
make migration NAME=add_foo_table   # yangi migration
make db-reset          # ⚠️ DB drop + recreate + migrate + seed

# Admin
make admin             # next dev :3000
make admin-build       # production build
make admin-typecheck   # tsc --noEmit

# Mobile
make mobile-ios        # iOS simulator
make mobile-android    # Android emulator
make mobile-codegen    # Freezed regen
make mobile-l10n       # l10n regen

# Quality
make analyze           # flutter analyze + pnpm typecheck
make lint              # backend ruff
make fmt               # ruff format + dart format
```

---

## 7. Tipik dev workflow

### Yangi feature qo'shish (backend + mobile + admin)

```bash
# 1. Yangi DB ustun
make migration NAME=add_post_video_url
# alembic'da qo'lda upgrade() to'ldirasiz
make migrate

# 2. Backend
# Model'ga field qo'shing, schemas'ni yangilang, endpoint qo'shing
make test                      # regression check

# 3. Mobile
# Freezed model'ga field, ViewModel, UI
make mobile-codegen
make mobile-ios

# 4. Admin
# TanStack Query / Refine list/edit'ga field
make admin

# 5. Tekshirish
make analyze                   # 0 error bo'lishi kerak
make test
```

### Database o'zgarishi

```bash
# Avval models/*.py'ga o'zgartirish
make migration NAME=qisqa_tavsif

# Yaratilgan migration'ni `alembic/versions/` da tekshiring
# Keyin qo'llang:
make migrate

# Yoki butunlay qaytadan boshlash:
make db-reset
```

### Sample data qayta tushirish

```bash
make seed     # idempotent — mavjud data'ni o'chirmaydi, faqat yo'qlarini qo'shadi
```

To'liq tozalash:
```bash
make db-reset
```

---

## 8. Common errors va yechimlar

| Xato | Sabab | Yechim |
|---|---|---|
| `pg_isready: connection refused` | Postgres ishlamayapti | `brew services start postgresql@15` |
| `password authentication failed` | DB user yaratilmagan | `make db-create` |
| `No module named 'psycopg2'` | Alembic uchun sync driver kerak | `uv pip install psycopg2-binary` |
| `error parsing value for field "allowed_hosts"` | Pydantic Settings list parsing | Faqat `str` ishlating, `_list` property orqali bo'ling |
| `bcrypt has no attribute __about__` | passlib + new bcrypt mos kelmaydi | `uv pip install "bcrypt<4.1"` |
| `Telegram Gateway not configured` (warning) | `.env`'da `TELEGRAM_GATEWAY_TOKEN` bo'sh | Dev rejim — OTP backend log'da, normal |
| `MinIO init skipped` (warning) | MinIO ishlamayapti | Image upload sinasangiz, Docker compose'dan `minio` xizmatini ishga tushiring |
| Mobile `Failed host lookup` | `API_BASE_URL` noto'g'ri | `.env`'da `API_BASE_URL=http://localhost:8000` |
| iOS sim'da `localhost` ishlamasligi mumkin | iOS sim mahalliy host'ni topadi | `http://localhost:8000` odatda ishlaydi. Agar bo'lmasa: `http://127.0.0.1:8000` |
| Android emulator'da `localhost` | Android emulator alohida network | `http://10.0.2.2:8000` (host machine alias) |

---

## 9. Test infratuzilma

### Backend integration testlari (77 ta)

```bash
make test                          # 10s
make test-cov                      # 11s + coverage hisobot
```

Test alohida `discoveruzb_test` DB ishlatadi — production data ga
tegmaydi. Har test'da jadval truncate.

### Mobile testlar

Hozircha mobile uchun test yo'q (Sprint 15'da rejada).

### Admin testlar

Hozircha admin uchun test yo'q (kelajakda Playwright bilan).

---

## 10. Production deploy uchun farq

Lokal vs Production sozlamalari (`backend/.env`):

| Sozlama | Lokal | Production |
|---|---|---|
| `APP_ENV` | `development` | `production` |
| `DEBUG` | `true` | `false` |
| `SECRET_KEY` | dev value | **random 32 byte hex** |
| `JWT_SECRET_KEY` | dev value | **random 32 byte hex** |
| `DATABASE_URL` | `localhost:5432` | managed DB yoki private network |
| `ALLOWED_HOSTS` | `localhost,127.0.0.1` | `api.discoveruzb.uz` |
| `CORS_ORIGINS` | `http://localhost:3000,...` | `https://admin.discoveruzb.uz` |
| `TELEGRAM_GATEWAY_TOKEN` | bo'sh (dev OTP) | **real token** |
| `GOOGLE_PLACES_API_KEY` | bo'sh | real |
| `MINIO_*` | localhost | private bucket + signed URL |

Production deploy hujjati — `docs/production-deploy.md` (Sprint 13'da).

---

**So'nggi yangilanish:** 2026-05-12. Sprint 12.
