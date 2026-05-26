import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/users_model.dart';
import '../screens/introPages/login_with_phone.dart';
import 'api_client.dart';

/// Auth service — backend bilan ishlaydigan to'liq auth oqim.
///
/// Endpointlar (`backend/app/api/v1/auth.py`):
/// - `POST /auth/telegram/send-otp`
/// - `POST /auth/telegram/verify-otp`
/// - `POST /auth/google`
/// - `POST /auth/refresh`
/// - `POST /auth/logout`
/// - `GET  /auth/me`
class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final _api = ApiClient.instance;

  /// Google Sign-In klient — iOS / Android client ID lar Google
  /// Cloud Console'da sozlanadi. Mobile platforma'da
  /// `GoogleService-Info.plist` (iOS) va `google-services.json` (Android)
  /// ikkalasi ham FAQAT Sign-In uchun kerak — Firebase emas.
  final _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile', 'openid'],
  );

  // ===== Telegram OTP =====

  Future<TelegramOtpResult> sendTelegramOtp(String phone) async {
    final response = await _api.dio.post<Map<String, dynamic>>(
      '/auth/telegram/send-otp',
      data: {'phone': phone},
      options: Options(extra: {'noAuth': true}),
    );
    final data = response.data!;
    return TelegramOtpResult(
      requestId: data['request_id'] as String,
      expiresIn: data['expires_in'] as int,
      delivery: data['delivery'] as String,
    );
  }

  Future<AuthResult> verifyTelegramOtp({
    required String phone,
    required String code,
  }) async {
    final response = await _api.dio.post<Map<String, dynamic>>(
      '/auth/telegram/verify-otp',
      data: {'phone': phone, 'code': code},
      options: Options(extra: {'noAuth': true}),
    );
    return _handleAuthResponse(response.data!);
  }

  // ===== Google Sign-In =====

  Future<AuthResult?> signInWithGoogle() async {
    final account = await _googleSignIn.signIn();
    if (account == null) return null; // user bekor qildi

    final auth = await account.authentication;
    final idToken = auth.idToken;
    if (idToken == null) {
      throw const AuthException('Google ID token olinmadi');
    }

    final response = await _api.dio.post<Map<String, dynamic>>(
      '/auth/google',
      data: {'id_token': idToken},
      options: Options(extra: {'noAuth': true}),
    );
    return _handleAuthResponse(response.data!);
  }

  // ===== Profile =====

  Future<Users> fetchMe() async {
    final response = await _api.dio.get<Map<String, dynamic>>('/auth/me');
    return Users.fromJson(response.data!);
  }

  // ===== Logout =====

  Future<void> signOut(BuildContext context) async {
    final refresh = await _api.readRefreshToken();
    if (refresh != null && refresh.isNotEmpty) {
      try {
        await _api.dio.post(
          '/auth/logout',
          data: {'refresh_token': refresh},
          options: Options(extra: {'noAuth': true}),
        );
      } on DioException {
        // server ulanmasa ham mahalliy tokenlarni o'chirib qo'yamiz
      }
    }
    await _api.clearTokens();
    try {
      await _googleSignIn.signOut();
    } on Exception {
      // Google Sign-In sessiya bo'lmasa ham OK
    }
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginWithPhone()),
      (route) => false,
    );
  }

  // ===== Helpers =====

  Future<AuthResult> _handleAuthResponse(Map<String, dynamic> data) async {
    final access = data['access_token'] as String;
    final refresh = data['refresh_token'] as String;
    await _api.saveTokens(access: access, refresh: refresh);
    return AuthResult(
      user: Users.fromJson(data['user'] as Map<String, dynamic>),
      accessToken: access,
      refreshToken: refresh,
    );
  }
}

class TelegramOtpResult {
  TelegramOtpResult({
    required this.requestId,
    required this.expiresIn,
    required this.delivery,
  });

  final String requestId;
  final int expiresIn;
  final String delivery;
}

class AuthResult {
  AuthResult({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  final Users user;
  final String accessToken;
  final String refreshToken;
}

class AuthException implements Exception {
  const AuthException(this.message);
  final String message;

  @override
  String toString() => 'AuthException: $message';
}
