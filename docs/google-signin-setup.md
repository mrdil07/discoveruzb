# Google Sign-In sozlash

DiscoverUzb mobile va backend Google Sign-In integratsiyasini
sozlash uchun yo'l-yo'riq.

> **Eslatma:** Firebase **ishlatilmaydi**. Faqat Google OAuth 2.0
> Sign-In Services (ID token). `GoogleService-Info.plist` va
> `google-services.json` fayllari **Firebase emas**, balki sof
> Google Sign-In konfiguratsiya fayllari.

---

## 1. Google Cloud Console'da loyiha yaratish

1. <https://console.cloud.google.com/> ga kiring.
2. **New Project** — `DiscoverUzb`.
3. **APIs & Services → OAuth consent screen**:
   - **User Type:** External.
   - **App name:** DiscoverUzb.
   - **User support email:** sizning email.
   - **Developer contact:** sizning email.
   - **Scopes:** `email`, `profile`, `openid` (default).
   - **Test users** (testing davrida): o'z Google hisoblaringizni qo'shing.

## 2. OAuth 2.0 Client ID'lar yaratish

**APIs & Services → Credentials → Create Credentials → OAuth client ID.**

### 2.1. iOS Client

| Maydon | Qiymat |
|---|---|
| **Application type** | iOS |
| **Name** | DiscoverUzb iOS |
| **Bundle ID** | `uz.dizcoveruzb.discoveruzb` |
| **App Store ID** (ixtiyoriy) | App Store'dagi raqam |

Yaratilgach **Client ID** (`<...>.apps.googleusercontent.com`) va
**iOS URL scheme** (`com.googleusercontent.apps....`) qaytariladi —
ikkalasi ham keyinroq kerak.

### 2.2. Android Client

| Maydon | Qiymat |
|---|---|
| **Application type** | Android |
| **Name** | DiscoverUzb Android |
| **Package name** | `uz.dizcoveruzb.discoveruzb` |
| **SHA-1 certificate fingerprint** | Quyida tushuntirilgan |

**SHA-1 olish** (debug keystore):

```bash
keytool -list -v -alias androiddebugkey \
  -keystore ~/.android/debug.keystore \
  -storepass android -keypass android \
  | grep "SHA1:"
```

**Release keystore** uchun (Play Store uchun shu kerak):

```bash
keytool -list -v -alias <key-alias> -keystore <path/to/release.keystore> \
  | grep "SHA1:"
```

> **MUHIM:** Agar Play Store **App Signing** ishlatilsa (default), siz
> berilgan keystore SHA-1'i emas, Google tomonidan boshqariladigan
> "App signing key certificate" SHA-1'ini qo'shishingiz kerak. Uni
> Play Console → **Setup → App signing → App signing key certificate**'da
> ko'rasiz.

### 2.3. Web Client (backend uchun)

| Maydon | Qiymat |
|---|---|
| **Application type** | Web application |
| **Name** | DiscoverUzb Backend |
| **Authorized JavaScript origins** | `https://admin.discoveruzb.uz`, `http://localhost:3000` |
| **Authorized redirect URIs** | (mobile uchun kerak emas) |

Bu Client ID **backend'da audience tekshiruvi** uchun ishlatiladi —
mobile iOS/Android ID tokenlari ham shu Web Client'ga audience sifatida
chiqariladi (kross-klient auth).

## 3. Backend konfiguratsiya

`backend/.env`:

```env
GOOGLE_CLIENT_ID_IOS=<ios-client-id>.apps.googleusercontent.com
GOOGLE_CLIENT_ID_ANDROID=<android-client-id>.apps.googleusercontent.com
GOOGLE_CLIENT_ID_WEB=<web-client-id>.apps.googleusercontent.com
```

Backend `app/services/google_auth.py` har uchchasini audience sifatida
qabul qiladi (`settings.google_audience` xususiyati).

## 4. iOS mobile konfiguratsiya

### 4.1. `Info.plist` ga URL scheme qo'shish

