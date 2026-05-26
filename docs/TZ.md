# TEXNIK TOPSHIRIQ

## "DiscoverUzb" — O'zbekiston turistik joylari ekotizimi

**Hujjat turi:** Texnik topshiriq (GOST 19.201 ga yaqin format)
**Versiya:** 2.0
**Sana:** 2026-05-10
**Repozitoriy:** https://github.com/Dilshodbek007/discoveruzb.git

> **Versiya 2.0 o'zgarishlari:** Supabase BaaS arxitekturasidan custom
> backend (FastAPI) + admin panel (Next.js + Refine) + multi-auth
> (Telegram Gateway + Google) ga to'liq migratsiya. Eski 1.x versiyasi
> Git tarixida.

---

## 1. KIRISH

### 1.1. Loyiha nomi

**DiscoverUzb** — O'zbekistondagi turistik joylarni kashf etish, qidirish,
saqlash va boshqalar bilan ulashish uchun ekotizim. Uchta komponent:

1. **Mobil ilova** (Flutter, iOS/Android) — asosiy foydalanuvchi mahsuloti.
2. **Backend API** (Python FastAPI) — biznes mantiq, DB, auth, storage.
3. **Admin panel** (Next.js + Refine + shadcn/ui) — kontent boshqaruvi va
   moderatsiya.

Asosiy auditoriya: O'zbekiston ichidagi va xorijiy turistlar.

### 1.2. Asosiy domenlar / kirish nuqtalari

| Manzil | Vazifasi |
|--------|----------|
| `https://api.discoveruzb.uz` (TODO domain) | Backend API (FastAPI) |
| `https://admin.discoveruzb.uz` (TODO domain) | Admin panel (Next.js) |
| `https://media.discoveruzb.uz` (TODO domain) | MinIO public images |
| iOS App Store: `uz.dizcoveruzb.discoveruzb` | iOS distribution |
| Google Play: `uz.dizcoveruzb.discoveruzb` | Android distribution |
| `https://gateway.telegram.org/api` | Telegram OTP (Gateway xizmati) |
| `https://api.openweathermap.org/data/2.5/weather` | Ob-havo ma'lumoti |
| `https://accounts.google.com/.well-known/openid-configuration` | Google OAuth |

### 1.3. Loyiha maqsadi

Tizim quyidagi funksiyalarni ta'minlaydi:

1. Turistik joylarni ro'yxat va kategoriya bo'yicha namoyish.
2. Joy tafsilotlari: rasmlar (carousel), tavsif, manzil, telefon, narx,
   ob-havo va xaritada yo'nalish.
3. Foydalanuvchi profili: layk, saqlangan postlar, izohlar.
4. Multi-auth: **Telegram Gateway OTP** (asosiy) + **Google Sign-In**
   (alternative).
5. Shaxsiy galereya yaratish va ulashish (public share link bilan).
6. Joy nomi bo'yicha qidiruv (PostgreSQL trigram).
7. **Admin panel:** kontent moderatsiyasi, foydalanuvchilarni boshqarish,
   statistika, sozlamalar.

### 1.4. Foydalanuvchi toifalari

| Rol | Kanal | Imkoniyatlar |
|-----|-------|--------------|
| Mehmon | Mobil ilova (login oldin) | Ko'rishi mumkin emas — login majburiy |
| Foydalanuvchi (`role=user`) | Mobil ilova | Joylarni ko'rish, layk, saqlash, izoh, o'z galereyasi |
| Moderator (`role=moderator`) | Admin panel | Postlar va izohlarni moderatsiya, foydalanuvchilarni view |
| Admin (`role=admin`) | Admin panel | Barcha CRUD, foydalanuvchilarni ban/role o'zgartirish, sozlamalar |

Rol DB'da `users.role` ustunda saqlanadi va JWT'ga claim sifatida
joylanadi. Backend har endpoint'da `Depends(require_role)` orqali tekshiradi.

### 1.5. Hujjat maqsadi

Mazkur hujjat loyihaning joriy arxitekturasini va talablarini
rasmiylashtiradi. U quyidagilar uchun mo'ljallangan:

- Yangi dasturchilarni loyihaga jalb qilish.
- Keyingi bosqichlar uchun reja tuzish (audit roadmap, §8).
- Tizim kamchiliklarini va texnik qarzlarni hujjatlashtirish (§9).

---

## 2. ASOSLASH VA ZARURAT

### 2.1. Muammo tahlili

- O'zbekistonda turistik joylar haqida bitta yagona, zamonaviy va
  uchta tilda (UZ/RU/EN) ishlaydigan rasmiy mobil ilova yo'q.
- Mavjud yechimlar (web sahifalar, blog'lar) statik, ob-havo va offline
  rejim bilan integratsiyalanmagan.
- Foydalanuvchilarda joy tafsilotlarini "saqlash" va keyinroq qaytib
  ko'rish ehtiyoji bor.
- Mobil-first auditoriya — desktop kanallari kam ishlaydi.

### 2.2. Loyiha yechimi

Flutter mobil ilova + Supabase BaaS (PostgreSQL + Storage). Backend kod
yozilmaydi — barcha CRUD'lar Supabase REST orqali. Ob-havo va SMS
tashqi servislar orqali.

### 2.3. Afzalliklari

1. **Cross-platform:** iOS va Android bitta kod bazasidan.
2. **Offline-first imkoniyati:** Hive lokal kesh bor, kengaytirilishi
   mumkin (rasm cache `cached_network_image` bilan).
3. **Tez deploy:** Supabase tufayli backend infra'ni boshqarish kerak emas.
4. **Uch tilli UI:** O'zbek/Rus/Ingliz `flutter_localizations`.
5. **O'lchamga moslashuvchi UI:** `responsive_framework` orqali
   mobile/tablet/desktop layout.

---

## 3. TIZIMGA QO'YILADIGAN TALABLAR

### 3.1. Umumiy talablar

- Tizim yuqori mavjudlikka (high availability) ega bo'lishi kerak —
  Supabase managed SLA'ga tayanadi.
- iOS va Android store qoidalariga muvofiq (privacy manifest, App
  Tracking Transparency, Play Data Safety).
- Barcha foydalanuvchi ma'lumotlari xavfsiz saqlanishi kerak (RLS
  politikalar — TODO: hozirda `Allow all`).

### 3.2. Ishonchlilik talablari

- Tarmoq xatoligida ilova qulamasin — `try/catch` va shimmer
  loading + retry mexanizmi.
- Supabase backupи Supabase tomonidan boshqariladi (free plan'da kunlik).
- Lokal Hive box'lari `Hive.initFlutter()` da xavfsiz ochilsin.

### 3.3. Unumdorlik talablari

- Asosiy ekran (HomePage) yuklash vaqti < 2 soniya 4G tarmoqda.
- Postlar ro'yxati pagination bilan yuklansin (TODO: hozirda yo'q,
  barcha postlar bir martada).
- Image cache — `cached_network_image` bilan disk cache.
- Skroll FPS ≥ 55 (iPhone 11 va shunga ekvivalent darajadagi qurilmada).

### 3.4. Xavfsizlik talablari

