# DiscoverUzb - O'zbekiston Sayohat Ilovasi

O'zbekistonning turistik joylarini kashf etish uchun Flutter ilovasi.

**Package name:** `uz.dizcoveruzb.discoveruzb`
**Version:** 1.2.1+11
**Play Market:** Mavjud (oxirgi yangilanish: 26 Feb 2026, version code: 5)

---

## Texnologiyalar

| Texnologiya | Maqsad |
|-------------|--------|
| Flutter (Dart) | Frontend framework |
| Supabase (PostgreSQL) | Database + Storage |
| DevSMS (devsms.uz) | SMS OTP yuborish |
| Provider | State management |
| Hive | Lokal kesh |
| SharedPreferences | Session saqlash |
| Freezed + json_serializable | Data modellar |
| OpenWeatherMap API | Ob-havo ma'lumoti |

---

## Loyiha strukturasi

```
lib/
├── main.dart                          # Ilova boshlang'ich nuqtasi
├── l10n/                              # Lokalizatsiya (en, uz, ru)
├── constants/                         # Ranglar, ma'lumot manbalari
├── models/                            # Freezed data modellar
│   ├── users_model.dart               # Foydalanuvchi profili
│   ├── places_model.dart              # Joy/manzil ma'lumoti
│   ├── gallery_model.dart             # Galereya kolleksiyasi
│   ├── comments.dart                  # Izohlar
│   ├── media_model.dart               # Media yuklamalar
│   ├── types_model.dart               # Kategoriya turlari
│   └── weather_model.dart             # Ob-havo (OpenWeatherMap)
├── service/                           # Biznes logika
│   ├── supabase_service.dart          # Supabase init
│   ├── sms_service.dart               # DevSMS OTP
│   ├── data_service.dart              # Supabase CRUD
│   ├── file_service.dart              # Supabase Storage upload
│   ├── auth_service.dart              # Logout
│   ├── pref_service.dart              # SharedPreferences
│   ├── hive_service.dart              # Lokal kesh
│   └── themes.dart                    # Mavzular
├── view_models/                       # Provider ChangeNotifier
│   ├── splash_vm.dart                 # Session tekshirish
│   ├── login_vm.dart                  # Telefon kiritish
│   ├── otp_vm.dart                    # OTP tasdiqlash
│   ├── registration_vm.dart           # Ro'yxatdan o'tish
│   ├── home_vm.dart                   # Bosh sahifa ma'lumotlar
│   ├── account_vm.dart                # Profil boshqaruv
│   ├── details_vm.dart                # Joy tafsilotlari
│   ├── search_vm.dart                 # Qidiruv
│   ├── sub_category_vm.dart           # Kategoriya filtri
│   ├── create_gallery_vm.dart         # Galereya yaratish
│   ├── comment_vm.dart                # Izoh boshqaruv
│   ├── main_vm.dart                   # Navigatsiya holati
│   └── media_page.dart                # Media yuklash
└── screens/                           # UI sahifalar
    ├── introPages/                    # Auth oqimi
    │   ├── splash_page.dart           # Splash ekran
    │   ├── login_with_phone.dart      # Telefon kiritish
    │   ├── otp.dart                   # OTP tasdiqlash
    │   └── registration.dart          # Ro'yxatdan o'tish
    └── pageViewPages/                 # Asosiy ilova
        ├── main_screen.dart           # Bottom nav (4 sahifa)
        ├── home/home_page.dart        # Bosh sahifa
        ├── category_page/             # Kategoriyalar
        ├── account_pages/             # Profil va sozlamalar
        └── private_gallery/           # Shaxsiy galereya
```

---

## Auth oqimi

```
SplashPage (3 soniya)
    |
SharedPreferences: userId bormi?
    |                        |
  HA (userId mavjud)    YO'Q (userId yo'q)
    |                        |
  MainPage            LoginWithPhone
                           |
                    Telefon raqam kiritish (+998 XX XXX XX XX)
                           |
                    DevSMS orqali OTP yuboriladi
                           |
                       OTPScreen
                    6 xonali kod kiritish
                           |
                    Supabase'da user bormi?
                    |                  |
                 HA (mavjud)     YO'Q (yangi)
                    |                  |
                 MainPage        Registration
                                     |
                                Ism/Familiya
                                     |
                                Supabase'ga yozish
                                     |
                                  MainPage
```

---

## Supabase sozlamalari

**Project URL:** `https://lfyzugkyoopolbmifvxo.supabase.co`

### Database table'lar:

**users** - Foydalanuvchilar
| Ustun | Tip | Tavsif |
|-------|-----|--------|
| uid | TEXT (PK) | Foydalanuvchi ID |
| fullname | TEXT | To'liq ism |
| phoneNumber | TEXT | Telefon raqam |
| email | TEXT | Email |
| imgUrl | TEXT | Profil rasm URL |
| device_id, device_type, device_token | TEXT | Qurilma ma'lumoti |

**posts** - Joylar/manzillar
| Ustun | Tip | Tavsif |
|-------|-----|--------|
| id | TEXT (PK) | Post ID |
| uid | TEXT | Yaratuvchi ID |
| placeName | TEXT | Joy nomi |
| placeInfo | TEXT | Tavsif |
| placeImage | JSONB | Rasmlar ro'yxati |
| address | TEXT | Manzil |
| type | TEXT | Kategoriya |
| time | BIGINT | Vaqt (timestamp) |
| lat, lon | FLOAT | Koordinatalar |
| liked, saved | JSONB | Like/saqlangan user ID'lar |
| likeCount | INT | Like soni |
| comments | JSONB | Izohlar |