`ios/Runner/Info.plist`'ni oching va `<dict>` ichiga qo'shing
(`UIApplicationSceneManifest` yoki boshqa shunga o'xshash mavjud
kalitlardan keyin):

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <!-- Google Cloud Console'dan olingan REVERSED CLIENT ID -->
      <string>com.googleusercontent.apps.YOUR_IOS_CLIENT_ID</string>
    </array>
  </dict>
</array>
```

> `REVERSED CLIENT ID` — Client ID'ning teskari nuqtalar bilan
> yozilgan formati. Misol: `123456-abc.apps.googleusercontent.com`
> → `com.googleusercontent.apps.123456-abc`.

### 4.2. `GoogleService-Info.plist` (ixtiyoriy)

`google_sign_in` paketi `Info.plist`'dagi URL scheme bilan yetadi.
`GoogleService-Info.plist` faqat Firebase'da ishlatiladi va bizga
kerak emas.

## 5. Android mobile konfiguratsiya

### 5.1. `strings.xml` ga Web Client ID qo'shish

`android/app/src/main/res/values/strings.xml` (mavjud emas bo'lsa
yarating):

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="default_web_client_id">YOUR_WEB_CLIENT_ID.apps.googleusercontent.com</string>
</resources>
```

> **Eslatma:** Android'da Google Sign-In **iOS Client ID'ni emas**,
> **Web Client ID'ni** ishlatadi (kross-klient auth). Bu ID token'ning
> `aud` claim'i Web Client ID'ga teng bo'lishini ta'minlaydi.

### 5.2. SHA-1 fingerprint Cloud Console'da

§2.2'da yozilgan SHA-1'ni Google Cloud Console'da **Android Client**'ga
qo'shganingizdan keyin Sign-In ishlay boshlaydi.

## 6. Flutter ilovada

`google_sign_in: ^6.2.2` paketi `pubspec.yaml`'da allaqachon bor.

`AuthService.signInWithGoogle()` quyidagini qiladi:

```dart
final account = await _googleSignIn.signIn();  // Native picker
final auth = await account.authentication;
final idToken = auth.idToken;
// idToken backend'ga yuboriladi: POST /auth/google
```

Backend ID tokenni audience'larga taqqoslaydi, `iss=accounts.google.com`,
`email_verified=true` tekshiradi, foydalanuvchi yaratadi/topadi va JWT
chiqaradi.

## 7. Test qilish

1. **Backend:** `cd backend && uvicorn app.main:app --reload`
2. **Mobile:** `flutter run --dart-define-from-file=.env`
3. Login ekranida **Google bilan kirish** tugmasini bosing.
4. Native Google picker ochiladi → akkaunt tanlaysiz.
5. Backend logida: `Google ID token verified for <email>`.
6. Mobile asosiy ekranga o'tadi.

## 8. Tez-tez uchraydigan xatolar

| Xato | Sabab | Yechim |
|---|---|---|
| `Sign in failed: 10` (Android) | Web Client ID `strings.xml`'da yo'q yoki SHA-1 yo'q | §5.1, §2.2 |
| `Sign in failed: 12500` (Android) | Google Play Services eski | Emulatorda Google API'lar bilan image tanlash |
| `ID_TOKEN_REJECTED` (backend) | Audience mos kelmaydi | `GOOGLE_CLIENT_ID_*` env to'g'ri ekanini tekshiring |
| `redirect_uri_mismatch` | Web client uchun redirect URI yetishmaydi | Cloud Console'da Web client'ga qo'shing |
| iOS picker ochilmaydi | URL scheme `Info.plist`'da yo'q | §4.1 |

## 9. Production rejimga o'tish

Test users ro'yxati bilan ishlash 100 user'ga cheklangan.
Production'da OAuth consent screen'ni **Publishing status: In production**
ga o'tkazish kerak — bu Google verifikatsiyani talab qiladi
(brand, privacy policy URL va h.k.).

Verifikatsiya 1-2 hafta vaqt oladi. Soddaroq: faqat `openid`, `email`,
`profile` scope'lar bilan **brand verification** kifoya (Google API
audit'siz).

---

**So'nggi yangilanish:** 2026-05-11. Sprint 7.
