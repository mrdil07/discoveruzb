import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Utils {
  /// Xatoni foydalanuvchiga ko'rsatish uchun qisqa xabarga aylantiradi.
  ///
  /// Xom `e.toString()` (DioException dump, stack va h.k.) UI'ga
  /// chiqarilmaydi — texnik tafsilot faqat debug logga yoziladi.
  static String friendlyError(String context, Object e) {
    debugPrint('$context: $e');
    if (e is DioException) {
      switch (e.type) {
        case DioExceptionType.connectionError:
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          return '$context. Server bilan aloqa yo\'q — '
              'internetni tekshirib, qayta urinib ko\'ring.';
        case DioExceptionType.badResponse:
          final code = e.response?.statusCode;
          return '$context. Server xatosi${code != null ? ' ($code)' : ''} — '
              'birozdan so\'ng qayta urinib ko\'ring.';
        default:
          break;
      }
    }
    return '$context. Qayta urinib ko\'ring.';
  }

  static void fireToast(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      backgroundColor: Colors.tealAccent,
      fontSize: 18,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      textColor: Colors.red.shade900,
    );
  }
}
