# Kod yozish standartlari

> Bu hujjat **DiscoverUzb** loyihasi uchun. Loyiha Flutter/Dart-only,
> shuning uchun Python/TS bo'limlari olib tashlangan. Yangi til/stack
> qo'shilsa — shu yerga bo'lim qo'shing.

---

## Dart / Flutter (asosiy stack)

### Arxitektura

- **Pattern:** MVVM (View → ViewModel → Service/Repository → Supabase).
- **Folder layout:** `lib/screens/`, `lib/view_models/`, `lib/service/`,
  `lib/models/`, `lib/widgets/`, `lib/constants/`, `lib/l10n/`.
  Kelajakda feature-based ko'chirish ko'rib chiqilsin
  (`lib/features/<feature>/{data,domain,presentation}/`).
- **State:** `provider: ^6.1.2` + `ChangeNotifier`. Yangi VM larni
  `lib/view_models/` ga qo'shing va `main.dart` `MultiProvider`'ga
  registratsiya qiling.
  > TODO: Riverpod/Bloc'ga migratsiya — TZ §8.4.
- **Navigatsiya:** hozirda `Navigator.push(MaterialPageRoute(...))` —
  TODO: `go_router` joriy etilsin.
- **DI:** yo'q (static metodlar). Yangi service yaratganda DI
  imkoniyatini ko'rib chiqing (`get_it` yoki Riverpod `Provider`).

### Null safety va tip xavfsizligi

- **Null safety:** to'liq qo'llaniladi (`sound null safety`).
- **Force unwrap (`!`):** faqat istisno hollarda. Asosan
  `if (x != null) { ... }` yoki `x?.field ?? default`.
- **Type:** har funksiya parametr va qaytish turi belgilansin.
  `Future` o'rniga `Future<void>` yoki `Future<T>`.
- **`dynamic` taqiqlanadi** — JSON parse Freezed `fromJson` orqali.

### Nomlash konventsiyasi

- `lowerCamelCase` — funksiya, metod, o'zgaruvchi, fayl ichidagi konstanta.
- `UpperCamelCase` — class, enum, typedef, mixin.
- `_lowerCamelCase` — private (file scope).
- `lowercase_with_underscores` — fayl nomi
  (`product_box.dart`, `home_page.dart`).
  > Joriy holatda `detailsPlace.dart`, `creating_gallery.dart` —
  > inkonsistent. Yangi fayllarda `snake_case` ishlatib boring.
- `kConstantName` — global/top-level konstanta (Material qoidasi).

### Modern Dart (3.x)

Yangi yozilayotgan kod uchun majburiy:

- `super.key` — `Key? key, super(key: key)` o'rniga.
  ```dart
  // ✅ Yangi:
  const HomePage({super.key});

  // ❌ Eski:
  const HomePage({Key? key}) : super(key: key);
  ```
- `withValues(alpha: ...)` — `withOpacity(...)` o'rniga (Flutter 3.27+).
- **Records** — bir necha qiymatni qaytarish uchun
  (`(double lat, double lon)`).
- **Pattern matching** — `switch` expression, `if-case`.
- **Sealed classes** — `Result<T>` uchun.
- `final` — har joyda mahalliy o'zgaruvchilar uchun, agar mutatsiya
  bo'lmasa.
- `const` — kompilatsiya konstantasi imkon bo'lsa
  (`const SizedBox(height: 10)`).

### Freezed model'lar

- Har model `lib/models/<name>.dart` + `.freezed.dart` + `.g.dart`.
- Schema o'zgarganda majburiy:
  ```bash
  dart run build_runner build --delete-conflicting-outputs
  ```
- `@Default([])`, `@Default('')`, `@Default(0)` — eski qatorlar buzilmasin.
- Yangi field qo'shilganda **majburiy `required` qo'ymang** — eski
  Supabase qatorlarida bo'lmasligi mumkin. `String?` yoki `@Default`
  ishlating.

### Provider va rebuild optimallashtirish

- **`Provider.of<T>(context, listen: true)`** butun widget'ni rebuild
  qiladi — minimal kontekstda ishlatib, `Consumer<T>` yoki `Selector<T, R>`
  bilan almashtiring.
  ```dart
  // ✅ Yaxshi:
  final isLoading = context.select((HomeViewModel vm) => vm.isLoading);

  // ❌ Yomon:
  final vm = Provider.of<HomeViewModel>(context, listen: true);
  if (vm.isLoading) { ... }
  ```
- `Consumer.builder` ichida `addPostFrameCallback` orqali navigatsiya
  qilmang — cheksiz loop ehtimoli (misol: `splash_page.dart`).
- ViewModel'da `_setLoading(false)` har `try/finally` da chaqirilsin.

### Xatolik boshqaruvi

**Taqiqlanadi:**

```dart
// ❌ Silent failure:
try {
  ...
} catch (e) {
  debugPrint('error: $e');
  return [];
}
```

