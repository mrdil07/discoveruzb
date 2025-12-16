import 'package:flutter/cupertino.dart';
import '../models/places_model.dart';
import '../service/data_service.dart';

class SubCategoryVM extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Place> _subCategory = [];
  List<Place> get subCategory => _subCategory;

  String _selectedRegion = 'Manzil hududi';
  String get selectedRegion => _selectedRegion;

  String? _error;
  String? get error => _error;

  set selectedRegion(String region) {
    _selectedRegion = region;
    notifyListeners();
  }

  Future<void> fetchPostsByCategory(String subCatName) async {
    _setLoading(true);
    _clearError();
    try {
      _subCategory = await DataService.loadFeedsNew(subCatName);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchPostsByCategoryAndRegion(String subCatName) async {
    if (_selectedRegion == 'Manzil hududi') {
      // Fetch all posts if no region is selected
      await fetchPostsByCategory(subCatName);
      return;
    }
    _setLoading(true);
    _clearError();
    try {
      _subCategory = await DataService.loadFeedLocation(subCatName, _selectedRegion);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

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
}