- **Autentifikatsiya:**
  - Telefon + Telegram Gateway OTP (asosiy).
  - Google Sign-In ID token (alternative).
  - DevSMS — Telegram'siz user'lar uchun fallback (kelajak).
- **Avtorizatsiya:** rolli — `users.role` (`user` | `moderator` | `admin`).
  JWT `claim['role']` orqali backend va admin panelda tekshiriladi.
- **JWT:** access (1 soat) + refresh (30 kun, DB'da hashlangan).
- **Sezgir oqimlar** (OTP, login, role o'zgartirish) — barcha audit
  log'ga yoziladi. Batafsil: `docs/security-rules.md`.
- **SSL/TLS:** barcha public domenlarda majburiy (Let's Encrypt).
- **Sirlar:** backend `.env` + systemd `EnvironmentFile=`.
  Mobile'da `--dart-define`. Repo'da hech qachon hardcoded yo'q.

### 3.5. Kengaytirilganlik talablari

- Supabase `posts` jadvali kelajakda partition qilinishi mumkin
  (region/category bo'yicha).
- Storage rasmlarga CDN qo'shilishi (Supabase pro plan yoki Cloudflare).
- Realtime subscription qo'llanilishi mumkin (yangi izoh, layk).

### 3.6. Ekspluatatsiya talablari

- Mobile-only — server boshqaruvi yo'q.
- Supabase dashboard orqali jadval va RLS boshqariladi.
- App Store / Play Console orqali release.

---

## 4. FUNKSIONAL TALABLAR

> Bu bo'lim loyihaning yuragi. Har bir komponent uchun alohida sub-bo'lim
> oching va ichida endpointlar/sahifalar/komandalar ro'yxatini saqlang.
> Yangi feature qo'shilganda darhol shu yerga yozing (`CLAUDE.md §3`).

### 4.1. Backend API (`backend/`)

FastAPI + SQLAlchemy 2.0 (async) + PostgreSQL. Barcha endpoint'lar
`/api/v1/` prefiksi bilan. JSON request/response. JWT auth.

#### 4.1.1. Auth router (`/api/v1/auth/`)

- `POST /telegram/send-otp` — telefon raqamni qabul qiladi, Telegram
  Gateway orqali OTP yuboradi. Body: `{phone}`.
- `POST /telegram/verify-otp` — OTP tekshiruvi, JWT qaytaradi.
  Body: `{phone, code}`. Response: `{access_token, refresh_token, user}`.
- `POST /google` — Google ID token verifikatsiyasi va JWT qaytarish.
  Body: `{id_token}`.
- `POST /refresh` — refresh token orqali yangi access token.
  Body: `{refresh_token}`.
- `POST /logout` — refresh tokenni invalidate qiladi.
- `GET /me` — joriy foydalanuvchi (Bearer JWT bilan).

#### 4.1.2. Users router (`/api/v1/users/`)

- `GET /me` — joriy foydalanuvchi profili.
- `PATCH /me` — profilni yangilash (`fullname`, `email`, `img_url`).
- `POST /me/avatar` — profil rasmini yuklash (multipart, → MinIO).
- `GET /{user_id}` — public profil (admin uchun barcha maydon).
- `GET /` (admin) — foydalanuvchilar ro'yxati (pagination + filter).
- `PATCH /{user_id}/role` (admin) — rol o'zgartirish.
- `DELETE /{user_id}` (admin) — ban / o'chirish.

#### 4.1.3. Posts router (`/api/v1/posts/`)

- `GET /` — postlar ro'yxati. Query: `?page=1&size=20&type=&address=&sort=time|like_count&order=asc|desc`.
- `GET /famous` — eng ko'p layklangan top 20 (cache 5 daqiqa).
- `GET /recommend` — tavsiya algoritmi (kelajakda — hozirgisi `famous`).
- `GET /search?q=keyword` — ism bo'yicha qidiruv.
- `GET /{post_id}` — bitta post (kommentlar va layk soni bilan).
- `POST /` — yangi post (mobile + admin).
- `PATCH /{post_id}` — post yangilash (faqat ega yoki admin).
- `DELETE /{post_id}` — o'chirish (faqat ega yoki admin).
- `POST /{post_id}/like` — toggle like.
- `POST /{post_id}/save` — toggle save.
- `GET /me/liked` — joriy user'ning layklari.
- `GET /me/saved` — joriy user'ning saqlanganlar.
- `POST /{post_id}/images` — post rasmlarini ko'tarish.

#### 4.1.4. Comments router (`/api/v1/comments/`)

- `GET /post/{post_id}` — post bo'yicha izohlar.
- `POST /post/{post_id}` — yangi izoh.
- `DELETE /{comment_id}` — o'chirish (ega yoki admin).
- `POST /{comment_id}/report` (kelajak) — moderatsiyaga jo'natish.

#### 4.1.5. Gallery router (`/api/v1/galleries/`)

- `GET /me` — foydalanuvchi galereyalari.
- `POST /` — yangi galereya.
- `PATCH /{gallery_id}` — yangilash.
- `POST /{gallery_id}/images` — rasm qo'shish.
- `DELETE /{gallery_id}` — o'chirish.
- `GET /{gallery_id}/share-link` — public shareable link generatsiyasi.

#### 4.1.6. Categories router (`/api/v1/categories/`) — yangi

- `GET /` — kategoriyalar ro'yxati (admin tomonidan boshqariladi).
- Admin uchun POST/PATCH/DELETE.

#### 4.1.7. Stats router (`/api/v1/stats/`) — admin

- `GET /dashboard` — total user, post, today new, eng ko'p layklangan.
- `GET /users-by-day?from=&to=` — kunlik signup grafik.
- `GET /posts-by-type` — turlar bo'yicha taqsimot.

#### 4.1.8. Storage (`backend/app/services/storage.py`)

MinIO (S3-compatible) bilan integratsiya.

- `upload_file(file, folder) -> public_url`
- `delete_file(key) -> bool`
- `generate_presigned_url(key, expires=3600) -> url` (private buckets uchun)
- Public bucket: `media-public` (post rasmlari, avatarlar).
- Private bucket: `media-private` (galereya, kelajak — to'lov receipts).

### 4.2. Mobil ilova (`lib/`)

#### 4.2.1. Asosiy navigatsiya

`MainPage` (`screens/pageViewPages/main_screen.dart`) — `PageView` +
`BottomNavigationBar`:

| Tab | Ekran | Vazifasi |
|-----|-------|----------|
| 0. Home | `HomePage` | Famous + Recommended + New posts |
| 1. Search | `TypeOfPlaces` | Kategoriya bo'yicha qidiruv |
| 2. Add | `MediaPage` | Galereya yaratish/ko'rish |
| 3. Account | `AccountPage` | Profil, layklar, saqlanganlar |

#### 4.2.2. Auth oqim

1. `SplashPage` — 3 sek delay + `Prefs.loadUserId()` tekshiruv.
2. Login yo'q → `LoginWithPhone` — telefon kiritish.
3. `OTPScreen` — DevSMS orqali OTP yuborish + tekshirish.
4. Yangi user → `Registration` (ism/familiya).
5. `MainPage`.

> **Test rejim:** `+998911490349` raqami uchun OTP `121212` (faqat
> `kDebugMode`).

#### 4.2.3. ViewModels (`lib/view_models/`)

| ViewModel | Asosiy holatlar |
|-----------|-----------------|
| `HomeViewModel` | famousPlaces, recPosts, newAdded, fullName, imgUrl, userId |
| `MainViewModel` | currentPage, pageController |
| `AccountViewModel` | places (my/saved), profile data, image picker |
| `DetailsVM` | weather temp, like/save toggle |
| `SubCategoryVM` | filtered posts per category |
| `CommentVM` | comments per post |
| `MediaPageVM` | gallery list |
| `CreateGalleryVM` | new gallery form |
| `SplashViewModel` | isLoggedIn, isLoading |
| `LoginViewModel`, `OTPViewModel`, `RegistrationViewModel` | auth oqim |
| `SearchViewModel` | search results |

### 4.3. Tashqi integratsiyalar

#### 4.3.1. DevSMS (`sms_service.dart`)

- `POST https://devsms.uz/api/send_sms.php` — JSON body, Bearer token.
- 6 xona OTP, "MRDIL: Ilovaga kirish uchun parol: <OTP>" matni.
- Token `--dart-define=DEVSMS_TOKEN=...` orqali (TODO).

#### 4.3.2. OpenWeatherMap (`details_vm.dart`)

- `GET /data/2.5/weather?lat=...&lon=...&appid=...&units=metric`.
- Faqat `temp` ko'rsatiladi (AppBar'da).
- API key `--dart-define=OPENWEATHER_KEY=...` orqali (TODO).

#### 4.3.3. Map Launcher (`map_launcher: ^3.5.0`)

- `MapLauncher.installedMaps` — qurilmadagi xaritalar ro'yxati.
- Bottom sheet'da har xarita ikonkasi ko'rsatiladi.

### 4.4. Lokal saqlash

- **Hive** (`person`, `restore` boxes) — foydalanuvchi obyektini cache.
- **SharedPreferences** — `userId`, `phone`, `fullname`.
  TODO: `flutter_secure_storage` ga ko'chirish (token sezgir).

---

## 5. TEXNIK TALABLAR

### 5.1. Dasturiy stack

#### Backend (`backend/`)

| Qatlam | Texnologiya | Versiya |
|--------|-------------|---------|
| **Til** | Python | 3.12+ |
| **Framework** | FastAPI | 0.115+ |
| **ASGI server** | uvicorn (dev) / gunicorn + uvicorn workers (prod) | latest |
| **DB** | PostgreSQL | 16+ |
| **ORM** | SQLAlchemy | 2.0+ (async) |
| **DB driver** | asyncpg | latest |
| **Migrations** | Alembic | latest |
| **Validation** | Pydantic | 2.x |
| **Auth (JWT)** | python-jose[cryptography] | latest |
| **Password hash** | passlib[bcrypt] (kelajak — admin login) | latest |
| **Storage client** | minio | latest (S3-compatible) |
| **Cache / queue** | Redis | 7+ |
| **HTTP client** | httpx | latest (Telegram Gateway, Google) |
| **Google auth** | google-auth | latest |
| **Image processing** | Pillow | latest |
| **Lint / format** | ruff + ruff format | latest |
| **Type check** | mypy yoki pyright | latest |
| **Test** | pytest + pytest-asyncio + httpx | latest |
| **Package manager** | uv yoki poetry | latest |

#### Admin panel (`admin/`)

| Qatlam | Texnologiya | Versiya |
|--------|-------------|---------|
| **Framework** | Next.js (App Router) | 15+ |
| **Til** | TypeScript | 5.6+ |
| **Admin** | Refine | 4+ |
| **UI** | shadcn/ui | latest |
| **CSS** | Tailwind CSS | 4+ |
| **Forms** | react-hook-form + zod | latest |
| **HTTP / data** | TanStack Query (Refine ichida) | latest |
| **Charts** | recharts | latest |
| **Icons** | lucide-react | latest |
| **API client** | OpenAPI generator (FastAPI sxemasi'dan) | — |
| **Lint / format** | ESLint + Prettier | latest |

#### Mobil ilova (`lib/` — root'da)

| Qatlam | Texnologiya | Versiya |
|--------|-------------|---------|
| **Mobile framework** | Flutter | 3.38+ |
| **Til** | Dart | 3.10+ |
| **State** | provider (ChangeNotifier) | ^6.1.2 (TODO: Riverpod) |
| **Routing** | Navigator (default) | — (TODO: go_router) |
| **HTTP client** | dio + dio_cache_interceptor | latest (Supabase'dan keyin) |
| **Auth storage** | flutter_secure_storage | latest |
| **Auth providers** | google_sign_in + (Telegram via backend) | latest |
| **Lokal cache** | Hive | ^2.2.3 |
| **Models** | freezed + json_serializable | ^2.4.4 / ^4.9.0 |
| **Image cache** | cached_network_image | ^3.4.1 |
| **Image picker** | image_picker | ^1.1.2 |
| **Image compress** | flutter_image_compress | latest (yangi) |
| **Video** | video_player + video_thumbnail | ^2.9.3 / ^0.5.3 |
| **Carousel** | carousel_slider | ^5.0.0 |
| **OTP input** | pinput | ^5.0.1 |
| **Phone mask** | mask_text_input_formatter | ^2.9.0 |
| **Maps** | map_launcher | ^3.5.0 |
| **URL launcher** | url_launcher | ^6.3.1 |
| **Localization** | flutter_localizations + intl | ^0.20.2 |
| **Responsive** | responsive_framework | ^1.5.1 |
| **Shimmer** | shimmer | ^3.0.0 |
| **SVG** | flutter_svg | ^2.0.16 |
| **QR** | qr_flutter | ^4.1.0 |
| **Linter** | flutter_lints | ^5.0.0 (TODO yangilash) |

### 5.2. Apparat talablari

#### Mobile (foydalanuvchi qurilmasi)

- **iOS:** iPhone 6s+ (iOS 12.0+).
- **Android:** API 21+ (Lollipop, Android 5.0+).
- **RAM:** kamida 2 GB.
- **Storage:** ~80 MB ilova + cache.
- **Tarmoq:** 3G+, offline rejim qisman (cached image + Hive user).

#### Server (backend + admin)

- **VPS provider:** TODO (Hetzner CX22 yoki DigitalOcean — foydalanuvchi tanlaydi).
- **OS:** Ubuntu 24.04 LTS.
- **CPU:** 2 vCPU (boshlanishida).
- **RAM:** 4 GB.
- **Disk:** 40 GB SSD (10 GB system + 30 GB data + media).
- **Network:** 1 Gbps + 20 TB/oy.

> **Login va parollar:** TODO — foydalanuvchi tomonidan keyinroq beriladi.

### 5.3. Infrastruktura

#### Production server tuzilmasi

```
[Mobile + Admin browser]
        │ HTTPS
        ▼
[Cloudflare DNS + SSL] (ixtiyoriy, kelajak)
        │
        ▼
   [nginx :443]
   ├── /api/        → backend (FastAPI :8000, gunicorn 4 worker)
   ├── /admin/      → admin static (Next.js build, /var/www/admin)
   └── /media/      → MinIO :9000 (public bucket)
        │
        ├─ PostgreSQL :5432 (lokal yoki managed)
        ├─ Redis :6379 (cache + rate limit)
        └─ MinIO :9000 (S3 storage)
```

#### Servislar (systemd)

| Service | Port | Vazifasi |
|---------|------|----------|
| `discoveruzb-api.service` | 8000 | FastAPI (gunicorn) |
| `nginx.service` | 80, 443 | Reverse proxy + SSL |
| `postgresql.service` | 5432 | DB |
| `redis-server.service` | 6379 | Cache + rate limit |
| `minio.service` | 9000, 9001 | S3 storage + console |

#### Lokal development

`docker-compose` orqali (`infra/docker-compose.yml`):

- `postgres:16` (port 5432)
- `redis:7-alpine` (port 6379)
- `minio/minio:latest` (port 9000 + 9001 console)
- `backend` (FastAPI, port 8000, hot-reload)

Mobile va admin lokal'da o'z dev server'lari bilan ishlaydi.

#### Build / release

| Komponent | Vazifa |
|-----------|--------|
| Backend | `docker build -t backend .` + `systemctl restart` (CI/CD'da) |
| Admin | `pnpm build` + nginx static fayllari yangilanadi |
| Mobile (iOS) | `flutter build ipa` → App Store Connect |
| Mobile (Android) | `flutter build appbundle` → Play Console |

> **TODO:** GitHub Actions CI/CD (lint + test + build + deploy).

### 5.4. Tashqi servislar

| Servis | Maqsad | Konfiguratsiya |
|--------|--------|----------------|
| **Telegram Gateway** (`gateway.telegram.org`) | OTP yuborish va tekshirish (SMS o'rniga) | `TELEGRAM_GATEWAY_TOKEN` |
| **Google OAuth 2.0** | Google Sign-In ID token verifikatsiyasi | `GOOGLE_CLIENT_ID_IOS`, `GOOGLE_CLIENT_ID_ANDROID`, `GOOGLE_CLIENT_ID_WEB` |
| **OpenWeatherMap** | Ob-havo | `OPENWEATHER_API_KEY` (mobile'da `--dart-define`) |
| **DevSMS** (fallback) | Telegram'siz user'lar uchun SMS | `DEVSMS_TOKEN` (kelajak) |

Backend'da barcha sirlar `.env` fayl yoki environment variable'lar
orqali. Production'da `systemd` `EnvironmentFile=` yoki Secrets Manager.

---

## 6. MA'LUMOTLAR STRUKTURASI

### 6.1. Umumiy ma'lumot

- **DBMS:** PostgreSQL 16+ (lokal yoki managed).
- **Schema versiyalash:** Alembic (`backend/alembic/versions/`).
- **ORM:** SQLAlchemy 2.0 (async) — `backend/app/models/`.
- **Snake_case:** barcha jadval va ustun nomlari `snake_case`'da
  (eski Supabase `phoneNumber`, `placeName` kabi camelCase'dan voz
  kechiladi).

### 6.2. Asosiy jadvallar

#### 6.2.1. `users`

```sql
CREATE TABLE users (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  phone           TEXT UNIQUE,                    -- Telegram auth uchun
  email           TEXT UNIQUE,                    -- Google auth uchun
  google_sub      TEXT UNIQUE,                    -- Google sub ID
  telegram_id     BIGINT UNIQUE,                  -- Telegram user ID
  fullname        TEXT NOT NULL,
  img_url         TEXT,
  role            TEXT NOT NULL DEFAULT 'user',   -- user | moderator | admin
  is_banned       BOOLEAN NOT NULL DEFAULT false,
  language        TEXT NOT NULL DEFAULT 'uz',     -- uz | ru | en
  device_id       TEXT,
  device_type     TEXT,                           -- ios | android
  device_token    TEXT,                           -- FCM/APNS push token
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  last_login_at   TIMESTAMPTZ
);

CREATE INDEX idx_users_phone ON users(phone) WHERE phone IS NOT NULL;
CREATE INDEX idx_users_email ON users(email) WHERE email IS NOT NULL;
CREATE INDEX idx_users_role ON users(role);
```

#### 6.2.2. `posts`

```sql
CREATE TABLE posts (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  author_id       UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  place_name      TEXT NOT NULL,
  place_info      TEXT NOT NULL,
  address         TEXT NOT NULL,
  type            TEXT NOT NULL,                  -- category slug
  source          TEXT,
  price           TEXT,                           -- "Bepul", "30 000 so'm"
  phone_numbers   TEXT[] NOT NULL DEFAULT '{}',
  images          TEXT[] NOT NULL DEFAULT '{}',   -- MinIO URL'lar
  lat             DOUBLE PRECISION NOT NULL,
  lon             DOUBLE PRECISION NOT NULL,
  like_count      INTEGER NOT NULL DEFAULT 0,
  is_published    BOOLEAN NOT NULL DEFAULT true,  -- moderatsiya uchun
  created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_posts_type ON posts(type);
CREATE INDEX idx_posts_author ON posts(author_id);
CREATE INDEX idx_posts_created ON posts(created_at DESC);
CREATE INDEX idx_posts_likes ON posts(like_count DESC);
CREATE INDEX idx_posts_published ON posts(is_published);
-- Search uchun:
CREATE INDEX idx_posts_name_trgm ON posts USING gin(place_name gin_trgm_ops);
```

#### 6.2.3. `post_likes`

```sql
CREATE TABLE post_likes (
  user_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  post_id    UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, post_id)
);
CREATE INDEX idx_post_likes_post ON post_likes(post_id);
```

#### 6.2.4. `post_saves`

```sql
CREATE TABLE post_saves (
  user_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  post_id    UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, post_id)
);
```

#### 6.2.5. `comments`

```sql
CREATE TABLE comments (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id     UUID NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
  author_id   UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  body        TEXT NOT NULL,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_comments_post ON comments(post_id, created_at DESC);
```

#### 6.2.6. `galleries`

```sql
CREATE TABLE galleries (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id    UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  place_name  TEXT NOT NULL,
  images      TEXT[] NOT NULL DEFAULT '{}',
  date        DATE,
  is_public   BOOLEAN NOT NULL DEFAULT false,
  share_slug  TEXT UNIQUE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_galleries_owner ON galleries(owner_id);
```

#### 6.2.7. `categories` (yangi)

```sql
CREATE TABLE categories (
  slug      TEXT PRIMARY KEY,                     -- 'historical', 'mountain'
  name_uz   TEXT NOT NULL,
  name_ru   TEXT NOT NULL,
  name_en   TEXT NOT NULL,
  icon_url  TEXT,
  sort_order INTEGER NOT NULL DEFAULT 0,
  is_active BOOLEAN NOT NULL DEFAULT true
);
```

#### 6.2.8. `auth_otps`

```sql
CREATE TABLE auth_otps (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  phone       TEXT NOT NULL,
  code_hash   TEXT NOT NULL,                      -- bcrypt hash
  request_id  TEXT,                               -- Telegram Gateway request_id
  attempts    INTEGER NOT NULL DEFAULT 0,
  verified    BOOLEAN NOT NULL DEFAULT false,
  expires_at  TIMESTAMPTZ NOT NULL,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_auth_otps_phone ON auth_otps(phone, created_at DESC);
```

#### 6.2.9. `refresh_tokens`

```sql
CREATE TABLE refresh_tokens (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token_hash  TEXT NOT NULL UNIQUE,               -- SHA-256
  expires_at  TIMESTAMPTZ NOT NULL,
  revoked_at  TIMESTAMPTZ,
  user_agent  TEXT,
  ip_address  INET,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now()
);
CREATE INDEX idx_refresh_tokens_user ON refresh_tokens(user_id);
```

#### 6.2.10. `audit_log` (kelajak)

Admin amallari uchun — kim, qachon, nima o'zgartirgan.

### 6.3. Storage bucket'lar (MinIO)

| Bucket | Public | Tafsif |
|--------|--------|--------|
| `media-public` | ✅ | Post rasmlari, profil avatarlari |
| `media-private` | ❌ | Galereya rasmlari (presigned URL bilan) |

Folder konvensiyasi:

- `media-public/avatars/<user_id>/<timestamp>.webp`
- `media-public/posts/<post_id>/<timestamp>.webp`
- `media-private/galleries/<gallery_id>/<timestamp>.webp`

### 6.4. Migratsiyalar

`backend/alembic/versions/` papkada timestamp + slug formatda:

```
20260510_0001_initial_schema.py
20260510_0002_add_categories_table.py
...
```

Komandalar:

```bash
# Yangi migratsiya
alembic revision --autogenerate -m "add categories table"

# Qo'llash
alembic upgrade head

# Bekor qilish
alembic downgrade -1
```

### 6.5. Eski Supabase'dan migratsiya

`backend/scripts/migrate_from_supabase.py` (Sprint 5) — Supabase eski
3 jadvalidan yangi PostgreSQL'ga ko'chirish skripti:

1. Eski `users` → yangi `users` (UUID generatsiya, role='user').
2. Eski `posts` → yangi `posts` + `post_likes` + `post_saves` (JSONB
   array → alohida jadvallarga).
3. Eski `gallery` → yangi `galleries`.
4. Supabase Storage URL'larni yuklab olib, MinIO'ga upload.

---

## 7. INTERFEYS TALABLARI

### 7.1. REST API (Supabase auto-generated)

- **Base URL:** `https://lfyzugkyoopolbmifvxo.supabase.co/rest/v1/`.
- **Autentifikatsiya:** `Authorization: Bearer <jwt>` + `apikey: <anon>`.
  Hozirda anonymous client ishlatilyapti.
- **Format:** JSON (PostgREST).
- **Pagination:** `Range` header yoki `.range(0, 19)` (TODO: joriy etish).
- **CORS:** Supabase tomonidan `*` (mobile uchun ahamiyatsiz).

### 7.2. Mobil UI

- **Dizayn tili:** Material 2 (TODO: Material 3 ga migratsiya).
- **Asosiy rang:** Teal (`Colors.teal.shade400`–`shade700`).
- **Theme:** Light (hardcoded `ThemeMode.light` — TODO: foydalanuvchi tanlovi).
- **Tillar:** O'zbek (asosiy), Rus, Ingliz.
- **Bottom navigation:** Home, Search, Add, Account.
- **Splash:** Linear gradient (`0C8FCC` → `0CBFCC`), "Created by MrDil".
- **Responsive:** `responsive_framework` 4 breakpoint
  (Mobile/Tablet/Desktop/4K).

### 7.3. Localization

- `lib/l10n/app_en.arb`, `app_ru.arb`, `app_uz.arb`.
- Auto-generated `app_localizations.dart` (`flutter gen-l10n`).
- Konfiguratsiya: `l10n.yaml`.
- TODO: hardcoded matnlarni topish va ARB'ga ko'chirish (audit:
  "Turistik hududlar", "Manba:", "Open with", "GO", "Created by MrDil").

---

## 8. AMALGA OSHIRISH BOSQICHLARI

### 8.1. Bosqich 1: MVP (✅ tugagan)

- [x] Telefon + OTP login (DevSMS).
- [x] Joylar ro'yxati (famous, recommend, new).
- [x] Joy tafsilotlari (rasm carousel, manzil, ob-havo).
- [x] Layk va saqlash.
- [x] Izoh qoldirish.
- [x] Profil va o'z postlari.
- [x] Galereya (private gallery).
- [x] Qidiruv.
- [x] 3 til UI (UZ/RU/EN).
- [x] Supabase migratsiya (Firebase'dan).
- [x] Play Market'da chiqish (version 1.2.1+11, version code 5).

### 8.2. Bosqich 2: Xavfsizlik tuzatish (🔄 boshlanishi kerak)

- [ ] Hardcoded sirlar `--dart-define`/`.env` ga ko'chirish.
- [ ] MySQL parol o'zgartirish + `mysql_service.dart` o'chirish.
- [ ] Supabase Phone Auth'ga to'liq o'tish.
- [ ] OTP'ni server-side tekshirish (Edge Function yoki Supabase Auth).
- [ ] RLS politikalarni qayta yozish.
- [ ] Hardcoded admin tekshiruvni `role` claim'ga ko'chirish.
- [ ] `users.password` ustunni o'chirish.
- [ ] Storage'da private bucket (galereya uchun).

### 8.3. Bosqich 3: Performance & Modernizatsiya (rejada)

- [ ] Postlar pagination (`.range()`).
- [ ] Bitta `posts` query'ga birlashtirish (famous/recommend/new).
- [ ] `Selector` joriy etish (Provider rebuild minimal).
- [ ] `IndexedStack` `MainPage`'da.
- [ ] Image kompressiya (WebP, `flutter_image_compress`).
- [ ] Weather API cache (15 daqiqa).
- [ ] Material 3 + `useMaterial3: true`.
- [ ] Dark mode foydalanuvchi tanlovi.
- [ ] `flutter_lints: ^5.0.0` + qat'iy rules.
- [ ] `super.key` migratsiya.
- [ ] `withOpacity` → `withValues(alpha:)`.

### 8.4. Rejadagi bosqichlar

#### Qisqa muddatli (1–2 hafta)

- [ ] Hardcoded sirlarni `--dart-define`'ga ko'chirish.
- [ ] MySQL credentials rotatsiya.
- [ ] CI/CD (GitHub Actions: lint + format + test + build).
- [ ] Sentry yoki Crashlytics integratsiyasi.

#### O'rta muddatli (1 oy)

- [ ] Riverpod yoki Bloc'ga migratsiya.
- [ ] go_router bilan deep linking.
- [ ] Repository pattern + DI (get_it).
- [ ] Unit test ViewModels uchun.
- [ ] Widget test asosiy ekranlar uchun.

#### Uzoq muddatli (3–6 oy)

- [ ] Realtime subscription (yangi izoh, layk).
- [ ] Push notifikatsiya (FCM yoki OneSignal).
- [ ] Offline-first (Hive sync).
- [ ] Booking/payment integratsiyasi (Click, Payme).
- [ ] Web versiya (Flutter Web).

---

## 9. JORIY HOLAT

> Bu — TZ ning eng tez-tez yangilanadigan bo'limi. Har Kategoriya A
> o'zgarishida shu yerni yangilang (`CLAUDE.md §3`).

### 9.1. Bajarilgan ishlar (qisqacha)

- Mobil ilova — Play Market'da, version 1.2.1+11.
- Supabase migratsiya — Firebase'dan to'liq ko'chirilgan (kodda eslatma'lar qoldi).
- 3 til UI — UZ/RU/EN ARB fayllarda.
- DevSMS OTP — ishlaydi (test rejim bilan).

#### ✅ Yaqinda tugallangan (2026-05-12)

- **Sprint 12 (yakunlangan) — Lokal end-to-end test:**
  - `discoveruzb` DB yaratildi, 2 alembic migration qo'llandi.
  - `backend/scripts/seed.py` — 8 kategoriya + 3 user + 5 real
    O'zbekiston joy (Registon, Chimgan, Buxoro Ark, Toshkent kuranti,
    Termiz).
  - `backend/.env` lokal sozlamalar (dev rejim, bo'sh API keys).
  - Backend `uvicorn` :8000'da ishladi.
  - 6 ta endpoint real ma'lumot bilan smoke test'dan o'tdi: health,
    /, categories, posts list, OTP send/verify (JWT bilan), /auth/me,
    external-reviews (graceful error), stats/dashboard.
  - Pydantic Settings v2 list parsing bug tuzatildi.
  - `Makefile` (28 buyruq), `docs/local-dev-guide.md` (10 bo'lim).
  - **Yangi developer 1 buyruqda lokal'da ishlay oladi:** `make setup`.

- **Sprint 11 (yakunlangan) — Admin panel: Post edit + place IDs:**
  - `posts/edit/[id]` sahifa (yangi route, 11.3 kB).
  - 2 ta katta card: "Asosiy ma'lumotlar" (Textarea, Switch),
    "Tashqi xarita ID lari" (Google/Yandex/2GIS place ID inputs).
  - Sidebar — `ExternalReviewsPanel`: per-source summary
    (rating + count + last_fetched_at), per-source refresh tugmasi,
    tabbed reviews preview.
  - 3 ta yangi shadcn komponent: Textarea, Switch, Tabs.
  - Posts list'da har post yonida Edit (Pencil) tugmasi.
  - Refine 4 migration: `isLoading` → `isPending`.
  - `pnpm build` ✓.

- **Sprint 10 (yakunlangan) — Mobile UI: external reviews:**
  - Yangi Freezed model: `ExternalReviewsResponse`, `SourceSummary`,
    `ExternalReview` + `ReviewSourceIds` konstantalari.
  - `Place` modelga 3 ta yangi field (`googlePlaceId`, `yandexPlaceId`,
    `gisPlaceId`) + `hasExternalReviews` extension.
  - `DataService.loadExternalReviews` va `refreshExternalReviews`.
  - `ExternalReviewsVM` — tab tanlovi, mahalliy cache, force refresh.
  - `ExternalReviewsSection` widget — pill tabbar (Google / Yandex /
    2GIS), rating chip, review card avatar + matn, error/empty holatlar.
  - `DetailsOfPlace` ga integratsiya.
  - `main.dart` ga VM qo'shildi.
  - 4 ta yangi l10n kalit (UZ/RU/EN).
  - Verifikatsiya: `flutter analyze` 0 error, iOS build 54.1s ✓.

#### ✅ Yaqinda tugallangan (2026-05-11)

- **Sprint 9 (yakunlangan) — Tashqi xaritalardan kommentlar:**
  - Yangi DB modellari: `ExternalReview`, `PlaceFetchLog` + 3 ta
    place_id field `Post`'da.
  - 3 ta provider: Google Places API (New), Yandex Maps Search,
    2GIS public-api.reviews — abstract `BaseReviewProvider`.
  - `ReviewAggregator` — TTL cache, parallel HTTP fetch + serial
    DB upsert, idempotent `on_conflict_do_update`.
  - 2 ta yangi endpoint: `GET /posts/{id}/external-reviews`,
    `POST .../refresh` (moderator+).
  - 7 ta yangi test → **77/77 passed**.
  - `docs/external-reviews-setup.md` — to'liq sozlash hujjati.

- **Sprint 8 (yakunlangan) — Backend integration testlari:**
  - 7 ta test fayl, **70 ta test passed**, 11.4s, coverage **69%**.
  - `conftest.py` — pytest fixtures (event_loop session-scope,
    db_engine + NullPool, db_session, ASGI client + dependency override,
    user/admin/moderator fixtures, mock Telegram/Google/MinIO).
  - Auth, users, posts, comments, galleries, categories, stats —
    barchasi qoplangan.
  - 2 ta bug topildi va tuzatildi (`db.refresh` + `selectinload`
    lazy-load masalasi `posts.py` va `comments.py`'da).

- **Sprint 7 (yakunlangan) — Android build + l10n + Google Sign-In hujjati:**
  - Android Gradle migratsiyasi: AGP 8.7, Kotlin 2.1, Gradle 8.9,
    Java 17, modern `pluginManagement` blok. `flutter build apk --debug` ✓.
  - 16 ta yangi l10n kalit auth oqimlari uchun (UZ/RU/EN).
  - Mobile auth ekranlarining hardcoded matnlari `app_localizations` ga.
  - `docs/google-signin-setup.md` — to'liq Google Cloud Console
    sozlash hujjati (iOS/Android/Web Client ID, SHA-1, URL scheme,
    Firebase **emas**).
  - Verifikatsiya: `flutter analyze` 0 error, admin `pnpm typecheck` ✓.

- **Sprint 6 (yakunlangan) — Mobile login UI (Telegram + Google):**
  - `LoginWithPhone` ekrani qayta yozildi — gradient fon, materialdek
    card, telefon input + "OTP yuborish" tugmasi + "Google bilan
    kirish" tugmasi.
  - `LoginViewModel.sendOtp()` backend `/auth/telegram/send-otp` orqali
    Telegram Gateway'ga so'rov yuboradi.
  - `OTPViewModel.attachPhone()` — OTP qaytarib yubormaslik uchun.
  - `OTPScreen`, `Registration`, `SplashPage` ekranlari yangi dizaynda.
  - `SplashViewModel` — JWT yaroqligini server tomonida tekshiradi.
  - `AuthService.signInWithGoogle()` — `google_sign_in` paketi orqali.
  - `flutter analyze` 0 error, iOS simulator build muvaffaqiyatli.

- **Sprint 4 (yakunlangan) — Admin panel skeleton:**
  - Next.js 15 (App Router) + TypeScript 5.7 + Tailwind 3.4 + shadcn/ui.
  - Refine 4 (auth provider + data provider) + TanStack Query.
  - Telefon + OTP login (`/auth/telegram/*` orqali) — admin/moderator
    rolli tekshiruv bilan.
  - Sidebar + topbar layout, light/dark theme, teal brand.
  - 7 ta route: `/login`, `/`, `/users`, `/posts`, `/comments`,
    `/galleries`, `/categories`.
  - Dashboard: 8 ta stat card + 2 ta chart.
  - Users: jadval + filter + role/ban/delete actions.
  - Posts: jadval + thumbnail + publish toggle + delete.
  - Categories: CRUD Dialog'i (UZ/RU/EN, zod validation).
  - Galleries: card grid moderatsiya ko'rinishi.
  - Build muvaffaqiyatli (0 xato).

#### ✅ Yaqinda tugallangan (2026-05-10)

- **Sprint 1 (yakunlangan) — Backend CRUD endpointlari:**
  - 8 ta router (auth, users, posts, comments, galleries, categories, stats, uploads).
  - **53 ta endpoint** Swagger'da ro'yxatda.
  - MinIO storage service + Pillow image optimization (WebP, max 1920px).
  - Pagination util, like/save atomic toggle, exception handlers.
  - Lokal venv'da boot test ✓.

- **Sprint 1 (qisman) — Backend skeleton + Mobile migratsiya:**
  - FastAPI backend skeleton (config, security, logging, DB, models,
    schemas, services, api/v1/auth router, main).
  - SQLAlchemy 2.0 async + Alembic + initial migration (10 ta jadval).
  - Telegram Gateway klient + Google ID token verifikatsiyasi.
  - JWT (access 1h + refresh 30d) + refresh token DB'da xeshlangan.
  - `infra/docker-compose.yml` (postgres + redis + minio + backend).
  - Mobile: `supabase_flutter` butunlay olib tashlandi.
  - Mobile: `ApiClient` (Dio + JWT auto-refresh + secure storage).
  - Mobile: `AuthService` Telegram Gateway + Google Sign-In oqimi.
  - Mobile: `DataService`, `FileService` backend REST API bilan.
  - Mobile: `Users` modeli snake_case + `role`/`language`/`is_banned`.
  - 0 compile error, 86 issue (info/warning, eski sifat).

- **Sprint 0 — Xavfsizlik tuzatish:**
  - `mysql_service.dart` + `mysql1` paket o'chirildi (legacy MySQL parol bilan).
  - Hardcoded sirlar `--dart-define` ga ko'chirildi (Supabase, DevSMS, OpenWeather).
  - `.env` / `.env.example` / `run_dev.sh` infratuzilmasi yaratildi.
  - `users.password` ustun olib tashlandi (model + SQL migration 001).
  - `users.role` field qo'shildi, hardcoded admin tekshiruvi (telefon va eski UID) o'chirildi.
  - RLS politikalar uchun `migrations/002_*.sql` (qat'iy) va `002a` (vaqtincha) yozildi.
  - `.gitignore` keskinlashtirildi (`.env`, signing keys, run scripts).
  - Test rejim telefon/OTP `--dart-define=TEST_PHONE/TEST_OTP` ga ko'chirildi.

#### ✅ Oldindan tugallangan (2026-04-01 atrofida)

- Supabase to'liq integratsiya (Firestore'dan keyin).
- Hive lokal cache (`person`, `restore` box).
- Galereya (private gallery) feature.
- Responsive breakpoints (Mobile/Tablet/Desktop/4K).

#### 🔄 Ishlab chiqilmoqda

- **Sprint 1 (yakunlangan ✅) — Backend CRUD endpointlari:**
  - 8 ta router, **53 ta endpoint** (auth, users, posts, comments,
    galleries, categories, stats, uploads).
  - Pagination utilitasi, like/save atomic toggle, MinIO storage
    (Pillow image optimization), global exception handler.
  - Lokal `python -c "from app.main import create_app"` ishladi.
- **Sprint 4 davomi — Admin panel hosil bo'lgan ish:**
  - Foydalanuvchini batafsil ko'rish + tahrirlash (drawer/modal).
  - Postni yangi yaratish/tahrirlash (multi-image upload + xarita).
  - Comments admin endpoint (`GET /api/v1/comments` qo'shilishi kerak).
  - Galleries-ni private bucket bilan signed URL orqali ko'rsatish.
  - Sozlamalar sahifasi (Telegram bot config, ko'p tilli matnlar).

- **Sprint 1.5 — Backend testlar va lokal docker run:**
  - pytest + httpx integration testlar (auth oqim, posts CRUD).
  - `docker compose up` orqali lokal stack ishga tushirish.
  - Postman/Insomnia collection (yoki to'g'ridan-to'g'ri Swagger UI).
- **Sprint 2 — Mobile UI refresh:**
  - `LoginWithPhone` — Telegram Gateway oqimi + Google Sign-In tugmasi.
  - Hardcoded matnlarni l10n'ga ko'chirish.
- **Sprint 3 — Admin panel:**
  - Next.js 15 + Refine 4 + shadcn/ui boilerplate.
  - Auth (admin login).
  - Dashboard, users, posts, gallery, categories sahifalari.
- **Sprint 4 — Production deploy:**
  - VPS sozlash (Ubuntu 24.04 + nginx + systemd).
  - Domen + SSL (Let's Encrypt).
  - GitHub Actions CI/CD.

### 9.2. Ishlamayotgan yoki tugallanmagan qismlar

> Honest bo'ling — texnik qarzni yashirmang.

**Mobil ilova:**

- `mysql_service.dart` — dead code, lekin parol Git tarixida.
- `loadRecommendPlace` — `insert(0, ...)` orqali sortni teskari aylantiradi (bug).
- `loadPosts` va `loadNewAdded` — duplikat metodlar.
- `LoginViewModel.submitPhoneNumber` — faqat 1 sek delay, hech narsa yubormaydi.
- `account_vm.fetchMyPosts` — "Mening postlarim" aslida liked postlarni
  yuklaydi (UX/logic mos kelmaydi).
- `home_page.dart` line 44 — `"Turistik hududlar"` hardcoded matn (l10n emas).
- `account_page.dart` line 222 — eski Firebase UID admin tekshirig'ida qoldi.
- `splash_page.dart` — `Future.microtask` cheksiz navigatsiya ehtimoli.
- 36 ta `debugPrint` + 4 ta `print()` (production'da o'chirish kerak).
- Test fayllari yo'q.

**Backend (Supabase):**

- RLS politikalar `Allow all` — xavfsizlik nol.
- Pagination yo'q — barcha postlar bir martada keladi.
- `posts.id` TEXT (string), Freezed model'da `String?` — type safety zaif.

**Umumiy:**

- Hardcoded sirlar (Supabase, DevSMS, OpenWeather, MySQL).
- CI/CD yo'q.
- Crashlytics/Sentry yo'q.
- `flutter_lints: ^2.0.0` (eski, hozirgi 5.0.0+).

### 9.3. Kodning kuchli tomonlari

1. **MVVM tuzilma:** ViewModel'lar `view_models/` da ajratilgan, UI dan
   business logic ajralgan (Provider + ChangeNotifier).
2. **Freezed model'lar:** `places_model`, `users_model`, `gallery_model`,
   `comments`, `weather_model` — to'liq immutable, copyWith bilan.
3. **3 tilli localization:** O'zbek/Rus/Ingliz ARB fayllar to'liq
   tuzilgan, default `flutter gen-l10n` orqali.
4. **Responsive:** `responsive_framework` 4 ta breakpoint bilan
   (mobile/tablet/desktop/4K).
5. **Image cache:** `cached_network_image` to'g'ri ishlatilgan.

### 9.4. Kodning zaif tomonlari

> `docs/security-rules.md` dagi "Hozirgi xavfsizlik qarzi" bilan sinxron
> turing.

1. **Xavfsizlik:**
   - ~~Hardcoded credentials (Supabase, MySQL, DevSMS, OpenWeather)~~
     ✅ Sprint 0 (2026-05-10): `--dart-define`'ga ko'chirildi.
   - **OTP client-side tekshiriladi** — bypass qilish oson. (Sprint 1)
   - **Random `userId`** (`DateTime.now().millisecondsSinceEpoch`)
     generatsiya qilinadi, Supabase Auth ishlatilmaydi. (Sprint 1)
   - ~~`users.password` plain-text ustun~~ ✅ Sprint 0: model'dan olib
     tashlandi, DB migration `001` SQL Editor'da ishga tushirilishi kerak.
   - ~~Hardcoded admin telefon va eski Firebase UID~~ ✅ Sprint 0:
     `users.role` ga ko'chirildi.
   - **RLS `Allow all`** — `migrations/002_*.sql` yozildi, lekin
     Supabase'da hali qo'llanmagan. (Sprint 1)
   - **Sirlar Git tarixida** — Sprint 0'dan oldingi commit'larda hardcoded
     qiymatlar bor. `git filter-repo` bilan tozalash + Supabase/DevSMS/
     OpenWeather kalitlarini rotatsiya qilish kerak. (Darhol)
2. **Testlar:** 0% coverage. `test/` papkasi yo'q.
3. **Logging:** `debugPrint` va `print` aralash, structured logging yo'q.
4. **Monitoring:** Sentry/Crashlytics yo'q. Production crash'larni bilmaymiz.
5. **Performance:**
   - Pagination yo'q.
   - 4 ta alohida fetch `home_vm.refreshAllData`'da.
   - `Provider.of(listen:true)` butun `HomePage` rebuild.
   - `SingleChildScrollView` + nested `ListView.builder`.
6. **Arxitektura:** DI yo'q (static metodlar), routing tizimi yo'q
   (`Navigator.push` har joyda), Repository pattern yo'q.
7. **Modernlik:** Flutter Lints v2 (eski), Material 2, `withOpacity`
   deprecated, `Key? key, super(key: key)` eski stil.

### 9.5. Keyingi qadamlar (prioritetlangan)

**Darhol (blokirlovchi xavfsizlik):**

1. MySQL parolini o'zgartirish + `mysql_service.dart` + `mysql1` paketni
   o'chirish.
2. Supabase/DevSMS/OpenWeather kalitlarini `--dart-define`'ga ko'chirish.
3. Git tarixidan sirlarni tozalash (`git filter-repo`).
4. RLS politikalarni qayta yozish (faqat ega o'zgartira oladi).

**Yaqin orada (muhim):**

5. Supabase Phone Auth'ga migratsiya (DevSMS o'rniga yoki adapter sifatida).
6. OTP'ni server-side tekshirishga o'tkazish.
7. `users.password` ustunni o'chirish.
8. Hardcoded admin tekshiruvni `role` claim'ga ko'chirish.

**Texnik qarz:**

9. Pagination joriy etish (`.range`).
10. Riverpod/Bloc va go_router migratsiya.
11. Repository pattern + DI.
12. Unit + widget test infratuzilma.
13. CI/CD (GitHub Actions).
14. Material 3 + Dark mode.
15. `flutter_lints: ^5.0.0` + qat'iy rules.

---

## ILOVALAR

### A. Asosiy fayllar ro'yxati

```
discoveruzb/
├── lib/
│   ├── main.dart                 # Entry point — Hive + Supabase + Provider tree
│   ├── constants/                # colors, data_sources, deep_links
│   ├── l10n/                     # app_en.arb, app_ru.arb, app_uz.arb
│   ├── models/                   # Freezed: places, users, gallery, comments, weather, types, media
│   ├── service/                  # supabase, data, file, sms, hive, pref, auth, route, themes, utils, mysql (legacy)
│   ├── view_models/              # 14 ta ChangeNotifier
│   ├── screens/
│   │   ├── introPages/           # splash, login, otp, registration
│   │   ├── pageViewPages/        # main_screen + home, account_pages, category_page, private_gallery
│   │   ├── components/           # home_header, product_box, title_name, dropdown_regions
│   │   └── (root: comment_page, search_page, search_result, recommendes, famouses)
│   └── widgets/                  # custom_textfield, hero_image, loading, nodata, shimmer_loading
├── android/                      # Android build (Gradle, Kotlin, signing)
├── ios/                          # iOS build (Xcode, Swift, Info.plist)
├── assets/
│   ├── images/
│   └── icons/
├── Keys/                         # signing keys (TODO: tekshirish — Git tarixda bormi)
├── supabase_setup.sql            # Initial schema
├── supabase_fix.sql              # Fix patch
├── pubspec.yaml                  # 26 ta dependency
├── analysis_options.yaml         # flutter_lints v2 (TODO: v5)
├── l10n.yaml                     # Localization config
├── run_app.command               # Quick run script
├── README.md
├── CLAUDE.md                     # AI yordamchi qoidalari (root)
└── docs/
    ├── CHANGELOG.md
    ├── coding-standards.md
    ├── security-rules.md
    └── TZ.md                     # Mazkur hujjat
```

### B. Environment o'zgaruvchilar

`--dart-define` orqali (yoki `flutter_dotenv` + `.env`):

```
SUPABASE_URL=https://<project>.supabase.co
SUPABASE_ANON_KEY=<anon_key>
DEVSMS_TOKEN=<bearer_token>
DEVSMS_BASE_URL=https://devsms.uz/api/send_sms.php
OPENWEATHER_API_KEY=<api_key>
DEV_MODE=false
```

Kodda o'qish:

```dart
const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
```

Build vaqtida:

```bash
flutter run --dart-define=SUPABASE_URL=https://... \
  --dart-define=SUPABASE_ANON_KEY=... \
  --dart-define=DEVSMS_TOKEN=...
```

### C. Build / Release komandalar

**Lokal run:**

```bash
flutter run -d <device-id>
# yoki:
./run_app.command
```

**Build (release):**

```bash
# Android (APK)
flutter build apk --release --dart-define=SUPABASE_URL=...

# Android (Play Store AAB)
flutter build appbundle --release

# iOS
flutter build ipa --release
```

**Codegen (Freezed/JSON):**

```bash
dart run build_runner build --delete-conflicting-outputs
```

**Lint / format:**

```bash
flutter analyze
dart format lib/ --set-exit-if-changed
```

**Localization regenerate:**

```bash
flutter gen-l10n
```

**Supabase schema reset (dev):**

```bash
# Supabase SQL Editor'da supabase_setup.sql ni ishga tushiring
```

---

**Hujjat oxiri.**
