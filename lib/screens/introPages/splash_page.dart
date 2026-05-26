import 'package:discoveruzb/screens/introPages/login_with_phone.dart';
import 'package:discoveruzb/view_models/splash_vm.dart';
import 'package:flutter/material.dart';
import 'package:discoveruzb/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../pageViewPages/main_screen.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SplashViewModel>(context, listen: false).checkUserSession();
    });
  }

  void _maybeNavigate(SplashViewModel vm) {
    if (vm.isLoading || _navigated) return;
    _navigated = true;
    final target = vm.isLoggedIn
        ? const MainPage()
        : const LoginWithPhone();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => target),
        (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color.fromRGBO(12, 191, 204, 1),
      resizeToAvoidBottomInset: false,
      body: Container(
        width: double.infinity,
        height: double.infinity,
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
        child: SafeArea(
          child: Consumer<SplashViewModel>(
            builder: (context, vm, child) {
              _maybeNavigate(vm);
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 30,
                          offset: const Offset(0, 12),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.travel_explore_outlined,
                      size: 52,
                      color: Colors.teal.shade500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.discoverUz,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const Spacer(),
                  if (vm.isLoading)
                    const CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  const SizedBox(height: 32),
                  Text(
                    l10n.createdBy,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
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
