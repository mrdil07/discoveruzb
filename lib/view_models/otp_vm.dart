import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
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

  // Test phone numbers for development (only works on simulators)
  static const Map<String, String> _testPhoneNumbers = {
    '+998911490349': '121212',
  };

  bool _isTestMode = false;
  String _testPhoneNumber = '';

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
    notifyListeners();
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
    clearError();
    _verificationCode = '';
    _testPhoneNumber = phoneNumber;
    
    // Check if this is a test phone number (for iOS simulator development)
    if (kDebugMode && _testPhoneNumbers.containsKey(phoneNumber)) {
      debugPrint('Test mode activated for: $phoneNumber');
      _isTestMode = true;
      _verificationCode = 'test-verification-id';
      startTimer();
      _setLoading(false);
      return;
    }
    
    _isTestMode = false;
    
    try {
      debugPrint('Starting phone verification for: $phoneNumber');
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          debugPrint('verificationCompleted called with credential');
          if (credential.smsCode != null) {
            pinPutController.text = credential.smsCode!;
          }
          await signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          debugPrint('verificationFailed: ${e.code} - ${e.message}');
          _setError('Tasdiqlashda xatolik: ${e.message}');
          _setLoading(false);
        },
        codeSent: (String verificationID, int? resendToken) {
          debugPrint('codeSent: verificationID = $verificationID');
          _verificationCode = verificationID;
          startTimer();
          _setLoading(false);
        },
        codeAutoRetrievalTimeout: (String verificationID) {
          debugPrint('codeAutoRetrievalTimeout: verificationID = $verificationID');
          if (_verificationCode.isEmpty) {
            _verificationCode = verificationID;
          }
          _setLoading(false);
        },
        timeout: const Duration(seconds: 120),
      );
    } catch (e) {
      debugPrint('verifyPhoneNumber error: ${e.toString()}');
      _setError('Telefon raqamini tasdiqlashda xatolik: ${e.toString()}');
      _setLoading(false);
    }
  }

  Future<void> signInWithOTP(String otp) async {
    _setLoading(true);
    clearError();
    
    // Test mode - simulate login for development
    if (_isTestMode && kDebugMode) {
      final expectedOtp = _testPhoneNumbers[_testPhoneNumber];
      if (otp == expectedOtp) {
        debugPrint('Test mode: OTP verified successfully');
        // Simulate successful login
        await Prefs.saveUserId('test-user-id');
        await Prefs.savePhone(_testPhoneNumber);
        _isNewUser = true; // Assume new user for test
        _isLoggedIn = true;
        _setLoading(false);
        stopTimer();
        notifyListeners();
        return;
      } else {
        _setError('Noto\'g\'ri OTP kodi');
        _setLoading(false);
        return;
      }
    }
    
    try {
      if (_verificationCode.isEmpty) {
        _setError('Verification ID topilmadi. Iltimos, qaytadan urinib ko\'ring.');
        _setLoading(false);
        return;
      }
      
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: _verificationCode, smsCode: otp);
      await signInWithCredential(credential);
    } catch (e) {
      _setError('OTPni tasdiqlashda xatolik: ${e.toString()}');
      _setLoading(false);
    }
  }

  Future<void> signInWithCredential(PhoneAuthCredential credential) async {
    _setLoading(true);
    clearError();
    try {
      debugPrint('Attempting to sign in with credential...');
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      User? user = userCredential.user;
      debugPrint('Sign in successful, user: ${user?.uid}');

      if (user != null) {
        await Prefs.saveUserId(user.uid);
        await Prefs.savePhone(user.phoneNumber.toString());

        _isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
        _isLoggedIn = true;
        debugPrint('User logged in, isNewUser: $_isNewUser');
        notifyListeners();
      } else {
        _setError('Foydalanuvchi ma\'lumotlari topilmadi.');
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException: ${e.code} - ${e.message}');
      _setError('Kirishda xatolik: ${e.message}');
    } catch (e) {
      debugPrint('General error: ${e.toString()}');
      _setError('Kirishda xatolik: ${e.toString()}');
    } finally {
      _setLoading(false);
      stopTimer();
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
