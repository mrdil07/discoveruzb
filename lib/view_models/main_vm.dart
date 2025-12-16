import 'package:flutter/material.dart';

import '../service/pref_service.dart';

class MainViewModel extends ChangeNotifier {
  int _currentPage = 0;
  int get currentPage => _currentPage;

  final PageController pageController = PageController();
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
      String? userId = await Prefs.loadUserId();
      uid = userId;
      notifyListeners();
    } catch (e) {
      _setError('Foydalanuvchi ID yuklashda xatolik: ${e.toString()}');
    }
  }

  void onPageChanged(int index) {
    _currentPage = index;
    notifyListeners();
  }

  void onTap(int index) {
    _currentPage = index;
    pageController.animateToPage(_currentPage,
        duration: const Duration(milliseconds: 200), curve: Curves.easeIn);
    notifyListeners();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
