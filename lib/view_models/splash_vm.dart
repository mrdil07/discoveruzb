import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../service/pref_service.dart';

class SplashViewModel extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String errorMessage) {
    _error = errorMessage;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  Future<void> checkUserSession() async {
    _setLoading(true);
    _clearError();
    try {
      await Future.delayed(const Duration(seconds: 3)); // Splash screen delay

      FirebaseAuth.instance.authStateChanges().listen((User? user) async {
        if (user != null) {
          _isLoggedIn = true;
          await Prefs.saveUserId(user.uid);
        } else {
          _isLoggedIn = false;
          await Prefs.removeUserId();
        }
        _setLoading(false);
        // Navigating here is not ideal for ViewModel, but for now we keep it simple.
        // Ideally, UI should listen to _isLoggedIn and navigate.
        // For example, using GoRouter or a similar package would be better.
      });
    } catch (e) {
      _setError('Foydalanuvchi sessiyasini tekshirishda xatolik: ${e.toString()}');
      _setLoading(false);
    }
  }
}
