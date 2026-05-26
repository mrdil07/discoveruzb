import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// DevSMS provider orqali OTP yuborish.
///
/// Konfiguratsiya `--dart-define` orqali kiritiladi:
///
/// ```bash
/// flutter run \
///   --dart-define=DEVSMS_TOKEN=<bearer_token> \
///   --dart-define=DEVSMS_BASE_URL=https://devsms.uz/api/send_sms.php
/// ```
///
/// Hech qachon tokenni kodga hardcoded yozmang
/// (`docs/security-rules.md`).
class SmsService {
  static const String _baseUrl = String.fromEnvironment(
    'DEVSMS_BASE_URL',
    defaultValue: 'https://devsms.uz/api/send_sms.php',
  );
  static const String _token = String.fromEnvironment(
    'DEVSMS_TOKEN',
    defaultValue: '',
  );

  /// Tasodifiy 6 xonali OTP kod generatsiya qiladi.
  static String generateOTP() {
    final random = Random.secure();
    return (100000 + random.nextInt(900000)).toString();
  }

  /// DevSMS API orqali OTP SMS yuboradi.
  ///
  /// `phoneNumber` formati: `+998XXXXXXXXX` yoki `998XXXXXXXXX`.
  /// DevSMS `+` belgisini qabul qilmaydi — avtomatik olib tashlanadi.
  static Future<bool> sendOTP(String phoneNumber, String otpCode) async {
    if (_token.isEmpty) {
      debugPrint(
        'DEVSMS_TOKEN berilmagan. '
        '`--dart-define=DEVSMS_TOKEN=...` orqali bering.',
      );
      return false;
    }

    try {
      final phone = phoneNumber.replaceAll('+', '');

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'phone': phone,
          'message': 'MRDIL: Ilovaga kirish uchun parol: $otpCode',
        }),
      );

      // PII himoyasi: telefonning oxirgi 4 xonasini ko'rsatamiz.
      final maskedPhone = phone.length >= 4
          ? '***${phone.substring(phone.length - 4)}'
          : '***';
      debugPrint('DevSMS response for $maskedPhone: ${response.statusCode}');

      if (response.statusCode == 200) {
        return true;
      } else {
        debugPrint('DevSMS error code: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('DevSMS exception: $e');
      return false;
    }
  }
}
