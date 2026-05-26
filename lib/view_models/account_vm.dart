import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/places_model.dart';
import '../models/users_model.dart';
import '../service/data_service.dart';
import '../service/file_service.dart';
import '../service/pref_service.dart';

class AccountViewModel extends ChangeNotifier {
  List<Place> _places = [];
  List<Place> get places => _places;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _fullName = '';
  String get fullName => _fullName;

  String _imgUrl = '';
  String get imgUrl => _imgUrl;

  String _email = '';
  String get email => _email;

  File? _image;
  File? get image => _image;

  final ScrollController _subController = ScrollController();
  ScrollController get subController => _subController;

  List<bool> _isSelected = [true, false]; // Made private
  List<bool> get isSelected => _isSelected;

  final ImagePicker _imagePicker = ImagePicker();

  String? _phone = '';
  String? get phone => _phone;

  bool _isAdmin = false;
  bool get isAdmin => _isAdmin;

  String? _error;
  String? get error => _error;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String errorMessage) {
    _error = errorMessage;
    notifyListeners();
  }

  // Making clearError public
  void clearError() {
    _error = null;
    notifyListeners(); // Notify listeners when error is cleared
  }

  // Method to update isSelected state
  void toggleSelected(int index) {
    for (int i = 0; i < _isSelected.length; i++) {
      _isSelected[i] = i == index;
    }
    notifyListeners();
  }

  Future<void> pickImageFromGallery() async {
    clearError(); // Use public clearError
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
          source: ImageSource.gallery, imageQuality: 50);
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        notifyListeners();
        await _changeProfilePhoto();
      }
    } catch (e) {
      _setError('Galereyadan rasm tanlashda xatolik: ${e.toString()}');
    }
  }

  Future<void> pickImageFromCamera() async {
    clearError(); // Use public clearError
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
          source: ImageSource.camera, imageQuality: 50);
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        notifyListeners();
        await _changeProfilePhoto();
      }
    } catch (e) {
      _setError('Kameradan rasm olishda xatolik: ${e.toString()}');
    }
  }

  Future<void> fetchUserProfile() async {
    _setLoading(true);
    clearError();
    try {
      String? userId = await Prefs.loadUserId();
      
      // Test mode - use local data
      if (userId == 'test-user-id') {
        debugPrint('Test mode: Loading local user profile');
        _fullName = await Prefs.loadFullname() ?? 'Test User';
        _phone = await Prefs.loadPhone() ?? '';
        _email = '';
        _imgUrl = '';
        _isAdmin = false;
        notifyListeners();
        _setLoading(false);
        return;
      }

      Users user = await DataService.loadUser();
      _fullName = user.fullname;
      _email = user.email;
      _imgUrl = user.imgUrl;
      _phone = user.phoneNumber;
      _isAdmin = user.isAdmin;
      notifyListeners();
    } catch (e) {
      _setError('Foydalanuvchi ma\'lumotlarini yuklashda xatolik: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _changeProfilePhoto() async {
    if (_image == null) return;

    _setLoading(true);
    clearError();
    try {
      String downloadUrl = await FileService.uploadFile(_image!, FileService.folderUserImg);
      await _updateUserImageUrl(downloadUrl);
    } catch (e) {
      _setError('Rasm yuklashda yoki yangilashda xatolik: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _updateUserImageUrl(String downloadUrl) async {
    clearError();
    try {
      Users user = await DataService.loadUser();
      Users updatedUser = user.copyWith(imgUrl: downloadUrl);
      await DataService.updateUser(updatedUser);
      _imgUrl = downloadUrl;
      notifyListeners();
      await fetchUserProfile();
    } catch (e) {
      _setError('Foydalanuvchi rasmini yangilashda xatolik: ${e.toString()}');
    }
  }

  Future<void> fetchMyPosts() async {
    _setLoading(true);
    clearError();
    try {
      String? userId = await Prefs.loadUserId();
      String? loadedPhone = await Prefs.loadPhone();
      _phone = loadedPhone;
      notifyListeners();

      // Test mode - return empty list
      if (userId == 'test-user-id') {
        debugPrint('Test mode: Skipping Firestore, returning empty posts');
        _places = [];
        _setLoading(false);
        return;
      }

      // Admin barcha postlarni ko'radi, oddiy user — faqat layklarni.
      // Admin moderatsiyasi admin panelda — mobile'da admin ham faqat
      // o'z layklari va saqlanganlarini ko'radi.
      _places = await DataService.loadLiked();
    } catch (e) {
      _setError('Mening postlarimni yuklashda xatolik: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchMySavedPosts() async {
    _setLoading(true);
    clearError();
    try {
      String? userId = await Prefs.loadUserId();
      
      // Test mode - return empty list
      if (userId == 'test-user-id') {
        debugPrint('Test mode: Skipping Firestore, returning empty saved posts');
        _places = [];
        _setLoading(false);
        return;
      }
      
      _places = await DataService.loadSaved();
    } catch (e) {
      _setError('Saqlangan postlarni yuklashda xatolik: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deletePost(Place place) async {
    _setLoading(true);
    clearError();
    final id = place.id;
    if (id == null) {
      _setError('Post ID topilmadi');
      _setLoading(false);
      return;
    }
    try {
      await DataService.removePost(id);
      _places.removeWhere((p) => p.id == id);
      notifyListeners();
      await fetchMyPosts();
    } catch (e) {
      _setError('Postni o\'chirishda xatolik: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  @override
  void dispose() {
    _subController.dispose();
    super.dispose();
  }
}
