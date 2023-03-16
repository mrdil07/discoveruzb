import 'dart:async';

import 'package:discoveruzb/screens/introPages/registration.dart';
import 'package:discoveruzb/service/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

import '../../service/pref_service.dart';
import '../pageViewPages/main_screen.dart';

class OTPScreen extends StatefulWidget {
  final String phone;
  const OTPScreen(this.phone, {Key? key}) : super(key: key);

  @override
  _OTPScreenState createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldkey = GlobalKey<ScaffoldState>();
  String _verificationCode = '';
  final TextEditingController _pinPutController = TextEditingController();
  final FocusNode _pinPutFocusNode = FocusNode();

  Timer? countdownTimer;
  Duration myDuration = const Duration(minutes: 3);
  @override
  void initState() {
    super.initState();
    _verifyPhone();
    startTimer();
  }

  @override
  Widget build(BuildContext context) {
    String strDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = strDigits(myDuration.inMinutes.remainder(60));
    final seconds = strDigits(myDuration.inSeconds.remainder(60));
    return Scaffold(
      key: _scaffoldkey,
      backgroundColor: Colors.teal,
      body: SafeArea(
        top: true,
        bottom: true,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Mobil raqamni tasdiqlash',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 26,
                  color: Colors.white),
            ),
            const SizedBox(height: 20),
            const Text(
              'Biz sizga yuborgan kodni kiriting',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white),
            ),
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Pinput(
                length: 6,
                focusNode: _pinPutFocusNode,
                controller: _pinPutController,
                pinAnimationType: PinAnimationType.fade,
                onCompleted: (pin) {
                  onCompleted(pin);
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
                  style: const TextStyle(
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                      fontSize: 25),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (countdownTimer?.isActive == false)
              InkWell(
                onTap: () {
                  _verifyPhone();
                  setState(() {
                    resetTimer();
                  });
                },
                child: const Text(
                  'SMS.ni qayta yuborish uchun bosing',
                  style: TextStyle(
                      fontWeight: FontWeight.w400,
                      color: Colors.red,
                      fontSize: 19),
                ),
              ),
          ],
        ),
      ),
    );
  }

  _verifyPhone() async {
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+998${widget.phone}',
      verificationCompleted: (PhoneAuthCredential credential) async {
        setState(() {
          _pinPutController.setText(credential.smsCode!);
        });
      },
      verificationFailed: (FirebaseAuthException e) {
        print('verification failed');
        Utils.fireToast(e.message!);
      },
      codeSent: (String verficationID, int? resendToken) {
        print("kod jonatildi");
        setState(() {
          _verificationCode = verficationID;
        });
      },
      codeAutoRetrievalTimeout: (String verificationID) {
        print("time out");
        if (mounted) {
          setState(() {
            _verificationCode = verificationID;
          });
        }
      },
      timeout: const Duration(seconds: 120),
    );
  }

  void onCompleted(String pin) async {
    try {
      await FirebaseAuth.instance
          .signInWithCredential(PhoneAuthProvider.credential(
              verificationId: _verificationCode, smsCode: pin))
          .then((value) async {
        if (value.additionalUserInfo?.isNewUser == false) {
          Prefs.saveUserId(value.user?.uid);
          Prefs.savePhone(value.user!.phoneNumber.toString());
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const MainPage()),
              (route) => false);
        } else {
          Prefs.saveUserId(value.user?.uid);
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => Registration(widget.phone)),
              (route) => false);
        }
      });
    } catch (e) {
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Invalid Token'),
      ));
    }
    stopTimer();
  }

  void startTimer() {
    countdownTimer =
        Timer.periodic(const Duration(seconds: 1), (_) => setCountDown());
  }

  void setCountDown() {
    const reduceSecondsBy = 1;
    if (mounted) {
      setState(() {
        final seconds = myDuration.inSeconds - reduceSecondsBy;
        if (seconds < 0) {
          countdownTimer!.cancel();
        } else {
          myDuration = Duration(seconds: seconds);
        }
      });
    }
  }

  void stopTimer() {
    if (mounted) {
      setState(() {
        countdownTimer!.cancel();
      });
    }
  }

  void resetTimer() {
    stopTimer();
    setState(() => myDuration = const Duration(minutes: 3));
    startTimer();
  }
}
