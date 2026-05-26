import 'package:flutter/material.dart';

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

  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Yangi user backend tomonida `verifyTelegramOtp`'da yaratiladi
  /// (default `fullname='Foydalanuvchi'` bilan). Bu yerda biz faqat
  /// fullname'ni yangilaymiz: `PATCH /users/me`.
  Future<void> registerUser(String phoneNumber) async {
    _setLoading(true);
    clearError();
    _isRegistered = false;
    try {
      final fullname =
          '${nameController.text.trim()} ${famController.text.trim()}'.trim();
      if (fullname.isEmpty) {
        _setError('Ism va familiya talab qilinadi');
        _setLoading(false);
        return;
      }

      final user = await DataService.loadUser();
      final updated = user.copyWith(fullname: fullname);
      await DataService.updateUser(updated);
      await Prefs.saveFullname(fullname);
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
