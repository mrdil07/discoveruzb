# Xavfsizlik qoidalari

> Bu hujjat **DiscoverUzb** loyihasi uchun. Mobile-only Flutter ilovasi
> + Supabase BaaS arxitekturasiga moslashtirilgan.

---

## Sirlar (secret) boshqaruvi

### Hech qachon kodga yozilmasin

- Supabase URL va anon/service key.
- DevSMS Bearer token.
- OpenWeatherMap API key.
- MySQL host/user/password (legacy — umuman ishlatilmasin).
- Push notification (FCM/OneSignal) kalitlari (kelajakda).
- Payment gateway tokenlari (Click, Payme — kelajakda).
- Android/iOS signing key paroli.

### To'g'ri yondashuv (Flutter)

**1) `--dart-define` orqali (tavsiya):**

```dart
class SupabaseService {
  static const url = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );
  static const anonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );
}
```

Build vaqtida:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://lfyzugkyoopolbmifvxo.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=sb_publishable_... \
  --dart-define=DEVSMS_TOKEN=ccfbc26c... \
  --dart-define=OPENWEATHER_API_KEY=09d7f0...
```

**2) `flutter_dotenv` orqali:**

```yaml
# pubspec.yaml
dependencies:
  flutter_dotenv: ^5.1.0
flutter:
  assets:
    - .env
```

```dart
// main.dart
await dotenv.load(fileName: ".env");
final url = dotenv.env['SUPABASE_URL']!;
```

`.env` `.gitignore`'ga qo'shilsin. `.env.example` faqat placeholder
qiymatlar bilan kommit qilinadi:

```
SUPABASE_URL=<random_string_here>
SUPABASE_ANON_KEY=<your_anon_key>
DEVSMS_TOKEN=<your_devsms_token>
OPENWEATHER_API_KEY=<your_openweather_key>
```

### Tekshirish

```bash
# .env tasodifan kommit qilinmaganligi:
git ls-files --error-unmatch .env
# "error: pathspec '.env' did not match any file(s) known to git." — to'g'ri.

# Kodda hardcoded sirlarni qidirish:
grep -rE "(token|password|secret|api[_-]?key|anonKey|supabaseUrl)\s*=" \
  lib/ --include="*.dart" \
  | grep -vE "(String\.fromEnvironment|dotenv\.env|fromEnvironment)"
