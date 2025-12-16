import 'package:discoveruzb/screens/introPages/login_with_phone.dart';
import 'package:discoveruzb/view_models/splash_vm.dart';
import 'package:flutter/material.dart';
import 'package:discoveruzb/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../pageViewPages/main_screen.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Start checking user session after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SplashViewModel>(context, listen: false).checkUserSession();
    });

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
          child: Consumer<SplashViewModel>(
            builder: (context, splashViewModel, child) {
              // Navigate based on session status after loading is complete
              if (!splashViewModel.isLoading) {
                if (splashViewModel.isLoggedIn) {
                  Future.microtask(() => Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (builder) => const MainPage()),
                        (Route<dynamic> route) => false,
                      ));
                } else {
                  Future.microtask(() => Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (builder) => const LoginWithPhone()),
                        (Route<dynamic> route) => false,
                      ));
                }
              }

              // Display splash screen content while loading or navigating
              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        AppLocalizations.of(context)!.discoverUz,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Text(
                    'Created by MrDil',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
