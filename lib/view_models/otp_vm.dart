import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../service/pref_service.dart';

class OTPViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _verificationCode = '';
  String? _error;
  String? get error => _error;

  bool _isNewUser = false;
  bool get isNewUser => _isNewUser;

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  final TextEditingController pinPutController = TextEditingController();
  final FocusNode pinPutFocusNode = FocusNode();

  Timer? _countdownTimer;
  Duration _myDuration = const Duration(minutes: 3);
  Duration get myDuration => _myDuration;

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

  void startTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) => _setCountDown());
  }

  void _setCountDown() {
    const reduceSecondsBy = 1;
    final seconds = _myDuration.inSeconds - reduceSecondsBy;
    if (seconds < 0) {
      _countdownTimer?.cancel();
    } else {
      _myDuration = Duration(seconds: seconds);
    }
    notifyListeners(); // Notify listeners on every second change
  }

  void stopTimer() {
    _countdownTimer?.cancel();
    notifyListeners();
  }

  void resetTimer() {
    stopTimer();
    _myDuration = const Duration(minutes: 3);
    startTimer();
    notifyListeners();
  }

  Future<void> verifyPhoneNumber(String phoneNumber) async {
    _setLoading(true);
    _clearError();
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-retrieval or instant verification
          pinPutController.setText(credential.smsCode!); // Set PIN directly
          await signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          _setError('Tasdiqlashda xatolik: ${e.toString()}');
          _setLoading(false);
        },
        codeSent: (String verficationID, int? resendToken) {
          _verificationCode = verficationID;
          startTimer();
          _setLoading(false);
        },
        codeAutoRetrievalTimeout: (String verificationID) {
          _verificationCode = verificationID;
          _setLoading(false);
        },
        timeout: const Duration(seconds: 120),
      );
    } catch (e) {
      _setError('Telefon raqamini tasdiqlashda xatolik: ${e.toString()}');
      _setLoading(false);
    }
  }

  Future<void> signInWithOTP(String otp) async {
    _setLoading(true);
    _clearError();
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: _verificationCode, smsCode: otp);
      await signInWithCredential(credential);
    } catch (e) {
      _setError('OTPni tasdiqlashda xatolik: Invalid Token');
      _setLoading(false);
    }
  }

  Future<void> signInWithCredential(PhoneAuthCredential credential) async {
    _setLoading(true);
    _clearError();
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        await Prefs.saveUserId(user.uid);
        await Prefs.savePhone(user.phoneNumber.toString());

        _isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
        _isLoggedIn = true; // User is logged in whether new or existing
      } else {
        _setError('Foydalanuvchi ma\'lumotlari topilmadi.');
      }
    } catch (e) {
      _setError('Kirishda xatolik: ${e.toString()}');
    } finally {
      _setLoading(false);
      stopTimer(); // Stop timer after successful sign-in or error
    }
  }

  @override
  void dispose() {
    pinPutController.dispose();
    pinPutFocusNode.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }
}
