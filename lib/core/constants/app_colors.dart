import 'package:flutter/material.dart';

import 'package:gamebooking/core/theme/theme_controller.dart';

/// App-wide color palette.
///
/// Colors split into two groups:
///
/// 1. **Mode-aware semantic colors** (backgrounds, surfaces, text, divider,
///    gradients) — implemented as `static` getters that resolve to either
///    the dark or light palette based on `ThemeController.instance.mode`
///    (falling back to the OS platform brightness when mode is `system`).
///    These look up the current theme at each access, so widgets rebuild
///    in the correct palette whenever the theme changes.
///
/// 2. **Fixed brand / semantic colors** (actionGreen, accentYellow, error,
///    sport accents, occupancy status) — remain `const` because they are
///    the same regardless of dark vs. light mode.
///
/// NOTE: Because the semantic colors are now runtime getters, they
/// **cannot be used inside `const` constructors** (e.g. you can't write
/// `const BoxDecoration(color: AppColors.primaryBackground)` anymore).
/// Drop the `const` keyword from any such widget — the switch is
/// mechanical and the tree rebuilds on every theme toggle anyway.
class AppColors {
  AppColors._();

  // ───────────────────────────────────────────────────────────────────────
  // Fixed brand colors — same in both themes
  // ───────────────────────────────────────────────────────────────────────

  /// Fresh Turf Green — main action / CTA color.
  static const Color actionGreen = Color(0xFF22C55E);

  /// Spotlight Yellow — accent highlights, badges, star ratings.
  static const Color accentYellow = Color(0xFFFACC15);

  /// Red Card — errors, alerts, destructive actions.
  static const Color error = Color(0xFFEF4444);

  // ── Sport accents (fixed across themes) ──────────────────────────────

  static const Color cricketAccent = Color(0xFFF59E0B);
  static const Color footballAccent = Color(0xFF3B82F6);
  static const Color pickleballAccent = Color(0xFF84CC16);

  // ── Occupancy status (fixed — semantic, not theme-dependent) ─────────

  static const Color available = Color(0xFF22C55E);
  static const Color fillingFast = Color(0xFFFACC15);
  static const Color fullyBooked = Color(0xFFEF4444);

  // ───────────────────────────────────────────────────────────────────────
  // Dark palette constants
  // ───────────────────────────────────────────────────────────────────────

  static const Color _darkPrimaryBackground = Color(0xFF0F172A);
  static const Color _darkSurface = Color(0xFF1E293B);
  static const Color _darkCard = Color(0xFF334155);
  static const Color _darkDivider = Color(0xFF475569);
  static const Color _darkTextPrimary = Color(0xFFF8FAFC);
  static const Color _darkTextSecondary = Color(0xFF94A3B8);
  static const Color _darkTextDisabled = Color(0xFF64748B);

  // ───────────────────────────────────────────────────────────────────────
  // Light palette constants
  // ───────────────────────────────────────────────────────────────────────

  // Keep these in sync with `_Palette _lightPalette` in app_theme.dart.
  static const Color _lightPrimaryBackground = Color(0xFFF1F5F9);
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightCard = Color(0xFFFFFFFF);
  static const Color _lightDivider = Color(0xFFCBD5E1);
  static const Color _lightTextPrimary = Color(0xFF0F172A);
  static const Color _lightTextSecondary = Color(0xFF475569);
  static const Color _lightTextDisabled = Color(0xFF94A3B8);

  // ───────────────────────────────────────────────────────────────────────
  // Mode resolution
  // ───────────────────────────────────────────────────────────────────────

  /// Whether we should render with the light palette right now.
  static bool get _isLight {
    final mode = ThemeController.instance.mode;
    switch (mode) {
      case ThemeMode.light:
        return true;
      case ThemeMode.dark:
        return false;
      case ThemeMode.system:
        final brightness =
            WidgetsBinding.instance.platformDispatcher.platformBrightness;
        return brightness == Brightness.light;
    }
  }

  // ───────────────────────────────────────────────────────────────────────
  // Mode-aware semantic colors
  // ───────────────────────────────────────────────────────────────────────

  static Color get primaryBackground =>
      _isLight ? _lightPrimaryBackground : _darkPrimaryBackground;

  static Color get surface => _isLight ? _lightSurface : _darkSurface;

  static Color get card => _isLight ? _lightCard : _darkCard;

  static Color get divider => _isLight ? _lightDivider : _darkDivider;

  static Color get textPrimary =>
      _isLight ? _lightTextPrimary : _darkTextPrimary;

  static Color get textSecondary =>
      _isLight ? _lightTextSecondary : _darkTextSecondary;

  static Color get textDisabled =>
      _isLight ? _lightTextDisabled : _darkTextDisabled;

  // ───────────────────────────────────────────────────────────────────────
  // Mode-aware gradients
  // ───────────────────────────────────────────────────────────────────────

  /// Gradient used behind hero / stadium banners.
  static LinearGradient get stadiumGradient {
    return _isLight
        ? const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFFFFF), Color(0xFFF1F5F9)],
          )
        : const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          );
  }

  /// Gradient used on CTA buttons (same in both themes — brand).
  static const LinearGradient actionGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
  );

  /// Gradient overlay for venue card images.
  static LinearGradient get cardImageOverlay {
    return _isLight
        ? const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Color(0x33000000)],
          )
        : const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Color(0xCC0F172A)],
          );
  }

  // ───────────────────────────────────────────────────────────────────────
  // Material swatch (fixed)
  // ───────────────────────────────────────────────────────────────────────

  static const MaterialColor actionGreenSwatch = MaterialColor(
    0xFF22C55E,
    <int, Color>{
      50: Color(0xFFF0FDF4),
      100: Color(0xFFDCFCE7),
      200: Color(0xFFBBF7D0),
      300: Color(0xFF86EFAC),
      400: Color(0xFF4ADE80),
      500: Color(0xFF22C55E),
      600: Color(0xFF16A34A),
      700: Color(0xFF15803D),
      800: Color(0xFF166534),
      900: Color(0xFF14532D),
    },
  );
}
