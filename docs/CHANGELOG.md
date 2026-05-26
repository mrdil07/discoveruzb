# CHANGELOG

Loyiha o'zgarishlari tarixi. Eng yangi yozuvlar — yuqorida.

Format va kategoriyalar haqida: `CLAUDE.md §3` ga qarang.

---

## 2026-05-12 — Sprint 13: Tourism redesign + bug fixes

### Bug fixes (Sprint 12 keyin)

#### `lib/service/data_service.dart`
**Modul:** Mobile — Backend response moslik
**Kategoriya:** B
**Sabab:** Profil sahifasidagi DIO exception. Backend
`/posts/famous`, `/recommend`, `/search`, `/me/liked`, `/me/saved` —
to'g'ridan-to'g'ri `List` qaytaradi (paginated emas). Mobile esa
`Map<String, dynamic>` kutardi va `items` field'ini olishga harakat
qilardi. Yangi `_parseDirectList()` helper qo'shildi; 5 ta metodning
type signature `List<dynamic>`'ga o'zgartirildi.

#### `lib/screens/introPages/{login,otp,registration,splash}.dart`
**Modul:** Mobile — auth ekranlar pastki oq qism fix
**Kategoriya:** B
**Sabab:** iPhone home bar joyida oq SafeArea ko'rinardi. Tuzilma teskari
qilindi: `Scaffold(backgroundColor) > Container(gradient + double.infinity)
> SafeArea > content`.

### Tourism Redesign

#### `lib/constants/colors.dart` (oldin bo'sh edi — to'liq yangi)
**Modul:** Mobile — design tokens
**Kategoriya:** A
**Sabab:** Markazlashtirilgan dizayn tizimi: 4 palitra (primary deep
teal, accent saffron, terracotta, neutrals), spacing tokens (4pt grid),
border radii, shadow presets, gradient constants.

#### `lib/service/themes.dart`
**Modul:** Mobile — Material 3 tema
**Kategoriya:** A
**Sabab:** Material 3 `useMaterial3: true`, `ColorScheme.fromSeed`,
modern typography (display/headline/title/body/label, hammasi negative
letter-spacing katta o'lchamlar uchun), card/button/input themes.

#### `lib/screens/components/product_box.dart` (qayta yozildi)
**Modul:** Mobile — Hero card
**Kategoriya:** A
**Sabab:** Eski sodda card → Full-bleed rasm + gradient overlay +
oq matn ustida (Airbnb pattern). Kategoriya badge (saffron pill),
like count chip, slide-in transition.

#### `lib/screens/components/home_header.dart` (qayta yozildi)
**Modul:** Mobile — Greeting + search
**Kategoriya:** A
**Sabab:** Vaqt-bog'liq salom (tong/kun/kech/tun), pill search bar →
`DraggableScrollableSheet` modal (Airbnb pattern).

#### `lib/screens/components/title_name.dart` (qayta yozildi)
**Modul:** Mobile — Section header
**Kategoriya:** B
**Sabab:** Title + subtitle + arrow, modern weight, optional callback.

#### `lib/screens/pageViewPages/home/home_page.dart` (qayta yozildi)
**Modul:** Mobile — Home page
**Kategoriya:** A
**Sabab:** `CustomScrollView + Slivers` (bouncing physics), `_Section`
wrapper: skeleton loaders, empty state, content. Brand color
RefreshIndicator.

#### `lib/screens/pageViewPages/main_screen.dart` (qayta yozildi)
**Modul:** Mobile — Bottom navigation
**Kategoriya:** A
**Sabab:** Custom `_ModernBottomNav`: 4 tab animated, `AnimatedSwitcher`
(outline ↔ filled ikonka), brand color highlight.

#### `lib/screens/pageViewPages/category_page/detailsPlace.dart` (qayta yozildi)
**Modul:** Mobile — Joy tafsilotlari
**Kategoriya:** A
**Sabab:** SliverAppBar parallax hero carousel, floating top bar
(back + QR + weather), slide-up content card, action chips row,
horizontal info pills (Tur, Narx, Likes, Aloqa), gradient floating
"Xaritada ko'rsatish" CTA.

**Verifikatsiya:**
- `flutter analyze` — 0 error, 79 issue (eski qoldiq).
- `flutter run` — iOS sim'da launched, Xcode build 9.1s.
- Backend `/posts` 200 OK, login oqim ishlaydi.

---

## 2026-05-12 — Sprint 12: Lokal E2E — DB + seed + boot + dev guide

### `backend/.env` (yangi, gitignored)
**Modul:** Backend — lokal config
**Kategoriya:** B
**Sabab:** Lokal Homebrew Postgres'ga ulanish + bo'sh tashqi API
kalitlari (Telegram dev OTP, Google/Yandex/2GIS placeholder).
`DATABASE_URL`, `REDIS_URL`, JWT/SECRET, CORS uchun `localhost:3000`.

### `backend/app/core/config.py`, `app/main.py`
**Modul:** Backend — Pydantic Settings fix
**Kategoriya:** A
**Sabab:** `list[str]` env var Pydantic Settings v2'da JSON parse
qiladi va comma-separated qiymatni qabul qilmaydi. `allowed_hosts` va
`cors_origins` `str` saqlanadi, `_list` property orqali split qilinadi.
`main.py` `cors_origins_list` ishlatishga o'zgartirildi. `bcrypt<4.1`
pinned (passlib bilan moslik). `psycopg2-binary` Alembic sync uchun.

### `backend/scripts/seed.py` (yangi)
**Modul:** Backend — sample data seeder
**Kategoriya:** A
**Sabab:** Lokal development uchun real O'zbekiston ma'lumotlari bilan
DB to'ldirish:
- 8 ta kategoriya (historical, mountain, nature, museum, bazaar,
  religious, park, food) — UZ/RU/EN.
- 3 ta user: admin (`+998901111111`), moderator (`+998902222222`),
  user (`+998903333333`).
- 5 ta real turistik joy: Registon, Chimgan, Buxoro Ark, Toshkent
  kuranti, Termiz muzeyi — to'liq tavsif, real koordinata, Wikipedia
  rasm URL, real Google Place ID lar.
- Idempotent: qayta ishga tushirilsa duplicates yaratmaydi.

Foydalanish: `make seed` yoki `python -m scripts.seed`.

### `Makefile` (yangi, repo root)
**Modul:** Repo — convenience commands
**Kategoriya:** B
**Sabab:** 28 ta named target — backend/admin/mobile/DB/test/lint/format.
`make help` — barchasini ko'rsatadi rangli formatda.
`make setup` — yangi machine uchun bir buyruqda to'liq install.
`make status` — Postgres va backend holatini tekshiradi.
`make db-reset` — DB drop + recreate + migrate + seed.

### `docs/local-dev-guide.md` (yangi)
**Modul:** Hujjatlar — lokal dev qo'llanma
**Kategoriya:** B
**Sabab:** 10 bo'limli hujjat:
1. Tizim talablari (Postgres, Python, Node, Flutter).
2. Bir buyruq setup (`make setup`).
3. Bosqichma-bosqich qo'lda setup.
4. Login va test foydalanuvchilari (dev OTP oqim).
5. Tashqi xarita sharhlari.
6. Tezkor buyruqlar.
7. Tipik dev workflow.
8. Common errors (8 ta) va yechimlar.
9. Test infratuzilma.
10. Production farqi.

**Verifikatsiya (real lokal sinov):**
- `make db-create` — `discoveruzb` + `discoveruzb_test` ✓
- `make migrate` — 2 migration (0001_initial, 0002_external_reviews) ✓
- `make seed` — 8 cat + 3 user + 5 post ✓
- `make backend` → `uvicorn` :8000 ishladi
- 6 ta endpoint smoke test:
  - `GET /health` → `{"status":"ok"}` ✓
  - `GET /api/v1/categories` → 8 kategoriya ✓
  - `GET /api/v1/posts?size=2` → Registon + Chimgan ✓
  - `POST /api/v1/auth/telegram/send-otp` → `request_id` ✓
  - Backend log'dan OTP olib `verify-otp` → JWT ✓
  - `GET /api/v1/auth/me` (Bearer) → admin profil ✓
  - `GET /api/v1/posts/{id}/external-reviews` → 3 source error
    summary ("API_KEY sozlanmagan", "place_id sozlanmagan") ✓
  - `GET /api/v1/stats/dashboard` (admin Bearer) → 3 user, 5 post ✓

**Topilgan bug'lar (tuzatildi):**
1. Pydantic Settings v2 list[str] env parsing — `str` + property.
2. `psycopg2-binary` Alembic sync uchun yetishmasdi.

---

## 2026-05-12 — Sprint 11: Admin panel — Post edit + place IDs + Reviews panel

### `admin/src/app/(dashboard)/posts/edit/[id]/page.tsx` (yangi)
**Modul:** Admin — Post edit sahifa
**Kategoriya:** A
**Sabab:** Posts list'da har post yonida "Edit" tugmasi bor edi, lekin
edit sahifa hali yo'q edi. Yangi sahifa to'liq form bilan:
- **Asosiy ma'lumotlar** card: `place_name`, `address`, `type`,
  `price`, `place_info` (Textarea), `source`, `lat`/`lon` (number),
  `is_published` (Switch).
- **Tashqi xarita ID lari** card: `google_place_id`, `yandex_place_id`,
  `gis_place_id` — `placeholder` va hint matnlar bilan, hujjatga
  havola.
- **Sidebar:** `ExternalReviewsPanel` — per-source summary card'lar +
  refresh tugmalari + tabbed reviews preview.
- Zod schema validation, react-hook-form, optimistic toast.
**TZ ta'siri:** §4.2 (admin panel sahifalar to'liq), §9 (admin
post moderation oqim).