```

### Agar sir tasodifan kommit qilingan bo'lsa

1. **Token/parolni darhol aylantiring** (eski qiymat kompromat):
   - Supabase: dashboard → Settings → API → Reset anon key.
   - DevSMS: kabinetda token regenerate.
   - OpenWeather: dashboard → API keys → revoke.
   - **MySQL parolini bugun o'zgartiring** (`mirxojiddin.uz`'da).
2. Git tarixidan o'chiring:
   ```bash
   git filter-repo --path lib/service/supabase_service.dart --invert-paths
   # yoki butun tarixda string almashtirish:
   git filter-repo --replace-text replacements.txt
   ```
3. Force push (jamoaga ogohlantirib — ular `git reset --hard origin/<branch>` qilishi kerak).
4. Local `.dart_tool/`, `build/` cache'larini tozalang.

---

## Hozirgi xavfsizlik qarzi (oxirgi yangilanish: 2026-05-10)

> Bu ro'yxat `docs/TZ.md §9.4` bilan sinxron yuriladi. Qarzlar bartaraf
> etilganda — ikkala faylda ham yangilang.

### ✅ Sprint 0 (2026-05-10) bartaraf etildi

- ~~Hardcoded Supabase URL + anon key~~ → `--dart-define=SUPABASE_URL/ANON_KEY`.
- ~~Hardcoded MySQL credentials~~ → fayl + paket o'chirildi.
  ⚠️ Parol Git tarixida hali bor — siz `mirxojiddin.uz` panelida
  parolni o'zgartirishingiz kerak.
- ~~Hardcoded DevSMS token~~ → `--dart-define=DEVSMS_TOKEN`.
- ~~Hardcoded OpenWeather API key~~ → `--dart-define=OPENWEATHER_API_KEY`.
- ~~Plain-text `password` ustun~~ → model'dan olib tashlandi.
  DB ustunini olib tashlash uchun `migrations/001_drop_password_column.sql`
  Supabase SQL Editor'da ishga tushirilishi kerak.
- ~~Hardcoded admin telefon va Firebase UID~~ → `users.role` field +
  `Users.isAdmin` extension.

### 🔴 Kritik (darhol — siz qo'lda qilishingiz kerak)

- **Sirlar Git tarixida** — `mysql1`, Supabase, DevSMS, OpenWeather
  kalitlari oldingi commit'larda. Tartib:
  1. Supabase: dashboard → Settings → API → Reset anon key.
  2. DevSMS: panelda yangi token oling.
  3. OpenWeather: dashboard → API keys → revoke + yangi.
  4. **MySQL parolini bugun o'zgartiring** (`mirxojiddin.uz`).
  5. Yangi qiymatlarni `.env` ga yozing.
  6. `git filter-repo --path lib/service/mysql_service.dart --invert-paths`
     yoki butun tarixda string'larni almashtirish (`replacements.txt`).
  7. Force push (jamoa bilan ogohlantirib).
- **OTP client-side tekshiriladi** — `lib/view_models/otp_vm.dart`.
  Frida/jailbreak orqali bypass trivial. Sprint 1'da Supabase Phone
  Auth'ga to'liq o'tish.
- **Random userId mahalliy generatsiya qilinadi** —
  `lib/view_models/otp_vm.dart:176`. Hech qanday Supabase Auth
  ishlatilmagan, RLS ishlamaydi. Sprint 1.
- **RLS politikalar `Allow all`** (DB tomonida) — `migrations/002_*.sql`
  yozildi, lekin Supabase'da hali qo'llanmagan. Auth migratsiyasi bilan
  birga (`002`) yoki vaqtincha `002a` qo'llang.

### 🟠 Yuqori (yaqin orada)

- **Sezgir ma'lumot `SharedPreferences`'da** —
  `lib/service/pref_service.dart`. UserID, telefon — `flutter_secure_storage`'ga.
- **Storage'da public bucket** — `media` butun public.
  Galereya rasmlari — private bucket + signed URL bo'lsin.

### 🟡 O'rta

- **`mysql_service.dart` dead code** — `mysql1: ^0.20.0` paket bilan
  birga build hajmini oshiradi.
- **`debugPrint` PII chiqarishi** — telefon, OTP kod log'larda
  (`otp_vm.dart`, `pref_service.dart`).
- **Test fayllari yo'q** — security regression'larni topish qiyin.
- **CI/CD yo'q** — har commit'da static analyze + build tekshirish yo'q.

---

## Autentifikatsiya va avtorizatsiya

### Joriy holat (TODO: qayta yozish)

- Telefon raqami + 6 xonali OTP (DevSMS).
- OTP client-side tekshiriladi (xato!).
- Random `userId` (`DateTime.now().millisecondsSinceEpoch`) generatsiya
  qilinadi va `SharedPreferences`'da saqlanadi.
- Supabase Auth ishlatilmaydi — barcha so'rovlar anonymous client orqali.

### Maqsad (Sprint 1, TZ §8.2)

- **Supabase Phone Auth** — `supabase.auth.signInWithOtp(phone: ...)`.
- Server-side OTP tekshirish — `supabase.auth.verifyOTP(...)`.
- `auth.uid()` orqali RLS — har user faqat o'z ma'lumotlarini ko'radi.
- DevSMS — Supabase Auth provider sifatida sozlanadi (yoki Edge Function).

### OTP qoidalari

- **Uzunligi:** 6 xona.
- **Amal qiladi:** 5 daqiqa (joriy `otp_vm.dart` 3 daqiqa — yangilash).
- **Bir marta ishlatiladi** — verifikatsiyadan keyin server tomonida
  invalidate.
- **Brute force himoya:** rate limit telefon bo'yicha 1 daqiqada 1
  marta, kuniga 10 marta. *Hozirda yo'q — qo'shilishi kerak.*
- **Test rejim:** `kDebugMode` + `+998911490349` → OTP `121212`.
  Production'da `kDebugMode` `false` bo'lgani uchun avtomatik
  o'chiriladi — qo'shimcha `DEV_MODE` flag kerakmas.

### Rolli avtorizatsiya (kelajak)

- `users.role` ustun (`'user'`, `'admin'`).
- Supabase JWT'ga custom claim qo'shish (Edge Function yoki RLS function).
- RLS misolida:
  ```sql
  CREATE POLICY "admin can delete posts" ON posts
    FOR DELETE
    USING (auth.jwt() ->> 'role' = 'admin');
  ```

### JWT payload qoidalari

- Faqat `user_id`, `phone`, `role` saqlansin.
- PII (`fullname`, `email`, `device_token`) JWT'ga kiritilmasin —
  alohida `users` jadvalidan olinadi.
- Access token muddati: 1 soat. Refresh token: 30 kun.

---

## Ma'lumotlarni himoya qilish

- **PII (shaxsiy ma'lumot)** — log fayllarga to'liq yozilmasin.
  - Telefon: `+998***1234` (oxirgi 4 xona).
  - Email: `j***@example.com`.
  - Ism/familiya: faqat ID'ni log qiling, ism kerak emas.
- **OTP kod va parol** — log'larga **mutlaqo** tushmasin.
  Hozirda `debugPrint('Generated OTP: $_otpCode for $phoneNumber')`
  bor (`otp_vm.dart:102`) — release build'da o'chiriladi, lekin
  `kDebugMode` bilan o'rab qo'yish yaxshi:
  ```dart
  if (kDebugMode) debugPrint('OTP: $_otpCode');
  ```
- **Mobil token va session ma'lumoti** — interceptor faqat Supabase
  domeniga yuborsin (whitelist tekshiruvi). DevSMS va OpenWeather
  alohida tokenlar.

---

## HTTPS majburiy

- Barcha tashqi servislar HTTPS:
  - Supabase: ✅ (rasmiy domain).
  - DevSMS: ✅ (`https://devsms.uz`).
  - OpenWeather: ✅ (`https://api.openweathermap.org`).
