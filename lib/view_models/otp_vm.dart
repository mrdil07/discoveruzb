import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../service/auth_service.dart';
import '../service/pref_service.dart';

/// OTP oqimi — backend `/auth/telegram/*` endpoint'lar bilan ishlaydi.
///
/// Hujjatlar:
/// - `backend/app/api/v1/auth.py` — `telegram/send-otp`, `telegram/verify-otp`.
/// - Telegram Gateway: https://core.telegram.org/gateway/api
class OTPViewModel extends ChangeNotifier {
  OTPViewModel({AuthService? authService})
      : _auth = authService ?? AuthService.instance;

  final AuthService _auth;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  bool _isNewUser = false;
  bool get isNewUser => _isNewUser;

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  final TextEditingController pinPutController = TextEditingController();
  final FocusNode pinPutFocusNode = FocusNode();

  Timer? _countdownTimer;
  Duration _myDuration = const Duration(minutes: 5);
  Duration get myDuration => _myDuration;

  String _phoneNumber = '';
  String? _requestId;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void startTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _setCountDown(),
    );
  }

  void _setCountDown() {
    final seconds = _myDuration.inSeconds - 1;
    if (seconds < 0) {
      _countdownTimer?.cancel();
    } else {
      _myDuration = Duration(seconds: seconds);
    }
    notifyListeners();
  }

  void stopTimer() {
    _countdownTimer?.cancel();
    notifyListeners();
  }

  void resetTimer() {
    stopTimer();
    _myDuration = const Duration(minutes: 5);
    startTimer();
    notifyListeners();
  }

  /// `LoginViewModel.sendOtp()` allaqachon OTP yuborgan bo'lsa —
  /// shunchaki telefon raqamini saqlab, timer'ni boshlaymiz.
  /// Qayta yuborish kerak bo'lsa `verifyPhoneNumber` ishlatiladi.
  void attachPhone(String phoneNumber) {
    _phoneNumber = phoneNumber;
    if (_countdownTimer == null || !_countdownTimer!.isActive) {
      startTimer();
    }
  }

  /// Backend orqali OTP yuborish (Telegram Gateway).
  Future<void> verifyPhoneNumber(String phoneNumber) async {
    _setLoading(true);
    clearError();
    _phoneNumber = phoneNumber;

    try {
      final result = await _auth.sendTelegramOtp(phoneNumber);
      _requestId = result.requestId;
      _myDuration = Duration(seconds: result.expiresIn);
      startTimer();
      debugPrint('OTP yuborildi (delivery=${result.delivery})');
    } on DioException catch (e) {
      final message = _extractError(
        e,
        fallback: 'OTP yuborishda xatolik. Qaytadan urinib ko\'ring.',
      );
      _setError(message);
    } catch (e) {
      _setError('OTP yuborishda xatolik: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Backend orqali OTP tekshirish va JWT olish.
  Future<void> signInWithOTP(String otp) async {
    _setLoading(true);
    clearError();
    if (_phoneNumber.isEmpty) {
      _setError('Telefon raqami topilmadi');
      _setLoading(false);
      return;
    }

    try {
      final result = await _auth.verifyTelegramOtp(
        phone: _phoneNumber,
        code: otp,
      );
      // Bookkeeping: ba'zi ekranlar hali Prefs.userId'ga tayanadi
      // (legacy). Sprint 5 da olib tashlanadi.
      await Prefs.saveUserId(result.user.uid);
      await Prefs.savePhone(_phoneNumber);
      if (result.user.fullname.isNotEmpty &&
          result.user.fullname != 'Foydalanuvchi') {
        await Prefs.saveFullname(result.user.fullname);
      }

      // Yangi user — registration ekrani'ga; aks holda main page.
      _isNewUser = result.user.fullname == 'Foydalanuvchi';
      _isLoggedIn = true;
      stopTimer();
      notifyListeners();
    } on DioException catch (e) {
      final message = _extractError(e, fallback: 'OTP noto\'g\'ri');
      _setError(message);
    } catch (e) {
      _setError('OTPni tasdiqlashda xatolik: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  String _extractError(DioException e, {required String fallback}) {
    final response = e.response;
    if (response?.data is Map<String, dynamic>) {
      final detail = (response!.data as Map<String, dynamic>)['detail'];
      if (detail is String) return detail;
    }
    return fallback;
  }

  @override
  void dispose() {
    pinPutController.dispose();
    pinPutFocusNode.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }
}