**Tavsiya:**

```dart
// ✅ ViewModel'da error state:
try {
  ...
} catch (e) {
  _setError('Foydalanuvchiga ko\'rinadigan xato xabari');
  rethrow; // yoki: handle gracefully
}
```

ViewModel'da `_error` field bor — uni UI'da `SnackBar` orqali ko'rsating.

### Logging

- `print()` taqiqlanadi (production'da console'ga chiqadi). `debugPrint`
  ishlating — release build'da o'chiriladi.
- **PII (telefon, OTP, parol)** log'ga to'liq tushmasin —
  `+998***1234` ko'rinishida masklang.
- TODO: `logger` paketi yoki Sentry breadcrumb.

### Secure storage

- Foydalanuvchi tokeni / sezgir ID lar `flutter_secure_storage` da
  saqlansin (TODO: hozirda `SharedPreferences`'da).
- `Prefs` class — faqat sezgir bo'lmagan ma'lumot uchun (theme tanlovi,
  til tanlovi va h.k.).

### Sirlar

- **Hech qachon kodda hardcoded yozmang.**
- `--dart-define` yoki `flutter_dotenv` orqali:
  ```dart
  const url = String.fromEnvironment('SUPABASE_URL');
  ```
- Batafsil: `docs/security-rules.md`.

### Async / await

- I/O metodlari `async` bo'lsin, callback chain'idan saqlaning.
- `Future.wait([...])` — parallel chaqiruvlar uchun
  (misol: `home_vm.refreshAllData`).
- `BuildContext` async chaqiruvdan keyin ishlatishdan oldin
  `if (!context.mounted) return;` tekshiring.
  ```dart
  Future<void> signOut(BuildContext context) async {
    await Prefs.removeUserId();
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(...);
  }
  ```

### Formatlash va lint

- **Formatter:** `dart format lib/`. CI'da `--set-exit-if-changed`.
- **Linter:** `flutter analyze`. `analysis_options.yaml`.
  > TODO: `flutter_lints: ^5.0.0` ga yangilash + qat'iy qoidalar
  > (`prefer_const_constructors`, `avoid_print`, `unnecessary_this`,
  > `require_trailing_commas`).
- **Codegen:** Freezed/JSON o'zgarganda majburiy
  `dart run build_runner build`.

### Asset'lar

- `assets/images/` — rasm.
- `assets/icons/` — SVG ikonkalar (`flutter_svg`).
- `pubspec.yaml`'da har asset qo'shilganda `flutter pub get`.
- Image kompressiya: `image_picker` `imageQuality: 50` (yaxshi).
  TODO: `flutter_image_compress` + WebP.

### Localization

- Yangi UI matn — **majburiy ravishda** `lib/l10n/app_uz.arb`,
  `app_ru.arb`, `app_en.arb` ga qo'shilsin.
- Auto-generation: `flutter gen-l10n` (`l10n.yaml` config'iga ko'ra).
- Hardcoded matnlar (`Text('Salom')`) — release blokirovchi.

---

## Umumiy qoidalar

- **Komment:** nima qilinayotgani emas, **nega** qilinayotgani yozilsin.
  Kod o'zini tushuntirsa — komment yozmang. Komment-out kod
  taqiqlanadi (Git tarixi bor).
- **Magic number:** konstantaga ko'chirilsin — `lib/constants/colors.dart`
  yoki tegishli class ichida `static const`.
- **Dublikat:** uchinchi marta takrorlanayotganda umumiy util funksiya
  yaratilsin (`lib/service/utils.dart` yoki tegishli widget).
  Misol: `detailsPlace.dart`'da `MapLauncher` bottom sheet 2 marta
  takrorlanadi → bitta `_showMapsBottomSheet` metoddiga ajratilsin.
- **Mavjud naqshga moslashish:** yangi modul/sahifa qo'shganda mavjud
  bir-ikki o'xshash misolni o'rganib, shu tuzilishga rioya qiling.
  Yangi naqsh kiritmoqchi bo'lsangiz — sababini foydalanuvchi bilan
  kelishib oling.
- **Kommitlar atomar:** bitta kommit — bitta mantiqiy o'zgarish.
  Format/refactor va funksional o'zgarishni alohida kommitlarda saqlang.
- **`pubspec.yaml`'da paket qo'shilsa:** `pubspec.lock` ham kommitga
  kirsin. Major versiya o'zgarishi — Kategoriya A
  (`CLAUDE.md §3` ga qarang).

---

## Til

- **UI matnlari:** O'zbek (asosiy), majburiy holatda Rus va Ingliz.
- **Kod (nomlar, kommentlar):** inglizcha.
- **Lokalizatsiya kalitlari:** `app_uz.arb`, `app_ru.arb`, `app_en.arb` —
  uchchasi to'liq, yetishmagan kalit release blokirovchi.
- **Kommit xabarlari va docs (TZ, CHANGELOG):** O'zbek.