- iOS `Info.plist` da `NSAllowsArbitraryLoads = false` (default).
- Android `network_security_config.xml` da `cleartextTrafficPermitted = false`.

---

## SQL injection va XSS

- **SQL injection:** Supabase REST (PostgREST) parametrlangan so'rov
  yaratadi — `eq()`, `ilike()`, `contains()` xavfsiz. Raw SQL
  ishlatmang.
  ```dart
  // ✅ Xavfsiz:
  await supabase.from('posts').select().ilike('placeName', '%$keyword%');

  // ❌ Agar RPC ishlatsangiz — server tomonida parametrlash:
  await supabase.rpc('search_posts', params: {'kw': keyword});
  ```
- **XSS:** Flutter native `Text` widget'lari avtomatik escape qiladi.
  - WebView ishlatilsa — alohida ehtiyot.
  - HTML render qilinsa (`flutter_html` va h.k.) — sanitize.

---

## Fayl yuklash (Storage)

- **Fayl turini tekshirish** — extension'ga ishonmang. `image_picker`
  `XFile.mimeType` orqali yoki magic number tekshiruvi.
- **Maksimal hajm:**
  - Profil rasm: 5 MB.
  - Post rasmi: 10 MB.
  - Galereya: 200 MB jami (foydalanuvchi quotasi).
  TODO: `image_picker` natijasini hajm bo'yicha cheklash.
- **Saqlash nomi:** generatsiya qilingan UUID/timestamp ishlating —
  `file_service.dart:23`'da `image_${DateTime.now().millisecondsSinceEpoch}`
  bor (yaxshi).
- **Path traversal:** Supabase Storage avtomatik himoya qiladi
  (`/`, `..` filtrlanadi).
