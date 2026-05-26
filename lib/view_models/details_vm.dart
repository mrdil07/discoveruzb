import 'dart:convert';

import 'package:discoveruzb/models/weather_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/places_model.dart';
import '../service/data_service.dart';

/// OpenWeatherMap API key — `--dart-define` orqali beriladi:
///
/// ```bash
/// flutter run --dart-define=OPENWEATHER_API_KEY=<key>
/// ```
///
/// Hech qachon kalitni kodga hardcoded yozmang
/// (`docs/security-rules.md`).
const String _openWeatherApiKey = String.fromEnvironment(
  'OPENWEATHER_API_KEY',
  defaultValue: '',
);

class DetailsVM extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingWeather = false;
  bool get isLoadingWeather => _isLoadingWeather;

  List<Place> _places = [];
  List<Place> get places => _places;

  num? _temp;
  num? get temp => _temp;

  String? _error;
  String? get error => _error;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setLoadingWeather(bool loading) {
    _isLoadingWeather = loading;
    notifyListeners();
  }

  void _setError(String errorMessage) {
    _error = errorMessage;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  /// Backend RPC: `POST /posts/{id}/like` — server `liked` array va
  /// `like_count` o'zi yangilaydi (atomic, race-condition'siz).
  Future<void> toggleLikePost(Place place, String userId) async {
    final id = place.id;
    if (id == null) return;
    _clearError();
    try {
      final updated = await DataService.toggleLike(id);
      final index = _places.indexWhere((p) => p.id == id);
      if (index != -1) {
        _places[index] = updated;
      }
      notifyListeners();
    } catch (e) {
      _setError('Layk holatini o\'zgartirishda xatolik: ${e.toString()}');
    }
  }

  /// Backend RPC: `POST /posts/{id}/save`.
  Future<void> toggleSavePost(Place place, String userId) async {
    final id = place.id;
    if (id == null) return;
    _clearError();
    try {
      final updated = await DataService.toggleSave(id);
      final index = _places.indexWhere((p) => p.id == id);
      if (index != -1) {
        _places[index] = updated;
      }
      notifyListeners();
    } catch (e) {
      _setError('Saqlash holatini o\'zgartirishda xatolik: ${e.toString()}');
    }
  }

  Future<void> fetchWeather(double lat, double lon) async {
    _setLoadingWeather(true);
    _clearError();
    if (_openWeatherApiKey.isEmpty) {
      debugPrint(
        'OPENWEATHER_API_KEY berilmagan. '
        '`--dart-define=OPENWEATHER_API_KEY=...` orqali bering.',
      );
      _setError('Ob-havo xizmati sozlanmagan.');
      _setLoadingWeather(false);
      return;
    }
    try {
      final uri = Uri.https(
        'api.openweathermap.org',
        '/data/2.5/weather',
        {
          'lat': lat.toString(),
          'lon': lon.toString(),
          'appid': _openWeatherApiKey,
          'units': 'metric',
        },
      );
      var res = await http.get(uri);
      if (res.statusCode == 200) {
        Map<String, dynamic> map = jsonDecode(res.body);
        WeatherModel weatherModel = WeatherModel.fromJson(map);
        _temp = weatherModel.main?.temp;
      } else {
        _setError('Ob-havo ma\'lumotlarini olishda xatolik: ${res.statusCode}');
      }
    } catch (e) {
      _setError('Ob-havo ma\'lumotlarini yuklashda xatolik: ${e.toString()}');
    } finally {
      _setLoadingWeather(false);
    }
  }

  // openMapsSheet va showImage metodlari ViewModel'dan olib tashlandi.
  // Bu metodlar UI qatlamida chaqirilishi kerak.
}
