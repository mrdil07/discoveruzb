import 'package:discoveruzb/view_models/otp_vm.dart';
import 'package:flutter/material.dart';
import 'package:discoveruzb/l10n/app_localizations.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

import '../pageViewPages/main_screen.dart';
import 'registration.dart';

class OTPScreen extends StatefulWidget {
  final String phone;
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
    // Start phone verification when the widget is first built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final otpVM = Provider.of<OTPViewModel>(context, listen: false);
      otpVM.verifyPhoneNumber('+${widget.phone}');
    });
  }

  void _handleNavigation(OTPViewModel vm) {
    if (vm.isLoggedIn && !_hasNavigated) {
      _hasNavigated = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => vm.isNewUser ? Registration(widget.phone) : const MainPage(),
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
    return Scaffold(
      backgroundColor: Colors.teal,
      body: SafeArea(
        top: true,
        bottom: true,
        child: Consumer<OTPViewModel>(
          builder: (context, vm, child) {
            // Handle navigation and errors
            _handleNavigation(vm);
            _showError(vm);

            String strDigits(int n) => n.toString().padLeft(2, '0');
            final minutes = strDigits(vm.myDuration.inMinutes.remainder(60));
            final seconds = strDigits(vm.myDuration.inSeconds.remainder(60));

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  AppLocalizations.of(context)!.verifyPhoneNumber,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  AppLocalizations.of(context)!.enterVerificationCode,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Pinput(
                    length: 6,
                    focusNode: vm.pinPutFocusNode,
                    controller: vm.pinPutController,
                    pinAnimationType: PinAnimationType.fade,
                    onCompleted: (pin) {
                      vm.signInWithOTP(pin);
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.access_time,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '$minutes:$seconds',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (!vm.isLoading && vm.myDuration.inSeconds == 0)
                  InkWell(
                    onTap: () {
                      vm.resetTimer();
                      vm.verifyPhoneNumber('+${widget.phone}'); // Resend OTP
                    },
                    child: Text(
                      AppLocalizations.of(context)!.resendSms,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.red,
                      ),
                    ),
                  ),
                if (vm.isLoading)
                  const Padding(
                    padding: EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
