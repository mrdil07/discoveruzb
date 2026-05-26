import 'package:flutter/material.dart';

import '../service/pref_service.dart';

/// Main shell tab boshqaruvi.
///
/// `IndexedStack` ishlatilgani uchun `PageController` kerak emas —
/// shunchaki `_currentPage` indeksi bilan ishlaymiz.
class MainViewModel extends ChangeNotifier {
  int _currentPage = 0;
  int get currentPage => _currentPage;

  String? uid;
  String? _error;
  String? get error => _error;

  void _setError(String errorMessage) {
    _error = errorMessage;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  Future<void> loadUser() async {
    _clearError();
    try {
      final userId = await Prefs.loadUserId();
      uid = userId;
      notifyListeners();
    } catch (e) {
      _setError('Foydalanuvchi ID yuklashda xatolik: ${e.toString()}');
    }
  }

  void onTap(int index) {
    if (_currentPage == index) return;
    _currentPage = index;
    notifyListeners();
  }
}
