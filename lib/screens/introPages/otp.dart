import 'package:discoveruzb/view_models/otp_vm.dart';
import 'package:flutter/material.dart';
import 'package:discoveruzb/l10n/app_localizations.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

import '../pageViewPages/main_screen.dart';
import 'registration.dart';

/// OTP tasdiqlash ekrani.
///
/// `LoginWithPhone` `LoginViewModel.sendOtp()` orqali OTP yuborganidan
/// keyin chaqiriladi. Bu yerda foydalanuvchi 6-xona kodni kiritadi va
/// `OTPViewModel.signInWithOTP` backend `/auth/telegram/verify-otp`'ni
/// chaqiradi.
class OTPScreen extends StatefulWidget {
  final String phone;

  /// `phone` E.164 dan `+` belgisi olib tashlangan (`998901234567`).
  /// `OTPViewModel` o'zi `+` qo'shadi.
  const OTPScreen(this.phone, {Key? key}) : super(key: key);

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  bool _hasNavigated = false;
  String? _lastShownError;

  @override
  void initState() {
    super.initState();
    // OTP allaqachon LoginViewModel.sendOtp() orqali yuborilgan.
    // Bu yerda faqat timer'ni boshlaymiz va telefon raqamini saqlaymiz.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final otpVM = Provider.of<OTPViewModel>(context, listen: false);
      otpVM.attachPhone('+${widget.phone}');
    });
  }

  void _handleNavigation(OTPViewModel vm) {
    if (vm.isLoggedIn && !_hasNavigated) {
      _hasNavigated = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) =>
                vm.isNewUser ? Registration(widget.phone) : const MainPage(),
          ),
          (route) => false,
        );
      });
    }
  }

  void _showError(OTPViewModel vm) {
    if (vm.error != null && vm.error != _lastShownError) {
      _lastShownError = vm.error;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(vm.error ?? '')),
          );
          vm.clearError();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      // Pastki SafeArea iPhone home bar joyini ham gradient bilan qoplaydi
      backgroundColor: Colors.tealAccent.shade400,
      resizeToAvoidBottomInset: false,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal.shade400, Colors.tealAccent.shade400],
          ),
        ),
        child: SafeArea(
          child: Consumer<OTPViewModel>(
            builder: (context, vm, child) {
              _handleNavigation(vm);
              _showError(vm);

              String strDigits(int n) => n.toString().padLeft(2, '0');
              final minutes = strDigits(vm.myDuration.inMinutes.remainder(60));
              final seconds = strDigits(vm.myDuration.inSeconds.remainder(60));
              final isExpired = vm.myDuration.inSeconds == 0;

              return SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  children: [
                    const SizedBox(height: 48),
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.message_outlined,
                        size: 36,
                        color: Colors.teal.shade600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.verifyPhoneNumber,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.enterVerificationCode,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '+${widget.phone}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 24, horizontal: 16),
                        child: Pinput(
                          length: 6,
                          focusNode: vm.pinPutFocusNode,
                          controller: vm.pinPutController,
                          pinAnimationType: PinAnimationType.fade,
                          onCompleted: (pin) {
                            vm.signInWithOTP(pin);
                          },
                          defaultPinTheme: PinTheme(
                            width: 48,
                            height: 56,
                            textStyle: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          focusedPinTheme: PinTheme(
                            width: 48,
                            height: 56,
                            textStyle: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.teal.shade400, width: 2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (vm.isLoading)
                      const CircularProgressIndicator(color: Colors.white)
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isExpired
                                ? Icons.timer_off_outlined
                                : Icons.access_time,
                            color: Colors.white.withValues(alpha: 0.9),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isExpired ? l10n.timeExpired : '$minutes:$seconds',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 16),
                    if (!vm.isLoading && isExpired)
                      TextButton.icon(
                        onPressed: () {
                          vm.resetTimer();
                          vm.verifyPhoneNumber('+${widget.phone}');
                        },
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        label: Text(
                          l10n.resendSms,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
