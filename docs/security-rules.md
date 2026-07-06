# Xavfsizlik qoidalari

Oxirgi yangilanish: **2026-07-06** (FastAPI backend davri).
Eski Supabase/Firebase-davri qoidalari olib tashlandi.

---

## Arxitektura printsipi

Mobil ilova **faqat o'z backendimiz** bilan gaplashadi
(`lib/service/api_client.dart`, dio). Tashqi servislar (Telegram
Gateway, OpenWeatherMap, Google token verify, xarita reviewlari) —
faqat backend orqali, kalitlar faqat serverda.

Mobil ilovadan DB'ga yoki tashqi API'ga to'g'ridan-to'g'ri ulanish —
**taqiqlanadi**.

---

## Sirlar (secret) boshqaruvi

### Hech qachon kodga yozilmasin

- API kalitlar, tokenlar, parollar, keystore parollari.
- `defaultValue:` sifatida ham emas (release build ichida qoladi).

### To'g'ri yondashuv

**Mobil (Flutter):** `--dart-define` / `--dart-define-from-file=.env`.
Hozir mobil tomonda faqat bitta konfiguratsiya bor: `API_BASE_URL`
(release'da majburiy va `https://` bo'lishi shart — `api_client.dart`
runtime'da tekshiradi). Shablon: root `.env.example`.

**Backend (FastAPI):** `backend/.env` (gitignore'da), shablon —
`backend/.env.example`. Kalitlar: `SECRET_KEY`, `JWT_SECRET_KEY`,
`TELEGRAM_GATEWAY_TOKEN`, `OPENWEATHER_API_KEY`, Google client ID'lar,
MinIO va tashqi reviews API kalitlari.

### Tekshirish

```bash
# .env yoki keystore tasodifan kommit qilinmaganligi (bo'sh chiqishi kerak):
git ls-files | grep -E "\.env$|\.jks$"

# Kodda hardcoded sirlarni qidirish:
grep -rn "api_key\|token\|password" lib/ --include="*.dart" | grep -v fromEnvironment
```

### Agar sir tasodifan kommit qilingan bo'lsa

1. Kalitni darhol **rotatsiya** qiling (eski kalit yaroqsiz bo'lsin).
2. Faylni `git rm --cached` + `.gitignore` ga qo'shing.
3. Tarixdan olib tashlash kerak bo'lsa — `git filter-repo` (destruktiv,
   jamoa bilan kelishilgan holda, force-push talab qiladi).

---

## Hozirgi xavfsizlik qarzi (oxirgi yangilanish: 2026-07-06)

### ✅ Bartaraf etildi

- Hardcoded credentials → `--dart-define` / backend `.env` (Sprint 0).
- Client-side OTP tekshiruv → backend `POST /auth/telegram/verify-otp`.
- Random client-side `userId` → backend UUID + JWT.
- Telefon raqami orqali admin tekshiruvi → `users.is_admin` / `role`.
- Supabase RLS masalasi → Supabase butunlay olib tashlandi.
- OpenWeather API key mobil ilovada → backend proxy (`/api/v1/weather`).
- PII loglari (`print` bilan userId/telefon) → olib tashlandi.
- Xom `e.toString()` UI'da → `Utils.friendlyError()`.
- Keystore git tracking'da → `git rm --cached`, `Keys/` gitignore'da.
- Release'da `API_BASE_URL` default localhost → endi majburiy + https.

### 🔴 Kritik (foydalanuvchi qo'lda qilishi kerak)

- **Git TARIXIda sirlar bor**: eski commitlardagi hardcoded kalitlar
  (Supabase/DevSMS/OpenWeather) va `Keys/upload-keystore.jks`.
  Kerak: (1) eski kalitlarni rotatsiya qilish, (2) `git filter-repo`
  bilan tarixni tozalash, (3) Play Console'da upload key rotatsiyasi.

### 🟡 O'rta

- Splash offline-optimizm: 401 dan boshqa xatoda token yaroqsiz bo'lsa
  ham ichkariga kiritadi (`splash_vm.dart`) — ataylab (offline UX),
  lekin hujjatlangan risk.
- Crash monitoring yo'q (Sentry/Crashlytics) — production incidentlar
  ko'rinmaydi.

---

## Autentifikatsiya va avtorizatsiya

### Joriy oqim

1. **Telefon + OTP:** backend Telegram Gateway orqali kod yuboradi,
   server-side verify, JWT (access 60 daqiqa + refresh 30 kun).
2. **Google Sign-In:** mobil `id_token` oladi → `POST /auth/google` →
   backend Google bilan verify qiladi → JWT.
3. Tokenlar mobil tomonda `flutter_secure_storage`da; 401 da avtomatik
   refresh (`api_client.dart` interceptor).
4. **Guest (preview) rejim:** token'siz faqat public endpointlar
   (`CurrentUserOptional`); auth talab qiladigan amallar `AuthGuard`
   bottom sheet orqali login'ga yo'naltiradi.

### OTP qoidalari

- Kod HECH QACHON client'da generatsiya/tekshirilmaydi.
- TTL 5 daqiqa, max 5 urinish, rate-limit (backend `config.py`).
- Dev-rejim (`TELEGRAM_GATEWAY_TOKEN` bo'sh): kod faqat backend logida.

### Rolli avtorizatsiya

- `users.is_admin` / `role` — backend'da tekshiriladi (`CurrentAdmin`
  dependency). Mobil UI faqat ko'rsatish uchun ishlatadi, qaror serverda.
