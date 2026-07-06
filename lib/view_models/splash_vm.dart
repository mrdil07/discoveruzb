import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../service/api_client.dart';
import '../service/auth_service.dart';
import '../service/pref_service.dart';
import '../service/utils.dart';

/// Splash davrida foydalanuvchi session'ini tekshiradi:
///   - Mahalliy JWT mavjudligini.
///   - Token yaroqliligini (backend `/auth/me` chaqirish).
///
/// `isLoggedIn = true` bo'lsa, `MainPage`'ga; aks holda `LoginWithPhone`'ga.
class SplashViewModel extends ChangeNotifier {
  SplashViewModel({AuthService? authService})
      : _auth = authService ?? AuthService.instance;

  final AuthService _auth;
  final _api = ApiClient.instance;

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  /// Guest (preview) rejim — token yo'q, lekin user login'siz
  /// ko'rishni tanlagan.
  bool _isGuest = false;
  bool get isGuest => _isGuest;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  Future<void> checkUserSession() async {
    _setLoading(true);
    _clearError();
    try {
      // Minimum splash davri — UX uchun
      final delay = Future<void>.delayed(const Duration(seconds: 2));

      final hasToken = await _api.isAuthenticated;
      if (!hasToken) {
        // Guest (preview) rejim tanlangan bo'lsa — login'siz MainPage'ga.
        _isGuest = await Prefs.loadGuestMode();
        await delay;
        _isLoggedIn = false;
        _setLoading(false);
        return;
      }

      // Token bor — server tomonida yaroqligini tekshiramiz.
      try {
        await _auth.fetchMe();
        _isLoggedIn = true;
      } on DioException catch (e) {
        // 401 — token yaroqsiz. Boshqa xato — offline bo'lsa ham
        // logged-in deb hisoblaymiz (offline-first UX).
        if (e.response?.statusCode == 401) {
          await _api.clearTokens();
          _isLoggedIn = false;
        } else {
          _isLoggedIn = true; // offline rejim
        }
      } catch (_) {
        _isLoggedIn = true; // boshqa exception — tarmoq, parse va h.k.
      }

      await delay;
    } catch (e) {
      _setError(Utils.friendlyError('Sessiyani tekshirishda xatolik', e));
    } finally {
      _setLoading(false);
    }
  }
}
