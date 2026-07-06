import 'package:flutter/material.dart';

import '../models/places_model.dart';
import '../service/api_client.dart';
import '../service/data_service.dart';
import '../service/utils.dart';

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
      _setError(Utils.friendlyError('Layk holatini o\'zgartirishda xatolik', e));
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
      _setError(Utils.friendlyError('Saqlash holatini o\'zgartirishda xatolik', e));
    }
  }

  /// Backend proxy: `GET /weather?lat=..&lon=..` — OpenWeatherMap
  /// kaliti server tomonda saqlanadi, javob u yerda keshlanadi.
  Future<void> fetchWeather(double lat, double lon) async {
    _setLoadingWeather(true);
    _clearError();
    try {
      final res = await ApiClient.instance.dio.get<Map<String, dynamic>>(
        '/weather',
        queryParameters: {'lat': lat, 'lon': lon},
      );
      _temp = (res.data?['temp'] as num?)?.toDouble();
    } catch (e) {
      _setError(Utils.friendlyError('Ob-havo ma\'lumotlarini yuklashda xatolik', e));
    } finally {
      _setLoadingWeather(false);
    }
  }

  // openMapsSheet va showImage metodlari ViewModel'dan olib tashlandi.
  // Bu metodlar UI qatlamida chaqirilishi kerak.
}
