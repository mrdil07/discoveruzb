import 'package:flutter/material.dart';

import '../service/pref_service.dart';

/// UI tilini boshqaradi. Asosiy (default) til — o'zbek.
///
/// Tanlov `SharedPreferences`'da saqlanadi (`Prefs.saveLocale`),
/// Settings sahifasidagi til tanlagich shu VM orqali ishlaydi.
class LocaleProvider extends ChangeNotifier {
  static const supported = [
    Locale('uz'),
    Locale('ru'),
    Locale('en'),
  ];

  Locale _locale = const Locale('uz');
  Locale get locale => _locale;

  LocaleProvider() {
    _load();
  }

  Future<void> _load() async {
    final code = await Prefs.loadLocale();
    if (code != _locale.languageCode) {
      _locale = Locale(code);
      notifyListeners();
    }
  }

  Future<void> setLocale(String code) async {
    if (!supported.any((l) => l.languageCode == code)) return;
    _locale = Locale(code);
    notifyListeners();
    await Prefs.saveLocale(code);
  }
}
