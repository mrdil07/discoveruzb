import 'dart:convert';

import 'package:discoveruzb/models/weather_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/places_model.dart';
import '../service/data_service.dart';

const String apiKey = '09d7f0162c04c0035e95d2891522debf';

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

  Future<void> toggleLikePost(Place place, String userId) async {
    _clearError();
    try {
      List<String> updatedLiked = List.from(place.liked); // Create a mutable copy
      if (updatedLiked.contains(userId)) {
        updatedLiked.remove(userId);
      } else {
        updatedLiked.add(userId);
      }
      // Update likeCount based on the updatedLiked list
      Place updatedPlace = place.copyWith(liked: updatedLiked, likeCount: updatedLiked.length);
      await DataService.likePost(updatedPlace);
      // Update the place in the ViewModel's list if it's there
      int index = _places.indexWhere((p) => p.id == updatedPlace.id);
      if (index != -1) {
        _places[index] = updatedPlace;
      }
      notifyListeners();
    } catch (e) {
      _setError('Layk holatini o\'zgartirishda xatolik: ${e.toString()}');
    }
  }

  Future<void> toggleSavePost(Place place, String userId) async {
    _clearError();
    try {
      List<String> updatedSaved = List.from(place.saved); // Create a mutable copy
      if (updatedSaved.contains(userId)) {
        updatedSaved.remove(userId);
      } else {
        updatedSaved.add(userId);
      }
      Place updatedPlace = place.copyWith(saved: updatedSaved);
      await DataService.savePost(updatedPlace);
      // Update the place in the ViewModel's list if it's there
      int index = _places.indexWhere((p) => p.id == updatedPlace.id);
      if (index != -1) {
        _places[index] = updatedPlace;
      }
      notifyListeners();
    } catch (e) {
      _setError('Saqlash holatini o\'zgartirishda xatolik: ${e.toString()}');
    }
  }

  Future<void> fetchWeather(double lat, double lon) async {
    _setLoadingWeather(true);
    _clearError();
    try {
      String url =
          'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric';
      var res = await http.get(Uri.parse(url));
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
