import 'package:discoveruzb/view_models/login_vm.dart';
import 'package:flutter/material.dart';
import 'package:discoveruzb/l10n/app_localizations.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:provider/provider.dart';

import '../../service/auth_service.dart';
import '../pageViewPages/main_screen.dart';
import 'otp.dart';
import 'registration.dart';

/// Login ekrani — Telegram OTP + Google Sign-In.
///
/// Eski Supabase/DevSMS oqimi to'liq olib tashlandi.
class LoginWithPhone extends StatefulWidget {
  const LoginWithPhone({Key? key}) : super(key: key);

  @override
  State<LoginWithPhone> createState() => _LoginWithPhoneState();
}

class _LoginWithPhoneState extends State<LoginWithPhone> {
  final _formKey = GlobalKey<FormState>();
  bool _googleLoading = false;

  Future<void> _signInWithGoogle(BuildContext context) async {
    setState(() => _googleLoading = true);
    try {
      final result = await AuthService.instance.signInWithGoogle();
      if (!mounted) return;
      if (result == null) {
        // Foydalanuvchi bekor qildi
        setState(() => _googleLoading = false);
        return;
      }
      final isNewUser = result.user.fullname.isEmpty ||
          result.user.fullname == 'Foydalanuvchi';
      _navigateAfterAuth(
        isNewUser: isNewUser,
        phone: result.user.phone ?? '',
      );
    } on AuthException catch (e) {
      _showError(e.message);
      setState(() => _googleLoading = false);
    } catch (e) {
      _showError(AppLocalizations.of(context)!.googleSignInError);
      setState(() => _googleLoading = false);
    }
  }

  void _navigateAfterAuth({required bool isNewUser, required String phone}) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (ctx) =>
            isNewUser ? Registration(phone) : const MainPage(),
      ),
      (route) => false,
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final loginVM = Provider.of<LoginViewModel>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.tealAccent.shade400,
      resizeToAvoidBottomInset: false,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.teal.shade400,
              Colors.tealAccent.shade400,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 48),
                _buildLogo(),
                const SizedBox(height: 48),
                _buildPhoneCard(context, loginVM, l10n),
                const SizedBox(height: 24),
                _buildDivider(context),
                const SizedBox(height: 24),
                _buildGoogleButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
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
            Icons.travel_explore_outlined,
            size: 44,
            color: Colors.teal.shade600,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'DiscoverUzb',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Builder(
          builder: (context) => Text(
            AppLocalizations.of(context)!.appTagline,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneCard(
    BuildContext context,
    LoginViewModel loginVM,
    AppLocalizations l10n,
  ) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.enterPhoneNumber,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                l10n.telegramHint,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: loginVM.phoneController,
                inputFormatters: [
                  MaskTextInputFormatter(mask: "## ### ## ##"),
                ],
                keyboardType: TextInputType.phone,
                validator: (input) =>
                    input == null || input.replaceAll(' ', '').length < 9
                        ? l10n.phoneIncomplete
                        : null,
                onChanged: loginVM.updatePhoneNumber,
                decoration: InputDecoration(
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(left: 12, right: 4),
                    child: Text(
                      '+998',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  prefixIconConstraints:
                      const BoxConstraints(minWidth: 50, minHeight: 0),
                  hintText: 'XX XXX XX XX',
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.teal.shade400, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Consumer<LoginViewModel>(
                builder: (context, vm, child) {
                  return ElevatedButton.icon(
                    onPressed: vm.isLoading
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              loginVM.updatePhoneNumber(
                                loginVM.phoneController.text,
                              );
                              final ok = await vm.sendOtp();
                              if (!context.mounted) return;
                              if (ok && vm.normalizedPhone != null) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => OTPScreen(
                                      vm.normalizedPhone!.replaceFirst('+', ''),
                                    ),
                                  ),
                                );
                              } else if (vm.error != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(vm.error!)),
                                );
                                vm.clearError();
                              }
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade600,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: vm.isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.send_outlined, size: 18),
                    label: Text(
                      l10n.getSMS,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(color: Colors.white.withValues(alpha: 0.5)),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            AppLocalizations.of(context)!.orDivider,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Divider(color: Colors.white.withValues(alpha: 0.5)),
        ),
      ],
    );
  }

  Widget _buildGoogleButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: _googleLoading ? null : () => _signInWithGoogle(context),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
      ),
      icon: _googleLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Image.network(
              'https://www.google.com/favicon.ico',
              width: 18,
              height: 18,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.g_mobiledata, size: 24),
            ),
      label: Text(
        AppLocalizations.of(context)!.signInWithGoogle,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
