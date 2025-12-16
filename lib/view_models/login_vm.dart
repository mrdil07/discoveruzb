import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  final TextEditingController phoneController = TextEditingController();
  String _phoneNumber = '';
  String get phoneNumber => _phoneNumber;

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

  void _clearError() {
    _error = null;
  }

  void updatePhoneNumber(String value) {
    _phoneNumber = value;
    // No notifyListeners here, as it's typically bound to a TextEditingController
  }

  Future<void> submitPhoneNumber() async {
    _setLoading(true);
    _clearError();
    try {
      // Here you would typically initiate Firebase phone authentication
      // For now, we'll just simulate a delay.
      await Future.delayed(const Duration(seconds: 1));

      // After successful submission (e.g., Firebase sends OTP),
      // you might want to save the phone number or navigate.
      // For now, we'll just clear loading state.
      _setLoading(false);

      // In a real app, you'd get a verification ID and pass it to OTP screen.
      // Since actual auth is not implemented here, we just simulate success.

    } catch (e) {
      _setError('Telefon raqamini yuborishda xatolik: ${e.toString()}');
      _setLoading(false);
    }
  }

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }
}
