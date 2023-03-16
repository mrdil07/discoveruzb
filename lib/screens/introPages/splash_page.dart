import 'package:discoveruzb/screens/introPages/login_with_phone.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../service/pref_service.dart';
import '../pageViewPages/main_screen.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  initTimer() async {
    await Future.delayed(const Duration(
      seconds: 3,
    )).then((value) => callHomePage());
  }

  void callHomePage() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (builder) => StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (ctx, snapshot) {
              User? newData = snapshot.data;
              if (snapshot.hasData && newData != null) {
                Prefs.saveUserId(newData.uid);
                return const MainPage();
              } else {
                Prefs.removeUserId();
                return const LoginWithPhone();
              }
            }),
      ),
      (Route<dynamic> route) => false,
    );
  }

  @override
  void initState() {
    super.initState();
    initTimer();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      body: SafeArea(
        bottom: true,
        top: true,
        child: Container(
          padding: EdgeInsets.fromLTRB(
              5, MediaQuery.of(context).size.height / 10, 5, 20),
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromRGBO(12, 143, 204, 1),
                Color.fromRGBO(12, 191, 204, 1),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    AppLocalizations.of(context)!.discoverUz,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const Text(
                'Created by MrDil',
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
