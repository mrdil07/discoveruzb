# DiscoverUzb — Loyiha qoidalari

AI yordamchilar (Claude Code va h.k.) uchun majburiy qisqa qoidalar.
Batafsil qoidalar `docs/` ichida.

---

## 1. Sessiya boshida MAJBURIY

Yangi sessiya boshida quyidagilarni **o'qib chiqing**:

1. `docs/TZ.md` — texnik topshiriq, joriy holat, arxitektura.
2. `docs/CHANGELOG.md` — oxirgi o'zgarishlar.

O'qilmay turib kod yozish, refaktor yoki deploy qat'iyan taqiqlanadi.

---

## 1.1. Sessiya oxirida MAJBURIY

Ish tugaganini belgilaganda (foydalanuvchi "tugatdik", "rahmat",
"yetarli", "keyin davom etamiz" yoki shunga o'xshash desa) yoki sessiya
yakuniga yetganda:

1. Bajarilgan har bir o'zgarishni §3 qoidalariga ko'ra tasniflang.
2. `docs/CHANGELOG.md` ga yangi yozuv(lar) qo'shing.
3. Agar **Kategoriya A** bo'lsa — `docs/TZ.md` ning tegishli bo'lim(lar)ini
   yangilang (jadvalga qarang).
4. Foydalanuvchiga qisqa xulosa bering:
   - Nima qilindi (1–2 qator)
   - Qaysi fayllar o'zgardi
   - TZ va CHANGELOG yangilanganini tasdiqlang
   - Keyingi mantiqiy qadam (agar bor bo'lsa)

**Hujjatlash qilinmaganida sessiya "tugatilgan" hisoblanmaydi.**

---

## 2. Loyiha qisqacha

**DiscoverUzb** — O'zbekistondagi turistik joylarni kashf qiluvchi
mobil ilova. Foydalanuvchilar joylarni qidirishi, layk/saqlash, izoh
qoldirishi, ob-havoni ko'rishi va xaritada yo'nalish olishi mumkin.

| Komponent | Joy | Stack |
|-----------|-----|-------|
| Mobil ilova | `lib/` | Flutter 3.27+, Dart 3.x |
| Backend (o'zimizniki) | `backend/` | FastAPI + PostgreSQL + Redis + MinIO, alembic, pytest |
| Admin panel | `admin/` | Next.js 15 + Refine |
| Lokal kesh | Hive boxes | `hive: ^2.2.3`, `hive_flutter: ^1.1.0` |
| State | Provider | `provider: ^6.1.2` (ChangeNotifier) |
| OTP yetkazish | Telegram Gateway | backend orqali, server-side verify |
| Google Sign-In | google_sign_in | token verify backend'da (`/auth/google`) |
| Ob-havo | OpenWeatherMap | backend proxy (`GET /api/v1/weather`) |

**Deploy:** Mobile-only (iOS App Store + Google Play). Backend —
o'zimizning FastAPI (lokal dev: `http://localhost:8000`, `make setup`).
**Package name:** `uz.dizcoveruzb.discoveruzb`.
**Versiya:** 1.2.1+11.
**Repozitoriy:** `https://github.com/mrdil07/discoveruzb.git`.

Batafsil: `docs/TZ.md`.

---

## 3. Har o'zgarishdan keyin majburiy qadamlar

O'zgarish turini aniqlang va mos keladigan harakatni bajaring.

### 🔴 Kategoriya A — TZ + CHANGELOG (ikkalasini yangilash MAJBURIY)

Quyidagi holatlarda:

- Yangi DB jadval/ustun qo'shildi, o'chirildi, type o'zgardi (alembic).
- Yangi backend endpoint/router yoki migratsiya qo'shildi.
- Yangi ekran (Screen), tab yoki bottom navigation elementi qo'shildi.
- Mavjud ViewModel butunlay qayta yozildi.
- Mavjud feature o'chirildi yoki vaqtincha o'chirib qo'yildi.
- Autentifikatsiya/avtorizatsiya mantig'i o'zgardi (OTP, JWT, Google Sign-In).
- Tashqi servis qo'shildi yoki o'chirildi (Telegram Gateway, OpenWeather, push).
- Environment variable / `--dart-define` kalit qo'shildi yoki o'chirildi.
- Build konfiguratsiyasi o'zgardi (Android `build.gradle`, iOS `Info.plist`,
  signing, `pubspec.yaml` major versiya).
- Flutter SDK yoki major paket versiyasi o'zgardi (`provider`, `dio`).

**TZ ning qaysi bo'limi yangilanadi:**

| O'zgarish | TZ bo'limi |
|-----------|-----------|
| Yangi ekran / feature / RPC | §4 Funksional talablar |
| DB jadval / migratsiya o'zgarishi | §6 Ma'lumotlar strukturasi |
| Stack / paket / SDK | §5 Texnik talablar |
| Build / store deploy o'zgarishi | §5 + §9 |
| Yangi modul/feature | §4 + §9 |
| Auth/xavfsizlik | §4 + §9 |

**⚠️ Qo'shimcha — §9 Joriy holat:**
HAR Kategoriya A o'zgarishida §9 ham yangilansin — bu TZ ning eng
tez-tez yangilanadigan bo'limi:

- Yangi feature tugadi → `🔄 Ishlab chiqilmoqda` dan `✅ Tugallangan` ga ko'chirilsin.
- Yangi feature boshlandi → `🔄 Ishlab chiqilmoqda` ga qo'shilsin.
- Yangi technical debt aniqlandi → `⚠️ Tugallanmagan` ga qo'shilsin.
- Technical debt bartaraf etildi → ro'yxatdan o'chirilsin.

Bu odatda 2–3 qator o'zgartirish — katta vaqt talab qilmaydi.

---

### 🟡 Kategoriya B — faqat CHANGELOG (TZ tegilmaydi)

- Bug tuzatish (schema va tashqi xulq o'zgarmasa).
- Kod refactor (funksionallik o'zgarmasa).
- Performance optimizatsiya (cache, query tuzatish, `Selector` joriy etish).
- UI ko'rinishi o'zgarishi (button rangi, spacing, animation).
- Log xabarlari (`debugPrint`) qo'shilishi yoki o'zgartirilishi.
- Test qo'shilishi.
- Komment qo'shilishi yoki to'g'rilanishi.
- Mavjud backend so'rovida javob maydonlarini cheklash (tashqi xulq o'zgarmasa).
- Mavjud funksiya ichida algoritm o'zgarishi.
- Paket patch/minor versiya yangilanishi.

---

### ⚪ Kategoriya C — hech narsa yozilmaydi

- Typo tuzatish (kod yoki kommentda).
- `dart format` ishlatish.
- Import tartibini to'g'rilash.
- Bo'sh qatorlar, trailing whitespace tozalash.
- Lokal variable nomini kichik o'zgartirish (public API emas bo'lsa).
- `print()` → `debugPrint()` almashtirish.

---

### Ikkilansa — so'rang

"Bu o'zgarish A mi yoki B mi?" degan savol tug'ilsa — **taxmin qilmang**,
foydalanuvchidan aniqlang. Kategoriya noto'g'ri tanlansa — TZ yoki
o'zgarishlar tarixi ishonchini yo'qotadi.

---

### CHANGELOG yozuv formati

```markdown
## YYYY-MM-DD

### `fayl/yo-li.dart`
**Modul:** <komponent nomi — bo'lim>
**Kategoriya:** A | B
**Sabab:** <nega qilindi — technical yoki business sabab>
**TZ ta'siri:** <qaysi bo'lim yangilandi, agar A bo'lsa> | <yo'q, agar B>
**Kommit:** `<hash>` (agar bor bo'lsa)
```

Eng yangi yozuvlar — yuqorida. Bir sessiyadagi bir nechta bog'liq
o'zgarish bitta yozuvga birlashtirilsin.

---

## 4. Batafsil qoidalar

| Mavzu | Hujjat |
|-------|--------|
| Kod stili | `docs/coding-standards.md` |
| Xavfsizlik, sirlar, OTP | `docs/security-rules.md` |
| Texnik topshiriq | `docs/TZ.md` |
| O'zgarishlar tarixi | `docs/CHANGELOG.md` |

Ushbu qoidalar **majburiy** — tegishli hujjatni o'qimasdan tegishli
sohada ish boshlanmasin.

---

## 5. Eng muhim taqiqlar (qisqa)

- **Sir/parolni kodga yozmaslik.** `--dart-define` yoki `.env` (
  `flutter_dotenv`) faylga yozing. Batafsil: `docs/security-rules.md`.
- **Mobil ilovadan DB'ga yoki tashqi API'ga to'g'ridan-to'g'ri ulanish**
  — taqiqlanadi. Barcha aloqa faqat `ApiClient` (backend) orqali.
- **Xatolikni yutib yuborish** (`try {} catch (e) { debugPrint(...); return []; }`) —
  taqiqlanadi. Foydalanuvchiga ko'rinadigan xato yoki retry mexanizmi bo'lsin.
- **Telefon raqami orqali admin tekshiruvi** (`if (phone == '+998...')`) —
  taqiqlanadi. Backend `users.role` / `is_admin` maydonini ishlating.
- **OTP ni client-side tekshirish** (`if (otp != _otpCode)`) — taqiqlanadi.
  Backend `POST /auth/telegram/verify-otp` server-side bo'lsin.
- **Force push** asosiy va reliz branchlariga (`main`, `release/*`) — taqiqlanadi.
- **Production DB'da manual UPDATE/DELETE** — oldin backup va
  tranzaksiya ichida.
- **Mavjud `places_model` ga majburiy field qo'shish** (`required`) —
  eski qatorlar Freezed deserializerida yiqiladi. `@Default(...)` bering.

---

## 6. Ehtiyot bo'lish kerak fayllar

| Fayl | Sabab |
|------|-------|
| `lib/models/places_model.dart`, `users_model.dart`, `gallery_model.dart`, `comments.dart` | Freezed model — schema o'zgarsa `dart run build_runner build` kerak |
| `lib/service/api_client.dart`, `auth_service.dart` | Auth/connection root — barcha xizmatlar bog'liq |
| `lib/service/data_service.dart` | Asosiy repository — barcha ViewModel chaqiradi |
| `lib/main.dart` | Provider tree, Hive init |
| `lib/view_models/otp_vm.dart` | OTP/auth oqim — security critical |
| `lib/l10n/app_*.arb` | UZ/RU/EN tarjimalar — ekran o'zgarsa kalit qo'shish kerak |
| `pubspec.yaml`, `android/app/build.gradle`, `ios/Runner/Info.plist` | Build/release |
| `backend/alembic/versions/` | DB schema migratsiya |
| `.env`, `--dart-define` qiymatlari | Sirlar |

Ushbu fayllarga teginishdan oldin — sababni foydalanuvchiga aytib,
tasdiqlashni oling.

---

## 7. Parallel sessiyalar

Bir vaqtda bitta loyihada bir nechta Claude sessiyasi ishlayotgan
bo'lishi mumkin. Shuning uchun:

1. **Fayl tahrirlashdan oldin** — uni qayta o'qing. Boshqa sessiya
   o'zgartirgan bo'lishi mumkin.
2. **CHANGELOG ga yozishdan oldin** — oxirgi 5 yozuvni o'qing,
   takrorlanish bo'lmasin.
3. **TZ.md ga yozishdan oldin** — faylni qayta o'qing.
4. Fayl yaqinda (oxirgi 5 daqiqada) o'zgarganini sezsangiz —
   foydalanuvchini ogohlantiring, boshqa sessiya faol bo'lishi mumkin.

---

## 8. Til

- **UI matnlari:** O'zbek (asosiy). Majburiy holatda Rus va Ingliz.
- **Kod (nom, komment):** inglizcha.
- **Kommitlar, hujjatlar (TZ, CHANGELOG):** O'zbek.
- **Lokalizatsiya kalitlari:** `app_uz.arb` (asosiy), `app_ru.arb`, `app_en.arb`.
  Yetishmagan kalit — release blokirovchi.

---

## 9. Noaniqlik holatida

Avval qarang: `docs/TZ.md`, `CLAUDE.md`, `git log`.

Keyin foydalanuvchidan so'rang — xususan quyidagi hollarda:

- Xavfsizlikka taalluqli qaror (parol, token, autentifikatsiya, RLS).
- Ma'lumot yo'qotish mumkin bo'lgan amal (`DROP TABLE`, `DELETE FROM`,
  alembic downgrade).
- Production backend/DB'da o'zgarish.
- Tashqi xizmatga pullik chaqiruv (SMS, push, payment).
- App Store / Play Store ga yangi build chiqarish.

"Ehtimol shunday" degan taxmin bilan ishga kirishmang.
Har qanday ikkilanish holatida — **to'xtang va so'rang**.

---

## 10. Ushbu hujjat yangilanishi

`CLAUDE.md` o'zi ham hujjat — yangi qoida qo'shilsa yoki loyiha
shartlari o'zgarsa, darhol yangilansin. O'zgarish CHANGELOG da qayd
qilinsin:

```markdown
## YYYY-MM-DD

### `CLAUDE.md`
**Modul:** Loyiha qoidalari
**Kategoriya:** A
**Sabab:** <nima qo'shildi yoki o'zgardi va nega>
```

---

**Versiya:** 1.0
**Oxirgi yangilangan:** 2026-05-09
**Muallif:** MrDil (Dilshodbek007)
