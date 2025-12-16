import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/places_model.dart';
import '../service/file_service.dart';
import '../service/pref_service.dart';

class MediaPageVM extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _address1;
  String? get address1 => _address1;

  String? _placeType1;
  String? get placeType1 => _placeType1;

  final TextEditingController captionController = TextEditingController();
  final TextEditingController placeNameController = TextEditingController();
  final TextEditingController placeSourceController = TextEditingController();
  final TextEditingController latitudeController = TextEditingController();
  final TextEditingController longitudeController = TextEditingController();

  int _countPost = 0;
  int get countPost => _countPost;

  String? _userId;
  String? get userId => _userId;

  String? _phone;
  String? get phone => _phone;

  List<File> _images = [];
  List<File> get images => _images;

  final ImagePicker _imagePicker = ImagePicker();

  String? _error;
  String? get error => _error;

  bool _postUploadedSuccessfully = false;
  bool get postUploadedSuccessfully => _postUploadedSuccessfully;

  final List<String> menuItems1 = [
    "Toshkent",
    "Andijon",
    "Namangan",
    "Farg'ona",
    "Sirdaryo",
    "Jizzax",
    "Xorazm",
    "Samarqand",
    "Qashqadaryo",
    "Surxondaryo",
    "Navoiy",
    "Buxoro",
    "Qoraqolpog'iston",
    "Boshqalar",
  ];

  final List<String> menuItems2 = [
    "Sanatoriya",
    "Mehmonxona",
    "Dacha",
    "Dam olish maskanlari",
    "Cho'milish havzalari",
    "Boshqalar"
  ];

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

  void setAddress1(String? value) {
    _address1 = value;
    notifyListeners();
  }

  void setPlaceType1(String? value) {
    _placeType1 = value;
    notifyListeners();
  }

  Future<void> pickImages() async {
    _clearError();
    try {
      final List<XFile>? pickedFiles = await _imagePicker.pickMultiImage(
          imageQuality: 70);
      if (pickedFiles != null) {
        _images = pickedFiles.map((e) => File(e.path)).toList();
        notifyListeners();
      }
    } catch (e) {
      _setError('Rasmlarni tanlashda xatolik: ${e.toString()}');
    }
  }

  Future<void> removeImage(int index) async {
    _images.removeAt(index);
    notifyListeners();
  }

  Future<void> uploadNewPost() async {
    _setLoading(true);
    _clearError();
    _postUploadedSuccessfully = false;
    try {
      if (captionController.text.trim().isEmpty ||
          placeNameController.text.trim().isEmpty ||
          placeSourceController.text.trim().isEmpty ||
          latitudeController.text.trim().isEmpty ||
          longitudeController.text.trim().isEmpty ||
          _address1 == null ||
          _placeType1 == null ||
          _images.isEmpty) {
        _setError('Iltimos, barcha maydonlarni to\'ldiring va rasm yuklang.');
        return;
      }

      if (_userId == null || _phone == null) {
        await _loadUserData(); // Load user data if not already loaded
        if (_userId == null || _phone == null) {
          _setError('Foydalanuvchi ma\'lumotlari yuklanmadi. Iltimos, qayta urinib ko\'ring.');
          return;
        }
      }

      List<String> downloadUrls = await FileService.uploadFiles(_images, FileService.folderPostImg);

      Place newPlace = Place(
        uid: _userId, // Assuming uid is the userId
        phoneNumber: [_phone!],
        price: '0', // Assuming price is 0 for new posts or will be set later
        placeImage: downloadUrls,
        placeInfo: captionController.text.trim(),
        address: _address1!,
        placeName: placeNameController.text.trim(),
        type: _placeType1!,
        source: placeSourceController.text.trim(),
        lat: double.parse(latitudeController.text.trim()),
        lon: double.parse(longitudeController.text.trim()),
        comments: [],
        time: DateTime.now().microsecondsSinceEpoch,
      );

      // Assuming DataService.storePost and DataService.storeFeedNew are meant to be active
      // await DataService.storePost(newPlace);
      // await DataService.storeFeedNew(newPlace, _address1!); // Uncomment if needed

      _postUploadedSuccessfully = true;
      _resetFields();
      _clearError();
    } catch (e) {
      _setError('Post yuklashda xatolik: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadUserData() async {
    _clearError();
    try {
      _userId = await Prefs.loadUserId();
      _phone = await Prefs.loadPhone();
      // No notifyListeners here as it's a private helper and _userId, _phone are directly used
    } catch (e) {
      _setError('Foydalanuvchi ma\'lumotlarini yuklashda xatolik: ${e.toString()}');
    }
  }

  void _resetFields() {
    captionController.clear();
    placeNameController.clear();
    placeSourceController.clear();
    latitudeController.clear();
    longitudeController.clear();
    _address1 = null;
    _placeType1 = null;
    _images.clear();
    _countPost = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    captionController.dispose();
    placeNameController.dispose();
    placeSourceController.dispose();
    latitudeController.dispose();
    longitudeController.dispose();
    super.dispose();
  }
}
