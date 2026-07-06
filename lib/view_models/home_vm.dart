import 'package:flutter/material.dart';

import '../models/places_model.dart';
import '../models/users_model.dart';
import '../service/api_client.dart';
import '../service/data_service.dart';
import '../service/hive_service.dart';
import '../service/pref_service.dart';
import '../service/utils.dart';

class HomeViewModel extends ChangeNotifier {
  List<Place> _famousPlaces = [];
  List<Place> get famousPlaces => _famousPlaces;

  List<Place> _recPosts = [];
  List<Place> get recPosts => _recPosts;

  List<Place> _newAdded = [];
  List<Place> get newAdded => _newAdded;

  String _searchedPlace = '';
  String get searchedPlace => _searchedPlace;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _imgUrl = '';
  String get imgUrl => _imgUrl;

  String _fullName = '...';
  String get fullName => _fullName;

  /// Guest (preview) rejim — token yo'q, `/auth/me` chaqirilmaydi.
  bool _isGuest = false;
  bool get isGuest => _isGuest;

  String _userId = '';
  String get userId => _userId;

  String _phone = '';
  String get phone => _phone;

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

  Future<void> fetchUser() async {
    _clearError();
    try {
      // Guest (preview) rejim — profil so'rovisiz davom etamiz.
      _isGuest = !await ApiClient.instance.isAuthenticated;
      if (_isGuest) {
        _fullName = '';
        _imgUrl = '';
        _userId = '';
        _phone = '';
        notifyListeners();
        return;
      }

      String? userId = await Prefs.loadUserId();
      
      // Test mode - use local data
      if (userId == 'test-user-id') {
        debugPrint('Test mode: Loading local user data');
        _fullName = await Prefs.loadFullname() ?? 'Test User';
        _phone = await Prefs.loadPhone() ?? '';
        _userId = userId ?? '';
        _imgUrl = '';
        notifyListeners();
        return;
      }
      
      Users user = await DataService.loadUser();
      HiveDB.storePerson(user);
      _fullName = user.fullname;
      _imgUrl = user.imgUrl;
      _userId = user.uid;
      _phone = user.phoneNumber;
      notifyListeners();
    } catch (e) {
      _setError(Utils.friendlyError('Foydalanuvchi ma\'lumotlarini yuklashda xatolik', e));
    }
  }

  Future<void> fetchFamousPlaces() async {
    _setLoading(true);
    _clearError();
    try {
      String? userId = await Prefs.loadUserId();
      if (userId == 'test-user-id') {
        debugPrint('Test mode: Returning empty famous places');
        _famousPlaces = [];
        _setLoading(false);
        return;
      }
      
      _famousPlaces = await DataService.loadFamousPlace();
    } catch (e) {
      _setError(Utils.friendlyError('Mashhur joylarni yuklashda xatolik', e));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchRecommendedPosts() async {
    _setLoading(true);
    _clearError();
    try {
      String? userId = await Prefs.loadUserId();
      if (userId == 'test-user-id') {
        debugPrint('Test mode: Returning empty recommended posts');
        _recPosts = [];
        _setLoading(false);
        return;
      }
      
      _recPosts = await DataService.loadRecommendPlace();
    } catch (e) {
      _setError(Utils.friendlyError('Tavsiya etilgan joylarni yuklashda xatolik', e));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchNewAddedPosts() async {
    _setLoading(true);
    _clearError();
    try {
      String? userId = await Prefs.loadUserId();
      if (userId == 'test-user-id') {
        debugPrint('Test mode: Returning empty new added posts');
        _newAdded = [];
        _setLoading(false);
        return;
      }
      
      _newAdded = await DataService.loadNewAdded();
    } catch (e) {
      _setError(Utils.friendlyError('Yangi qo\'shilgan joylarni yuklashda xatolik', e));
    } finally {
      _setLoading(false);
    }
  }

   refreshAllData() async {
    await Future.wait([
      fetchUser(),
      fetchFamousPlaces(),
      fetchRecommendedPosts(),
      fetchNewAddedPosts(),
    ]);

  }

  // Dispose searchController
  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