**gallery** - Galereyalar
| Ustun | Tip | Tavsif |
|-------|-----|--------|
| id | SERIAL (PK) | Auto ID |
| placeName | TEXT | Joy nomi |
| images | JSONB | Rasmlar ro'yxati |
| date | TEXT | Sana |

**Storage bucket:** `media` (public)
- `user_image/` - Profil rasmlar
- `post_image/` - Post rasmlar
- `gallery/` - Galereya rasmlar

---

## DevSMS (SMS OTP)

- **API:** `https://devsms.uz/api/send_sms.php`
- **Metod:** POST
- **SMS shablon:** `MRDIL: Ilovaga kirish uchun parol: {6 xonali kod}`
- **Narx:** 200 UZS/SMS (mahalliy)

---

## Ishga tushirish

```bash
# Dependencies
flutter pub get

# Code generation (freezed models)
flutter pub run build_runner build --delete-conflicting-outputs

# Debug mode
flutter run

# Release AAB (Play Market uchun)
flutter build appbundle --release
```

### Signing (Android)

Keystore: `Keys/upload-keystore.jks`
Config: `android/key.properties`

---

## Tahlil natijalari (2026-03-31)

### Aniqlangan muammolar

| # | Muammo | Jiddiylik | Holat |
|---|--------|-----------|-------|
| 1 | Client-side OTP generatsiya va tekshirish - xavfsizlik xavfi | YUQORI | Ochiq |
| 2 | `loadUserId` loop - Home sahifada Supabase query'lar takrorlanadi | O'RTA | Ochiq |
| 3 | Test mode (`+998911490349` / `121212`) production build'da qolishi mumkin | O'RTA | Ochiq |
| 4 | DevSMS API token source kodda hardcoded | O'RTA | Ochiq |
| 5 | Telefon raqam validatsiyasi yo'q (faqat bo'shlik tekshiriladi) | PAST | Ochiq |
| 6 | OTP qayta yuborish uchun rate limiting yo'q | O'RTA | Ochiq |
| 7 | Session timeout mavjud emas - userId abadiy saqlanadi | PAST | Ochiq |
| 8 | Supabase `contains` query JSONB ustunlarda xato berishi mumkin | O'RTA | Tuzatildi |

---

## Bajarilgan ishlar logi

### 2026-03-31: Firebase -> Supabase + DevSMS migratsiya

**Muammo:** Firebase Spark (bepul) plan'da Phone Auth, Storage va boshqa xizmatlar ishlamay qolgan. Blaze plan'ga o'tish uchun $50 oldindan to'lov talab qilinadi.

**Yechim:** To'liq backend migratsiya qilindi:

| Avvalgi (Firebase) | Hozirgi | O'zgartirilgan fayllar |
|---------------------|---------|------------------------|
| Firebase Phone Auth | DevSMS OTP + Supabase DB | `otp_vm.dart`, `splash_vm.dart`, `registration_vm.dart`, `auth_service.dart` |
| Cloud Firestore | Supabase PostgreSQL | `data_service.dart` |
| Firebase Storage | Supabase Storage | `file_service.dart` |
| Firebase.initializeApp | SupabaseService.initialize | `main.dart` |

**Yangi fayllar yaratildi:**
- `lib/service/supabase_service.dart` - Supabase init
- `lib/service/sms_service.dart` - DevSMS integration
- `android/key.properties` - Signing config
- `supabase_setup.sql` - Database table yaratish SQL
- `supabase_fix.sql` - Table tuzatish SQL

**Test natijalari:**
- SMS OTP yuborish: ISHLAYDI (DevSMS: `{"success":true}`)
- User registration: ISHLAYDI (Supabase'ga yoziladi)
- Session saqlash: ISHLAYDI (SharedPreferences orqali)
- Supabase init: ISHLAYDI (`Supabase init completed`)
- Internet yo'q holat: Xatolar to'g'ri ushlandi (`SocketException` catch qilinadi)

**Qolgan ishlar:**
- [ ] Production build qilish va Play Market'ga yuklash
- [ ] Client-side OTP ni server-side'ga ko'chirish (xavfsizlik uchun)

### 2026-04-01: Firebase to'liq tozalash va build tuzatish

**Bajarilgan ishlar:**

1. **Supabase JSONB fix** - `supabase_fix.sql` SQL Editor'da ishga tushirildi. `posts` va `gallery` table'lar to'g'ri `JSONB DEFAULT '[]'::jsonb` bilan qayta yaratildi.

2. **Firebase package'lar olib tashlandi** - `pubspec.yaml`'dan `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage` olib tashlandi. 13 ta dependency o'chirildi.

3. **Firebase config fayllar tozalandi:**
   - `lib/firebase_options.dart` - o'chirildi
   - `android/app/google-services.json` - o'chirildi
   - `ios/Runner/GoogleService-Info.plist` - o'chirildi
   - `firebase.json` - o'chirildi
   - `android/build.gradle` - `com.google.gms:google-services` plugin olib tashlandi
   - `android/app/build.gradle` - Firebase BOM, analytics, dynamic-links olib tashlandi
   - `ios/Runner.xcodeproj/project.pbxproj` - GoogleService-Info.plist referenslari olib tashlandi

4. **Build tekshirish** - `flutter analyze`: 0 error. Faqat warning/info (81 ta, hammasi muhim emas).

5. **iOS Simulator test** - Loyiha muvaffaqiyatli ishga tushdi:
   - Supabase init: OK
   - Firebase xatolari: YO'Q
   - Build vaqti: 12.8s
   - Session: ishlaydi
