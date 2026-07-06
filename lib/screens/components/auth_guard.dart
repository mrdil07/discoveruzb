import 'package:flutter/material.dart';
import 'package:discoveruzb/l10n/app_localizations.dart';

import '../../constants/colors.dart';
import '../../service/api_client.dart';
import '../introPages/login_with_phone.dart';

/// Guest (preview) rejim uchun auth-guard.
///
/// Auth talab qiladigan amal (like, save, izoh, profil) oldidan
/// chaqiriladi:
///
/// ```dart
/// if (!await AuthGuard.ensureAuthenticated(context)) return;
/// ```
///
/// Token bo'lmasa — "Kirish talab qilinadi" bottom sheet ko'rsatiladi,
/// undan `LoginWithPhone`'ga o'tish mumkin.
class AuthGuard {
  AuthGuard._();

  static Future<bool> ensureAuthenticated(BuildContext context) async {
    final hasToken = await ApiClient.instance.isAuthenticated;
    if (hasToken) return true;
    if (!context.mounted) return false;
    await showLoginRequiredSheet(context);
    return false;
  }

  static Future<void> showLoginRequiredSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.lg)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.lock_outline_rounded,
                size: 44,
                color: AppColors.primary,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                l10n.loginRequiredTitle,
                textAlign: TextAlign.center,
                style: Theme.of(sheetContext).textTheme.titleLarge,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.loginRequiredMessage,
                textAlign: TextAlign.center,
                style: Theme.of(sheetContext)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.lg),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginWithPhone()),
                    (route) => false,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                child: Text(
                  l10n.signIn,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              TextButton(
                onPressed: () => Navigator.of(sheetContext).pop(),
                child: Text(
                  l10n.cancel,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
