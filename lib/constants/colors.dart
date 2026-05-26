import 'package:flutter/material.dart';

/// DiscoverUzb — Tourism design tokens.
///
/// Inspirated by O'zbek heritage (saffron, terracotta, lapis) blended with
/// modern travel app aesthetic (Airbnb depth, Booking clarity).
class AppColors {
  AppColors._();

  // ─────────── Primary (deep teal — trust, profession) ───────────
  static const Color primary = Color(0xFF005F73);
  static const Color primaryLight = Color(0xFF0A9396);
  static const Color primaryDark = Color(0xFF003D4A);
  static const Color primarySurface = Color(0xFFE8F4F5);

  // ─────────── Accent (saffron — Uzbek heritage, warmth) ───────────
  static const Color accent = Color(0xFFEE9B00);
  static const Color accentLight = Color(0xFFFFB534);
  static const Color accentDark = Color(0xFFCA7E00);
  static const Color accentSurface = Color(0xFFFFF5E0);

  // ─────────── Terracotta (secondary accent — earth, history) ───────────
  static const Color terracotta = Color(0xFFBB3E03);
  static const Color terracottaSurface = Color(0xFFFFE8DE);

  // ─────────── Neutrals (paper sand) ───────────
  static const Color background = Color(0xFFFAFAF7);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF4F1EC);

  // ─────────── Text ───────────
  static const Color textPrimary = Color(0xFF1A1D1A);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFFA0A4AC);
  static const Color textOnPrimary = Colors.white;

  // ─────────── Borders ───────────
  static const Color border = Color(0xFFE5E7EB);
  static const Color borderStrong = Color(0xFFD1D5DB);

  // ─────────── Semantic ───────────
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // ─────────── Gradients ───────────
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x00000000),
      Color(0x99000000),
    ],
    stops: [0.4, 1.0],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [accent, terracotta],
  );
}

/// Spacing tokens — 4pt grid system.
class AppSpacing {
  AppSpacing._();
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double base = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;
}

/// Border radii — soft modern.
class AppRadius {
  AppRadius._();
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 28;
  static const double full = 999;
}

/// Shadow presets — Material 3 elevation.
class AppShadows {
  AppShadows._();

  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 4,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> md = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x1F000000),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  /// Card hover/elevated state
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x10000000),
      blurRadius: 16,
      offset: Offset(0, 6),
    ),
  ];
}
