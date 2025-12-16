import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/users_model.dart';
import '../service/data_service.dart';
import '../service/pref_service.dart';

class RegistrationViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController famController = TextEditingController();

  String? _error;
  String? get error => _error;

  bool _isRegistered = false;
  bool get isRegistered => _isRegistered;

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

  Future<void> registerUser(String phoneNumber) async {
    _setLoading(true);
    clearError();
    _isRegistered = false;
    try {
      String fullname = '${nameController.text.trim()} ${famController.text.trim()}';

      // Get current authenticated user ID
      String? uid = FirebaseAuth.instance.currentUser?.uid ?? await Prefs.loadUserId();
      if (uid == null) {
        _setError('Foydalanuvchi ID topilmadi. Iltimos, qayta urinib ko\'ring.');
        _setLoading(false);
        return;
      }

      // Check if this is test mode (test-user-id is used in development)
      if (uid == 'test-user-id') {
        debugPrint('Test mode: Skipping Firestore write, registration simulated');
        await Prefs.saveFullname(fullname);
        _isRegistered = true;
        _setLoading(false);
        notifyListeners();
        return;
      }

      Users newUser = Users(
        uid: uid,
        fullname: fullname,
        phoneNumber: phoneNumber,
      );

      await DataService.storeUser(newUser);
      _isRegistered = true;
    } catch (e) {
      _setError('Ro\'yxatdan o\'tishda xatolik: ${e.toString()}');
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    famController.dispose();
    super.dispose();
  }
}
