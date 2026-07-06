import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../service/auth_service.dart';
import '../service/utils.dart';

/// Login oqimi:
///   1. Foydalanuvchi telefon raqamini kiritadi.
///   2. `AuthService.sendTelegramOtp(phone)` chaqiriladi — backend
///      Telegram Gateway orqali OTP yuboradi.
///   3. Muvaffaqiyatli bo'lsa, UI `OTPScreen`'ga o'tadi.
///
/// Backend kontrakti: `POST /auth/telegram/send-otp` →
/// `{ request_id, expires_in, delivery }`.
class LoginViewModel extends ChangeNotifier {
  LoginViewModel({AuthService? authService})
      : _auth = authService ?? AuthService.instance;

  final AuthService _auth;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final TextEditingController phoneController = TextEditingController();
  String _phoneNumber = '';
  String get phoneNumber => _phoneNumber;

  /// `sendOtp` muvaffaqiyatli bo'lganda E.164 formatdagi to'liq telefon.
  String? _normalizedPhone;
  String? get normalizedPhone => _normalizedPhone;

  /// Backenddan kelgan TTL (sekundlarda).
  int _otpExpiresIn = 0;
  int get otpExpiresIn => _otpExpiresIn;

  /// `telegram` | `sms` | `unknown` | `dev`
  String _otpDelivery = '';
  String get otpDelivery => _otpDelivery;

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

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void updatePhoneNumber(String value) {
    _phoneNumber = value;
  }

  /// Telefon raqamini E.164 formatga keltiradi (`+998XXXXXXXXX`).
  String _normalize(String raw) {
    var digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length == 9) {
      digits = '998$digits'; // Uzbekistan default
    }
    return '+$digits';
  }

  /// `true` qaytsa — UI `OTPScreen`'ga o'tadi.
  Future<bool> sendOtp() async {
    if (_phoneNumber.trim().isEmpty) {
      _setError('Telefon raqamini kiriting');
      return false;
    }
    _setLoading(true);
    clearError();
    try {
      final normalized = _normalize(_phoneNumber);
      final result = await _auth.sendTelegramOtp(normalized);
      _normalizedPhone = normalized;
      _otpExpiresIn = result.expiresIn;
      _otpDelivery = result.delivery;
      return true;
    } on DioException catch (e) {
      _setError(_extractDioError(e, fallback: 'OTP yuborishda xatolik'));
      return false;
    } catch (e) {
      _setError(Utils.friendlyError('OTP yuborishda xatolik', e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  String _extractDioError(DioException e, {required String fallback}) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final detail = data['detail'];
      if (detail is String) return detail;
    }
    return fallback;
  }

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }
}