### `admin/src/app/(dashboard)/posts/edit/[id]/_external-reviews-panel.tsx` (yangi)
**Modul:** Admin — yon panel
**Kategoriya:** A
**Sabab:** Backend `GET /posts/{id}/external-reviews` va
`POST .../refresh` ni admin sahifasiga ulaydi. Komponentlar:
- **SummaryCard** har source uchun (Google/Yandex/2GIS): ikonka +
  rang-baragn (blue/red/emerald), `last_fetched_at` formatlangan,
  rating va review count badge, **per-source refresh tugmasi**,
  `place_id sozlanmagan` holatda tugma disabled.
- **Tabs** — 3 source uchun tabbed reviews preview (har source'dan
  oxirgi 5 review).
- **Hammasini yangilash** tugmasi (header'da).

### `admin/src/components/ui/{textarea,switch,tabs}.tsx` (3 yangi shadcn komponent)
**Modul:** Admin — UI primitives
**Kategoriya:** B
**Sabab:** Edit form va reviews panel uchun zarur shadcn komponentlari.
Radix UI primitives ustiga Tailwind stillar.

### `admin/src/app/(dashboard)/posts/page.tsx`
**Modul:** Admin — Posts list
**Kategoriya:** B
**Sabab:** Har post yonidagi action ustunlariga **Edit** (Pencil)
tugmasi qo'shildi — `/posts/edit/{id}` ga link.

**Verifikatsiya:**
- `pnpm typecheck` — toza (Refine 4 / TanStack Query v5'da
  `isLoading` → `isPending` o'zgarishi tuzatildi).
- `pnpm build` — muvaffaqiyatli, yangi route `/posts/edit/[id]` 11.3 kB.

**Refine 4 migration note:**
- `useUpdate().isLoading` ❌ → `useUpdate().isPending` ✅
  (TanStack Query v5 standart).

---

## 2026-05-12 — Sprint 10: Mobile UI — external reviews integration

### `lib/models/external_review.dart` (yangi)
**Modul:** Mobile — Freezed model
**Kategoriya:** A
**Sabab:** Backend Sprint 9 endpointlari uchun mobile-side modellari:
`ExternalReviewsResponse` (`postId`, `summaries`, `reviews`),
`SourceSummary` (`source`, `reviewCount`, `averageRating`, `error`),
`ExternalReview` (`authorName`, `rating`, `text`, `postedAt`, ...).
`ReviewSourceIds` konstantalari (`google` / `yandex` / `2gis`) +
`postedAtDate` extension.
**TZ ta'siri:** §4.4 (mobile data models).

### `lib/models/places_model.dart`
**Modul:** Mobile — `Place` model kengaytirildi
**Kategoriya:** A
**Sabab:** 3 ta yangi nullable field qo'shildi —
`googlePlaceId`, `yandexPlaceId`, `gisPlaceId` (backend `Post` bilan
mos). `PlaceX.hasExternalReviews` extension geteri — widget shartli
render uchun.

### `lib/service/data_service.dart`
**Modul:** Mobile — service qatlami
**Kategoriya:** A
**Sabab:** 2 ta yangi metod: `loadExternalReviews(postId)` (cache-first),
`refreshExternalReviews(postId, sources)` (admin/moderator force refresh).

### `lib/view_models/external_reviews_vm.dart` (yangi)
**Modul:** Mobile — ViewModel
**Kategoriya:** A
**Sabab:** `ExternalReviewsVM` ChangeNotifier: yuklash holatlari
(`isLoading`, `error`, `response`), tab tanlovi (`selectedSource`),
mahalliy cache (`_lastPostId`) — bir xil postni qayta yuklamaslik,
auto-select first available source (`place_id sozlanmagan` xato
bo'lganlarni yashiradi), force refresh.

### `lib/widgets/external_reviews_section.dart` (yangi)
**Modul:** Mobile — UI widget
**Kategoriya:** A
**Sabab:** Joy tafsilotlari ekranida 3 tabbar:
- **Google Maps** — yashil pill, rating chip bilan.
- **Yandex Maps** — agar API key sozlangan bo'lsa.
- **2GIS** — rating + review count.
Tab yaqinida `_SourceIcon` (har xil ikonka), `_RatingChip` (yulduzcha +
ball), `_ReviewCard` (avatar + ism + sana + rating + matn, max 6 satr).
`refresh` tugmasi, loading/empty/error holatlari.

### `lib/screens/.../detailsPlace.dart`
**Modul:** Mobile — DetailsOfPlace ekraniga integratsiya
**Kategoriya:** A
**Sabab:** `Manba:` qatoridan keyin `ExternalReviewsSection(place)`
qo'shildi. Widget o'zi `place.hasExternalReviews` tekshiradi — bo'sh
bo'lsa `SizedBox.shrink()`.

### `lib/main.dart`
**Modul:** Mobile — Provider tree
**Kategoriya:** B
**Sabab:** `ChangeNotifierProvider(ExternalReviewsVM())` qo'shildi
(global singleton, bir VM barcha post'lar uchun — `_lastPostId` orqali
context switching).

### `lib/l10n/app_uz.arb`, `app_ru.arb`, `app_en.arb`
**Modul:** Localization
**Kategoriya:** A
**Sabab:** 4 ta yangi l10n kalit: `externalReviewsTitle`,
`externalReviewsEmpty`, `externalReviewsCount` (placeholder bilan),
`externalReviewsMore` (placeholder bilan). UZ/RU/EN to'liq.
`flutter gen-l10n` qayta yuritildi.

**Verifikatsiya:**
- `dart run build_runner build` — 24 outputs (8 yangi Freezed + g.dart).
- `flutter analyze` — 0 error, 96 issue (eski sifat).
- `flutter build ios --debug --simulator` — ✓ 54.1s.

---

## 2026-05-11 — Sprint 9: Tashqi xaritalardan kommentlar

### `backend/app/models/external_review.py` (yangi)
**Modul:** Backend — yangi DB modellari
**Kategoriya:** A
**Sabab:** Har post (joy) uchun Google Maps, Yandex Maps va 2GIS'dan
reviewlarni yig'ib cache qilish. Yangi modellar: `ExternalReview`
(har bitta review — idempotent uniq `(post_id, source, external_id)`),
`PlaceFetchLog` (cache TTL, average rating, error history),
`ReviewSource` enum (`google` | `yandex` | `2gis`).
`Post` modeliga 3 ta yangi field: `google_place_id`, `yandex_place_id`,
`gis_place_id` (admin tomonidan o'rnatiladi).
**TZ ta'siri:** §6 (yangi jadvallar).

### `backend/alembic/versions/20260511_0002_external_reviews.py` (yangi)
**Modul:** Backend — migratsiya
**Kategoriya:** A
**Sabab:** `external_reviews` va `place_fetch_logs` jadvallari +
`posts`'ga 3 ta yangi ustun. Cascade `ON DELETE CASCADE` posts'ga.

### `backend/app/services/external_reviews/` (yangi papka — 5 fayl)
**Modul:** Backend — multi-provider review aggregator
**Kategoriya:** A
**Sabab:** Provider abstraction (`BaseReviewProvider`), 3 ta
konkret provider (Google Places API v1, Yandex Maps Search,
2GIS Catalog API), `ReviewAggregator` — cache-first, parallel HTTP
fetch + serial DB upsert (asyncpg single-connection constraint).
**Fayllar:**
- `base.py` — `BaseReviewProvider` ABC, `FetchedReview`, `ProviderResult`.
- `google.py` — Google Places API (New), `X-Goog-Api-Key` + FieldMask.
- `yandex.py` — Yandex Search API v1 (rating + count, reviewlar qisman).
- `gis.py` — 2GIS public-api.reviews (full reviews + rating).
- `aggregator.py` — TTL cache, parallel fetch, upsert with
  `on_conflict_do_update`.

### `backend/app/api/v1/external_reviews.py` (yangi router)
**Modul:** Backend — REST API
**Kategoriya:** A
**Sabab:** 2 ta yangi endpoint:
- `GET /posts/{post_id}/external-reviews` — cache-first, public.
- `POST /posts/{post_id}/external-reviews/refresh` — moderator+,
  force refresh (cache ignore).
Response: `{ post_id, summaries[], reviews[] }` — summaries har
source uchun rating/count/error.

### `backend/app/schemas/{external_review,post}.py`
**Modul:** Backend — Pydantic schemas
**Kategoriya:** A
**Sabab:** `ExternalReviewRead`, `SourceSummary`, `ExternalReviewsResponse`,
`RefreshRequest`, `RefreshResult`. `PostBase`/`PostUpdate`'ga 3 ta
yangi optional place ID field.

### `backend/app/core/config.py`, `.env.example`
**Modul:** Backend — settings
**Kategoriya:** B
**Sabab:** Yangi env keys: `GOOGLE_PLACES_API_KEY`, `YANDEX_MAPS_API_KEY`,
`GIS_API_KEY`, `EXTERNAL_REVIEWS_CACHE_HOURS` (24),
`EXTERNAL_REVIEWS_PER_SOURCE_LIMIT` (20).

### `backend/tests/test_external_reviews.py` (yangi — 7 ta test)
**Modul:** Backend — testlar
**Kategoriya:** B
**Sabab:** 7 ta yangi test:
- `test_get_external_reviews_returns_aggregated` — 3 source aggregator.
- `test_get_external_reviews_post_not_found` — 404.
- `test_get_external_reviews_no_place_ids` — `place_id sozlanmagan` xato.
- `test_refresh_external_reviews_admin_only` — 403 user uchun.
- `test_refresh_external_reviews_moderator` — moderator OK, partial source.
- `test_cache_hit_on_second_call` — TTL cache hit.
- `test_provider_error_propagates_to_summary` — error → summary.error.

**FastAPI `dependency_overrides` pattern** ishlatildi (monkeypatch
`Depends(get_aggregator)`'ni override qilmaydi — `Depends` import-time
funksiya referensini saqlaydi).

### `docs/external-reviews-setup.md` (yangi)
**Modul:** Hujjatlar
**Kategoriya:** B
**Sabab:** Batafsil sozlash hujjati — Google Cloud Console, Yandex
Developer, 2GIS Dev portal'larida API kalit olish, Place ID topish,
narxlar, limitlar, tez-tez uchraydigan xatolar.

**Verifikatsiya:**
- `pytest tests/` — **77 ta test passed** (70 oldingi + 7 yangi), 10.5s.

---

## 2026-05-11 — Sprint 8: Backend integration testlari

### `backend/tests/` (yangi papka — 7 ta test fayl)
**Modul:** Backend — pytest test infrastruktura
**Kategoriya:** A
**Sabab:** Sprint 1 yakunlangan 53 endpoint hech qanday test bilan
qoplanmagan edi. Integration testlar avtomatlashtirilgan tekshiruv,
regression himoyasi va dokumentatsiya rolini bajaradi.

**Yaratilgan fayllar:**
- `tests/conftest.py` — pytest fixtures (event_loop session-scope,
  db_engine + NullPool, db_session, ASGI client + dependency override,
  test user/admin/moderator fixtures, mock Telegram/Google/MinIO).
- `tests/test_auth.py` — 16 ta test (telegram send/verify, google,
  refresh, logout, me).
- `tests/test_users.py` — 18 ta test (me, public, admin CRUD, role/ban).
- `tests/test_posts.py` — 17 ta test (list, search, CRUD, like/save).
- `tests/test_comments.py` — 5 ta test.
- `tests/test_galleries.py` — 6 ta test.
- `tests/test_categories.py` — 7 ta test.
- `tests/test_stats.py` — 4 ta test (admin dashboard, charts).

**Natija:** **70 ta test passed**, 11.4s, **coverage 69%** (schemas
va models 100%, routerlar 50-90%, servis qatlami 40-50%).

**Test DB:** lokal PostgreSQL'da alohida `discoveruzb_test` DB. Schema
har sessiya boshida `Base.metadata.create_all` + extensions
(pgcrypto, pg_trgm) + trigram index. Har test boshida jadval-
truncate (cascade).

**Mocks:**
- Telegram Gateway: `is_configured=False` (dev rejim, OTP log'ga).
- Google ID token: `verify_google_id_token` stub — `invalid` prefix
  reject, boshqalari fake `GoogleUserInfo`.
- MinIO: `FakeStorage` — fake URL qaytaradi, real S3 chaqirmaydi.

**TZ ta'siri:** §3 (test coverage talabi), §9 (ish holati).

### Bug fixlari (testlar topgan)

#### `app/api/v1/posts.py`, `comments.py`
**Modul:** Backend — POST/PATCH javoblarining bo'sh attributelar
**Kategoriya:** B
**Sabab:** `db.refresh(obj, attribute_names=["author"])` faqat `author`
relationship'ni qayta yuklardi — `updated_at` (server `onupdate`) va
boshqa attributelar `expire_on_commit=False` bo'lsa-da, Pydantic
`from_attributes` walk paytida lazy-load triggerlamoqchi bo'lib
"MissingGreenlet" xatolik bergan. Yechim: commit'dan keyin yangi
`select(... selectinload(author))` query bilan fresh row olib qaytariladi.

### `backend/pyproject.toml`
**Modul:** Backend — dev paketlar
**Kategoriya:** B
**Sabab:** `pytest-asyncio` 1.0+ event_loop scope muammosi sababli
0.23.x ga downgrade qilindi. `bcrypt<4.1` pinned (passlib bilan
moslik). `pythonpath = ["."]` qo'shildi (test imports uchun).

---

## 2026-05-11 — Sprint 7: Android build + l10n + Google guide

### `android/settings.gradle`, `android/build.gradle`, `android/app/build.gradle`, `AndroidManifest.xml`, `gradle.properties`, `gradle-wrapper.properties`
**Modul:** Android — Gradle migratsiyasi
**Kategoriya:** A
**Sabab:** Eski `plugins { id "dev.flutter.flutter-plugin-loader" }`
(version'siz) format Gradle 8+ va Flutter 3.38'da ishlamasdi
(`pluginManagement` blok yo'q). To'liq migratsiya:
- `settings.gradle` — `pluginManagement` bloki + Flutter SDK
  `includeBuild`, AGP 8.7.0, Kotlin 2.1.0, Google Services 4.4.2.
- `build.gradle` — eski `buildscript` blok olib tashlandi
  (plugin'lar `settings.gradle`'ga ko'chirildi).
- `app/build.gradle` — `namespace "uz.dizcoveruzb.discoveruzb"` qo'shildi
  (AGP 8.x talabi), Java 1.8 → 17, `androidx.multidex:2.0.1`,
  `androidx.browser:1.8.0`, `$kotlin_version` referensi olib tashlandi.
- `AndroidManifest.xml` — `package="..."` olib tashlandi (namespace
  build.gradle'da).
- `gradle.properties` — `android.bundle.enableUncompressedNativeLibs`
  olib tashlandi (AGP 8.1 da deprecated), JVM args 1.5G → 4G.
- Gradle wrapper 8.7 → 8.9.

**Natija:** `flutter build apk --debug` — `✓ Built app-debug.apk`
muvaffaqiyatli (Java 21 / Android Studio JBR bilan).
**TZ ta'siri:** §5.1 (Android build pipeline).

### `lib/l10n/app_uz.arb`, `app_ru.arb`, `app_en.arb`
**Modul:** Localization — auth oqimi uchun yangi kalitlar
**Kategoriya:** A
**Sabab:** 16 ta yangi l10n kalit (auth ekranlari uchun):
`appTagline`, `telegramHint`, `phoneIncomplete`, `orDivider`,
`signInWithGoogle`, `googleSignInError`, `phoneNumberNotFound`,
`timeExpired`, `enterYourInfo`, `registerProfileHint`, `firstName`,
`lastName`, `firstNameRequired`, `lastNameRequired`, `next`,
`createdBy`. Uchchasi: O'zbek, Rus, Ingliz.
`flutter gen-l10n` orqali `app_localizations.dart` regenerated.
**TZ ta'siri:** §7.3.

### `lib/screens/introPages/{login_with_phone,registration,otp,splash_page}.dart`
**Modul:** Mobile — hardcoded matnlar l10n'ga
**Kategoriya:** B
**Sabab:** Sprint 6 da yozilgan auth ekranlaridagi hardcoded O'zbek
matnlar (`"Telefon raqami to'liq emas"`, `"Ma'lumotlaringizni kiriting"`,
`"Davom etish"`, `"Vaqt tugadi"`, `"Created by MrDil"` va h.k.) yangi
l10n kalitlariga almashtirildi. ViewModel'lardagi xato matnlari
ViewModel context'siz bo'lgani uchun saqlandi.

### `docs/google-signin-setup.md` (yangi)
**Modul:** Hujjatlar — Google Sign-In sozlash
**Kategoriya:** B
**Sabab:** Yangi auth provider uchun batafsil sozlash hujjati:
Google Cloud Console, OAuth consent screen, iOS/Android/Web
Client ID, SHA-1 fingerprint, `Info.plist` URL scheme, Android
`strings.xml`, backend `.env`, tez-tez uchraydigan xatolar, production
rejimga o'tish. **Firebase ishlatilmaydi** — bu muhim eslatma.

**Verifikatsiya:**
- `flutter analyze` — 0 error, 81 issue (oldindan mavjud).
- `flutter build apk --debug` — ✓.
- `pnpm typecheck` (admin) — ✓.

---

## 2026-05-11 — Sprint 6: Mobile login UI (Telegram + Google)

### `lib/screens/introPages/login_with_phone.dart` (qayta yozildi)
**Modul:** Mobile — login ekrani
**Kategoriya:** A
**Sabab:** Eski Supabase oqimi va sodda dizayn yangi Telegram Gateway
oqimiga moslandi. Gradient fon, logo card, telefon kiritish card,
Google Sign-In tugmasi qo'shildi. `withValues(alpha: ...)` (Flutter
3.27+ API) ishlatildi.
**TZ ta'siri:** §4.2 (mobile login oqimi).

### `lib/view_models/login_vm.dart`, `splash_vm.dart`
**Modul:** Mobile — ViewModel'lar
**Kategoriya:** A
**Sabab:** `LoginViewModel.sendOtp()` to'liq qayta yozildi: backend
`/auth/telegram/send-otp` chaqiradi, E.164 telefon raqami normalizatsiyasi
qiladi, `request_id` va `expires_in` ni saqlaydi. `SplashViewModel`
endi `ApiClient.isAuthenticated` va `AuthService.fetchMe()` orqali JWT
yaroqligini server tomonida tekshiradi (401 da tokenlar tozalanadi,
offline'da logged-in deb hisoblanadi — offline-first UX).

### `lib/view_models/otp_vm.dart`
**Modul:** Mobile — OTP VM
**Kategoriya:** B
**Sabab:** `attachPhone(phone)` metodi qo'shildi — OTP ekrani ochilganda
takroriy `sendOtp` chaqirilmasligi uchun (LoginViewModel allaqachon
yuborgan). Faqat telefonni saqlab, timer'ni boshlaydi.

### `lib/screens/introPages/otp.dart`, `registration.dart`, `splash_page.dart`
**Modul:** Mobile — auth ekranlari dizayni
**Kategoriya:** B
**Sabab:** Uchchasi yangi dizayn tilida — gradient fon, logo card,
materialdek ko'rinish, ranglar uyg'unligi. `splash_page.dart`'da eski
`Future.microtask` antipattern (cheksiz navigatsiya ehtimoli) ichida
`_navigated` flag bilan almashtirildi. OTP'ning `Pinput` widget'iga
PinTheme qo'shildi.

### `lib/screens/introPages/login_with_phone.dart` — Google Sign-In
**Modul:** Auth — Google
**Kategoriya:** A
**Sabab:** `AuthService.signInWithGoogle()` chaqiradi
(`google_sign_in` paketi → ID token → backend `/auth/google` →
JWT). Yangi user bo'lsa `Registration` ekraniga, aks holda
`MainPage`'ga o'tadi.

**Tekshirish:**
- `flutter analyze` — 0 error, 82 issue (eski sifat).
- `flutter build ios --debug --simulator` — muvaffaqiyatli (47.4s).
- Android build alohida `settings.gradle` muammosi bor (`pluginManagement`
  bloki yetishmaydi) — Sprint 7'da tuzatiladi.

---

## 2026-05-11 — Sprint 4: Admin panel skeleton

### `admin/` (yangi papka — Next.js 15 + Refine 4 + shadcn/ui)
**Modul:** Admin panel
**Kategoriya:** A
**Sabab:** Backend CRUD endpointlari tayyor (Sprint 1) — admin panel
brauzerda kontentni boshqarish uchun zarur. Stack: Next.js 15
(App Router) + TypeScript 5.7 + Tailwind CSS 3.4 + shadcn/ui (manual
copy) + Refine 4 (auth + data provider) + TanStack Query + react-hook-form
+ zod + recharts.
**Yaratilgan tuzilma:**
- `package.json` — 30+ dependencies, pnpm lock.
- `tsconfig.json`, `next.config.mjs`, `postcss.config.mjs`, `tailwind.config.ts`.
- `src/app/layout.tsx` + `providers.tsx` (Refine, ThemeProvider, Toaster).
- `src/middleware.ts` — JWT cookie route guard.
- `src/app/login/page.tsx` + `_client.tsx` — telefon + OTP login
  (`/auth/telegram/send-otp` → `/auth/telegram/verify-otp`).
- `src/app/(dashboard)/layout.tsx` — sidebar + topbar + force-dynamic.
- `src/app/(dashboard)/page.tsx` — dashboard: 8 ta stat card +
  Bar Chart (users-by-day, 14 kun) + Bar Chart (posts-by-type).
- `src/app/(dashboard)/users/page.tsx` — jadval + qidiruv + rol
  selector + ban toggle + delete (admin endpoint).
- `src/app/(dashboard)/posts/page.tsx` — jadval + manzil qidiruv +
  publish toggle + delete + thumbnail.
- `src/app/(dashboard)/categories/page.tsx` — Dialog modal bilan
  CRUD (UZ/RU/EN), zod validation.
- `src/app/(dashboard)/galleries/page.tsx` — card grid moderatsiya
  ko'rinishi.
- `src/app/(dashboard)/comments/page.tsx` — placeholder (admin
  endpoint Sprint 5'da).
- `src/components/app-sidebar.tsx`, `app-topbar.tsx`, `role-badge.tsx`.
- `src/components/ui/` — 12 ta shadcn/ui komponent (Button, Input,
  Card, Table, Dialog, Select, DropdownMenu, Avatar, Badge, Label,
  Separator, Skeleton, InputOTP).
- `src/lib/api.ts` — axios + JWT interceptor + auto-refresh +
  localStorage + cookie sync.
- `src/lib/auth-provider.ts` — Refine `AuthProvider` (login via
  Telegram OTP, getIdentity, getPermissions, role guard:
  admin/moderator only).
- `src/lib/data-provider.ts` — Refine `DataProvider` (Page format,
  admin URL mapping for users).
- `src/lib/utils.ts` — `cn`, `formatDate`, `formatNumber`, `maskPhone`.
- `src/types/axios.d.ts` — `AxiosRequestConfig.noAuth` augmentation.

**Theme:** Light/Dark, teal brand (HSL 174 72% 32%), next-themes
sistema bilan birga.

**Tekshirish:**
- `pnpm typecheck` — 0 xato.
- `pnpm build` — muvaffaqiyatli (7 ta route, 256 KB First Load JS
  login uchun, 238 KB dashboard).

**TZ ta'siri:** §4.2 (admin panel), §5.1 (admin stack), §9.

---

## 2026-05-10 — Sprint 1 (yakuniy)

### Backend CRUD endpointlari (53 ta) tayyor

#### `backend/app/schemas/{post,comment,gallery,category,stats}.py` (yangi)
**Modul:** Backend — Pydantic schemas
**Kategoriya:** A
**Sabab:** Postlar, izohlar, galereyalar, kategoriyalar, statistika
uchun input/output schema'lari yaratildi. PostRead'da joriy user uchun
`is_liked` va `is_saved` flag'lar ham bor (per-request hisoblanadi).
**TZ ta'siri:** §4.

#### `backend/app/utils/pagination.py` (yangi)
**Modul:** Backend — pagination helper
**Kategoriya:** B
**Sabab:** Har router'da takrorlamasligimiz uchun umumiy `paginate()`
funksiyasi va `PageParams` dependency.

#### `backend/app/api/v1/users.py`, `posts.py`, `comments.py`, `galleries.py`, `categories.py`, `stats.py`, `uploads.py` (yangi — 7 ta router)
**Modul:** Backend — REST API
**Kategoriya:** A
**Sabab:** Frontend va admin panel uchun barcha CRUD endpointlar
implementatsiya qilindi:
- **Users (8):** `/me`, `/me/avatar`, public `/{user_id}`, admin
  `GET /`, `GET/PATCH/DELETE /admin/{user_id}`.
- **Posts (12):** list with filters/pagination, famous, recommend,
  search, my-liked/saved, get/create/update/delete, toggle like/save.
- **Comments (3):** list/create per post, delete.
- **Galleries (8):** my, create, get, update, add-images, delete,
  share-link, public share view.
- **Categories (4):** list (public), create/update/delete (admin).
- **Stats (3):** dashboard, users-by-day chart, posts-by-type.
- **Uploads (3):** avatar, post-image, gallery-image.

**Avtorizatsiya:** har endpoint `CurrentUser` / `CurrentAdmin` /
`CurrentModerator` / `CurrentUserOptional` dependency'lardan birini
ishlatadi (`app/api/deps.py`).

**TZ ta'siri:** §4 to'liq tasdiqlandi.

#### `backend/app/services/posts.py` (yangi)
**Modul:** Backend — biznes mantiq
**Kategoriya:** A
**Sabab:** Like/save toggle atomic — `like_count` server tomonida
yangilanadi (race-condition'siz). Eski Supabase'da client-side
hisoblanardi (xato).

#### `backend/app/services/storage.py` (yangi)
**Modul:** Backend — MinIO storage
**Kategoriya:** A
**Sabab:** S3-uyg'un MinIO klient. Image'larni Pillow bilan
optimizatsiya qiladi (max 1920px, WebP, 85% quality). Public va private
bucketlarni boshqaradi. App start'da bucketlarni avto-yaratadi.

#### `backend/app/main.py`
**Modul:** Backend — entry point
**Kategoriya:** A
**Sabab:** Barcha routerlar registratsiya qilindi (8 ta). Global
exception handler'lar: `IntegrityError` → 409, `RequestValidationError`
→ 422 with field-level errors. Lifespan'da MinIO bucket init.

#### `backend/pyproject.toml`
**Modul:** Backend — paketlar
**Kategoriya:** B
**Sabab:** `[build-system]` qismi qo'shildi (hatchling), `requests`
paket qo'shildi (google-auth transport uchun).

#### Tekshirish: 53 endpoint app yuklanadi
**Modul:** Backend — boot sinov
**Kategoriya:** B
**Sabab:** Lokal `.venv` bilan `python -c "from app.main import create_app"`
muvaffaqiyatli ishladi. Barcha 53 endpoint Swagger'da ro'yxatda.
DB ulanmagan, lekin app o'zi yuklanadi.

---

## 2026-05-10 — Sprint 1 (qisman, oldindan)

### Architecture v2.0: Supabase BaaS → Custom backend (FastAPI)

#### `backend/` (yangi papka — to'liq Python FastAPI loyihasi)
**Modul:** Backend API
**Kategoriya:** A
**Sabab:** Supabase BaaS arxitekturasidan voz kechib, custom backend
yozilmoqda. Sabab: Telegram Gateway integratsiyasi, multi-auth (Google +
Telegram), keng admin panel, kontent moderatsiyasi.
**Stack:** Python 3.12+, FastAPI 0.115, SQLAlchemy 2.0 async, asyncpg,
Alembic, Pydantic 2, JWT (jose), passlib, httpx, google-auth, minio,
redis, ruff + mypy.
**Yaratilgan fayllar:**
- `pyproject.toml` (uv/pip-uyg'un, dev-deps)
- `.env.example`
- `Dockerfile`
- `app/core/config.py` — Pydantic Settings
- `app/core/security.py` — JWT, OTP/token xeshlash
- `app/core/logging.py`
- `app/db/{base,session}.py` — SQLAlchemy async engine
- `app/models/{user,post,comment,gallery,category,auth}.py`
- `app/schemas/{user,auth,common}.py`
- `app/services/telegram_gateway.py` — Telegram Gateway klient
- `app/services/google_auth.py` — Google ID token verifikatsiyasi
- `app/services/auth.py` — biznes mantiq (OTP, JWT, refresh)
- `app/api/deps.py` — auth dependencies (`require_admin`, `require_moderator`)
- `app/api/v1/auth.py` — `/auth/telegram/*`, `/auth/google`, `/auth/refresh`, `/auth/logout`, `/auth/me`
- `app/main.py` — FastAPI app, CORS, health
- `alembic.ini`, `alembic/env.py`, `alembic/script.py.mako`
- `alembic/versions/20260510_0001_initial_schema.py` — to'liq schema
- `infra/docker-compose.yml` — postgres + redis + minio + backend
**TZ ta'siri:** §1, §3, §4, §5, §6 to'liq qayta yozildi (versiya 2.0).
§9 yangilandi.

#### `lib/service/supabase_service.dart` (o'chirildi), `pubspec.yaml`
**Modul:** Mobile — Supabase butunlay olib tashlash
**Kategoriya:** A
**Sabab:** Backend mavjud bo'lgani uchun `supabase_flutter` paketi va
Supabase init kodi olib tashlandi. Yangi paketlar: `dio: ^5.7.0`,
`pretty_dio_logger: ^1.4.0`, `flutter_secure_storage: ^9.2.2`,
`google_sign_in: ^6.2.2`.
**TZ ta'siri:** §5.1, §5.4.

#### `lib/service/api_client.dart` (yangi), `lib/service/auth_service.dart`, `lib/service/data_service.dart`, `lib/service/file_service.dart`
**Modul:** Mobile — backend bilan ishlaydigan service qatlami
**Kategoriya:** A
**Sabab:** Yangi `ApiClient` (Dio + JWT interceptor + auto-refresh).
`AuthService` to'liq qayta yozildi — Telegram Gateway + Google Sign-In +
secure storage. `DataService` Supabase chaqiruvlardan FastAPI REST
endpointlariga ko'chirildi (UUID PK, snake_case, pagination ready).
`FileService` MinIO upload uchun multipart `POST /uploads/*`.
**TZ ta'siri:** §4.1.

#### `lib/models/users_model.dart`, `lib/view_models/{otp_vm,registration_vm,details_vm,comment_vm,sub_category_vm,account_vm}.dart`, `lib/main.dart`, `lib/screens/.../{settings_page,gallery_detail}.dart`
**Modul:** Mobile — model va ViewModel'larni backend API bilan moslashtirish
**Kategoriya:** A
**Sabab:** `Users` model snake_case JSON kalitlarni qabul qilishi va
`role`, `language`, `is_banned`, `google_sub`, `telegram_id` kabi yangi
fieldlar qo'shildi. ViewModel'lar `DataService.toggleLike/Save`,
`addComment` kabi yangi atomic RPC'lar bilan ishlaydi (eski client-side
manipulatsiya o'rniga). `OTPViewModel` Telegram Gateway oqimi bilan.
`AuthService.signOut(context)` legacy `signOutUser` o'rniga.
**TZ ta'siri:** §4, §6.

---

## 2026-05-10 — Sprint 0 (avvalgi)

### Sprint 0 — Xavfsizlik tuzatish

#### `lib/service/mysql_service.dart` (o'chirildi), `pubspec.yaml`
**Modul:** Servis qatlami — legacy MySQL
**Kategoriya:** A
**Sabab:** `mysql_service.dart` mobile ilovadan to'g'ridan-to'g'ri MySQL'ga
ulanish urinardi (kompromat parol kodda hardcoded edi). Hech qaerda
chaqirilmagani uchun (dead code) xavfsiz olib tashlandi. `mysql1: ^0.20.0`
paketi `pubspec.yaml`'dan ham olib tashlandi — build hajmi kichrayadi.
**TZ ta'siri:** §5.1 (stack), §5.4 (legacy MySQL satri o'chirildi),
§9.4 (xavfsizlik qarzi qisqardi).

#### `lib/service/supabase_service.dart`, `lib/service/sms_service.dart`, `lib/view_models/details_vm.dart`
**Modul:** Servis qatlami — sirlar boshqaruvi
**Kategoriya:** A
**Sabab:** Hardcoded Supabase URL/anonKey, DevSMS Bearer token,
OpenWeatherMap API kalitlari `--dart-define` orqali
`String.fromEnvironment` mexanizmiga ko'chirildi. `--dart-define-from-file=.env`
qo'llab-quvvatlanadi (Flutter 3.7+).
Yangi: `.env`, `.env.example`, `run_dev.sh` (yordamchi script).
**TZ ta'siri:** §5.4 (env variables), §9.4 (4 ta kritik qarz bartaraf etildi).

#### `lib/models/users_model.dart`, `supabase_setup.sql`, `migrations/001_drop_password_column.sql` (yangi)
**Modul:** Ma'lumot modeli — `users.password` o'chirildi
**Kategoriya:** A
**Sabab:** Plain-text parol DB'da saqlanmasligi kerak. Auth Supabase
Phone OTP orqali boshqariladi. Freezed model'dan field olib tashlandi,
`build_runner` qayta ishga tushdi (`.freezed.dart`, `.g.dart` yangilandi).
DB ustunini olib tashlash uchun `migrations/001_drop_password_column.sql`
yaratildi — Supabase SQL Editor'da qo'lda ishga tushirilishi kerak.
**TZ ta'siri:** §6.2.1 (users schema), §9.4.

#### `migrations/002_rewrite_rls_policies.sql` (yangi), `migrations/002a_temp_relaxed_rls.sql` (yangi), `supabase_setup.sql`
**Modul:** Xavfsizlik — RLS politikalar
**Kategoriya:** A
**Sabab:** Eski "Allow all" politikalar (har kim har qanday
ma'lumotni o'zgartira olardi) o'chirildi. Yangi qat'iy politikalar
`auth.uid()` asosida yozildi (`002`). Auth migratsiyasidan oldin
ishlatish uchun yumshoqroq variant — `002a` (vaqtincha).
`supabase_setup.sql` reference qiladi, lekin politikalarni o'zi
yaratmaydi.
**TZ ta'siri:** §6 (yangi `migrations/`), §9.4.

#### `lib/models/users_model.dart`, `lib/view_models/account_vm.dart`, `lib/screens/pageViewPages/account_pages/account_page.dart`
**Modul:** Avtorizatsiya — admin tekshiruvi
**Kategoriya:** A
**Sabab:** Hardcoded telefon raqami (`+998911490349`) va eski Firebase
UID (`KvlFpnpu4ETTQHWKJpvXw3K15Cn1`) admin tekshiruvi sifatida
ishlatilardi. `Users.role` field qo'shildi (`'user' | 'admin'`),
`UsersX.isAdmin` extension yordamchisi yaratildi. `AccountViewModel.isAdmin`
geter orqali UI'da ishlatiladi.
**TZ ta'siri:** §1.4 (foydalanuvchi toifalari), §6.2.1 (users.role
ustun), §9.4.

#### `lib/view_models/otp_vm.dart`, `.env.example`, `.env`
**Modul:** Test rejim — telefon va OTP
**Kategoriya:** B
**Sabab:** Test foydalanuvchi telefon va OTP'si hardcoded `Map`'dan
`--dart-define=TEST_PHONE`, `TEST_OTP`'ga ko'chirildi. Production'da
kalit berilmasa — test rejim avtomatik o'chiq.
**TZ ta'siri:** yo'q

#### `.gitignore`
**Modul:** Git konfiguratsiyasi
**Kategoriya:** B
**Sabab:** `.env`, `*.keystore`, `key.properties`, `run_dev.sh`,
`secrets/` qo'shildi. `.env.example` exception qoldi.
**TZ ta'siri:** yo'q

---

## 2026-05-09

### `CLAUDE.md` (yangi), `docs/TZ.md`, `docs/CHANGELOG.md`, `docs/coding-standards.md`, `docs/security-rules.md` (yangi)
**Modul:** Hujjatlar — loyiha qoidalari va texnik topshiriq
**Kategoriya:** A
**Sabab:** AI yordamchilar (Claude Code) uchun loyiha qoidalari va batafsil
texnik topshiriq tuzildi. Xavfsizlik audit natijalari va keyingi
bosqichlar reja qilib hujjatlashtirildi. Yangi sessiyalar shu
hujjatlarni o'qib boshlaydi.
**TZ ta'siri:** §1–§9 to'liq to'ldirildi (loyiha tavsifi, stack,
xavfsizlik qarzi, roadmap).
**Kommit:** *(kelajakda)*

### Audit natijalari (kod o'zgarmadi, faqat hujjatlash)
**Modul:** Senior code review
**Kategoriya:** B
**Sabab:** Senior Developer/Arxitektur darajasidagi audit o'tkazildi.
Topilgan kritik xavfsizlik zaifliklari (hardcoded MySQL/Supabase/DevSMS/
OpenWeather kalitlari, OTP client-side tekshirish, RLS `Allow all`,
plain-text password ustun, hardcoded admin telefon) `docs/TZ.md §9.4` va
`docs/security-rules.md` "Hozirgi xavfsizlik qarzi" bo'limlariga
ro'yxatga olindi.
**TZ ta'siri:** yo'q (kod o'zgarmadi)

---

## 2026-05-09 va oldin

`CLAUDE.md` va `docs/` tuzilmasi yaratilguncha qilingan ishlar uchun —
`git log` va `docs/TZ.md §8 Amalga oshirish bosqichlari` ga qarang.

Asosiy bosqich:

- **2026-04-01 atrofida:** Supabase migratsiya (Firebase Firestore'dan)
  yakunlandi. Hive lokal cache, galereya feature, responsive
  breakpoints qo'shildi.
- **2026-02-26:** Play Market'da version 1.2.1+11 (version code 5)
  chiqarildi.
