import 'package:flutter/material.dart';

import '../models/places_model.dart';
import '../service/data_service.dart';

class SearchViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Place> _searchResults = [];
  List<Place> get searchResults => _searchResults;

  String? _error;
  String? get error => _error;

  final TextEditingController searchController = TextEditingController();

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String errorMessage) {
    _error = errorMessage;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  Future<void> searchPosts(String keyword) async {
    if (keyword.trim().isEmpty) {
      _searchResults = [];
      _clearError();
      notifyListeners();
      return;
    }

    _setLoading(true);
    _clearError();
    try {
      List<Place>? results = await DataService.searchPosts(keyword);
      _searchResults = results ?? [];
    } catch (e) {
      _setError('Qidiruvda xatolik: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
