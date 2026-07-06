import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

/// DiscoverUzb backend API uchun HTTP klient.
///
/// Konfiguratsiya `--dart-define` orqali:
/// ```bash
/// flutter run --dart-define=API_BASE_URL=https://api.discoveruzb.uz
/// ```
class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    // Faqat lokal dev uchun default. Release build'da API_BASE_URL
    // berilishi MAJBURIY — `_build()` dagi tekshiruv buni ushlaydi.
    defaultValue: kReleaseMode ? '' : 'http://localhost:8000',
  );

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  late final Dio dio = _build();

  Dio _build() {
    if (_baseUrl.isEmpty) {
      throw StateError(
        'API_BASE_URL berilmagan. Release build:\n'
        'flutter build ipa --dart-define=API_BASE_URL=https://api.example.uz',
      );
    }
    if (kReleaseMode && !_baseUrl.startsWith('https://')) {
      throw StateError(
        'API_BASE_URL release buildda https:// bilan boshlanishi shart '
        '(hozir: $_baseUrl).',
      );
    }
    final d = Dio(
      BaseOptions(
        baseUrl: '$_baseUrl/api/v1',
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 30),
        contentType: 'application/json',
        responseType: ResponseType.json,
        headers: {'Accept': 'application/json'},
      ),
    );

    d.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Auth oqimida tokensiz so'rovlar bor — `noAuth` flag orqali
          // belgilanadi (extra: {'noAuth': true}).
          final noAuth = options.extra['noAuth'] == true;
          if (!noAuth) {
            final token = await _storage.read(key: _accessTokenKey);
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          return handler.next(options);
        },
        onError: (e, handler) async {
          // 401 — refresh token bilan urinib ko'rish
          if (e.response?.statusCode == 401 &&
              e.requestOptions.extra['_retry'] != true &&
              e.requestOptions.path != '/auth/refresh') {
            final refreshed = await _tryRefresh();
            if (refreshed) {
              // Asl so'rovni qayta yuborish
              final newOptions = e.requestOptions.copyWith();
              newOptions.extra['_retry'] = true;
              try {
                final response = await d.fetch(newOptions);
                return handler.resolve(response);
              } catch (retryError) {
                return handler.reject(
                  retryError is DioException ? retryError : e,
                );
              }
            }
          }
          return handler.next(e);
        },
      ),
    );

    if (kDebugMode) {
      d.interceptors.add(
        PrettyDioLogger(
          requestHeader: false,
          requestBody: true,
          responseHeader: false,
          responseBody: false,
          error: true,
          maxWidth: 100,
        ),
      );
    }

    return d;
  }

  Future<bool> _tryRefresh() async {
    try {
      final refreshToken = await _storage.read(key: _refreshTokenKey);
      if (refreshToken == null || refreshToken.isEmpty) return false;

      final response = await dio.post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
        options: Options(extra: {'noAuth': true}),
      );
      final data = response.data;
      if (data == null) return false;

      await saveTokens(
        access: data['access_token'] as String,
        refresh: data['refresh_token'] as String? ?? refreshToken,
      );
      return true;
    } on DioException catch (_) {
      // Refresh token ham yaroqsiz — logout
      await clearTokens();
      return false;
    }
  }

  // ===== Token boshqaruvi =====

  Future<void> saveTokens({
    required String access,
    required String refresh,
  }) async {
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: access),
      _storage.write(key: _refreshTokenKey, value: refresh),
    ]);
  }

  Future<String?> readAccessToken() => _storage.read(key: _accessTokenKey);

  Future<String?> readRefreshToken() => _storage.read(key: _refreshTokenKey);

  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
    ]);
  }

  Future<bool> get isAuthenticated async {
    final token = await readAccessToken();
    return token != null && token.isNotEmpty;
  }
}