- **Storage policy** (Supabase):
  ```sql
  -- Faqat ega o'z rasmini ko'tara oladi:
  CREATE POLICY "users upload own image" ON storage.objects
    FOR INSERT WITH CHECK (
      bucket_id = 'media'
      AND (storage.foldername(name))[1] = 'user_image'
      AND owner = auth.uid()
    );
  ```

---

## Rate limiting

> Mobile + Supabase BaaS arxitekturasida rate limit ikki joyda kerak:
> Supabase Edge Function darajasida (auth oqim) va DevSMS provider
> tomonidan.

- **OTP yuborish** (`POST devsms.uz`): telefon bo'yicha 1 daqiqada 1 marta,
  kuniga 10 marta. TODO: Supabase Edge Function'da hisoblash.
- **Login (OTP tekshirish):** telefon bo'yicha 1 daqiqada 5 urinish.
- **Qidiruv (`searchPosts`):** UI debounce 500ms. TODO: joriy etish.
- **Umumiy Supabase API:** Supabase free plan'da 500 req/s — kifoya.
- **DDoS:** Supabase Cloudflare bilan himoyalangan.

---

## Secrets va kalitlarni rotatsiya

- **Supabase anon key:** kerak bo'lganda (kompromat aniqlansa).
- **Supabase service role key:** mobile'da **mutlaqo** ishlatilmasin.
  Faqat backend Edge Function'da.
- **DevSMS token:** yiliga bir marta + kompromat holatida.
- **OpenWeather API key:** yiliga bir marta.
- **Android keystore:** yo'qotilmasin (Play Store bog'lanishi shu
  bilan). Backup: Google Play App Signing'ga ishonch qilinsa, `Keys/`
  papkadagi keystore yo'qotilsa ham Google qutqaradi.

> **TODO:** `Keys/` papkasi `.gitignore`'da ekanligini tekshirish.

---

## Audit va monitoring

### Joriy holat

- **Logging:** `debugPrint` aralash `print()`. Strukturalashgan emas.
- **Crash reporting:** yo'q.
- **Analytics:** yo'q.

### Maqsad

- **Sentry yoki Firebase Crashlytics** — production crash + tarmoq
  xatoliklar.
  ```yaml
  dependencies:
    sentry_flutter: ^8.0.0
  ```
- **Auth eventlari** (login, signup, logout, OTP fail) — Supabase
  Audit log'ga yozilsin (Pro plan'da rasmiy mavjud).
- **Health check:** mobile-only ilovada kerak emas. Supabase status
  `https://status.supabase.com`.

---

## Build / Release xavfsizlik

- **`pubspec.lock` kommit qilinsin** — paket versiyalari deterministik.
- **`flutter pub upgrade --major-versions`** — major versiya yangilash
  alohida PR'da.
- **Android signing:** `key.properties` `.gitignore`'da. CI'da Secrets'dan.
- **iOS provisioning:** App Store Connect'da boshqariladi.
- **`google-services.json`, `GoogleService-Info.plist`** —
  hech qachon kommit qilinmasin (kelajakda FCM qo'shilsa).
- **ProGuard / R8** (Android) — release build'da yoqilsin
  (`android/app/build.gradle` `minifyEnabled true`).
- **iOS bitcode** — Xcode 15+ default `false`.

---

## Foydalanuvchi maxfiyligi (Privacy)

- **App Store Privacy Manifest** (iOS 17+) majburiy:
  `ios/Runner/PrivacyInfo.xcprivacy`. Foydalaniladigan API'lar:
  - `NSPrivacyAccessedAPICategoryUserDefaults` (SharedPreferences).
  - `NSPrivacyAccessedAPICategoryFileTimestamp` (image_picker).
- **Play Data Safety:** Google Play Console'da to'ldirilsin —
  qaysi ma'lumot to'planadi (telefon, ism, rasm).
- **GDPR (kelajakda Yevropa auditoriyasi):** foydalanuvchiga
  o'z ma'lumotlarini export va o'chirish imkoniyati.

---

**Ushbu hujjat har audit'dan keyin yangilansin. So'nggi audit:
2026-05-09 (Claude Code Senior Audit).**
