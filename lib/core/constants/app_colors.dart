import 'package:flutter/material.dart';

/// App-wide color constants based on a dark stadium aesthetic.
///
/// The palette is designed to evoke the feeling of a night-time sports
/// arena — deep navy backgrounds, vivid turf-green call-to-actions,
/// spotlight-yellow accents, and red-card error states.
class AppColors {
  AppColors._(); // prevent instantiation

  // ── Primary Palette ──────────────────────────────────────────────────

  /// Deep Stadium Night — primary background.
  static const Color primaryBackground = Color(0xFF0F172A);

  /// Fresh Turf Green — main action / CTA color.
  static const Color actionGreen = Color(0xFF22C55E);

  /// Spotlight Yellow — accent highlights, badges, star ratings.
  static const Color accentYellow = Color(0xFFFACC15);

  /// Red Card — errors, alerts, destructive actions.
  static const Color error = Color(0xFFEF4444);

  // ── Surfaces ─────────────────────────────────────────────────────────

  /// Elevated surface (bottom sheets, dialogs).
  static const Color surface = Color(0xFF1E293B);

  /// Card / tile background.
  static const Color card = Color(0xFF334155);

  /// Divider & border color.
  static const Color divider = Color(0xFF475569);

  // ── Text ──────────────────────────────────────────────────────────────

  /// High-emphasis text on dark backgrounds.
  static const Color textPrimary = Color(0xFFF8FAFC);

  /// Medium-emphasis / secondary text.
  static const Color textSecondary = Color(0xFF94A3B8);

  /// Disabled / hint text.
  static const Color textDisabled = Color(0xFF64748B);

  // ── Semantic / Sport-specific ─────────────────────────────────────────

  /// Cricket accent — warm amber.
  static const Color cricketAccent = Color(0xFFF59E0B);

  /// Football accent — sky blue.
  static const Color footballAccent = Color(0xFF3B82F6);

  /// Pickleball accent — vibrant lime.
  static const Color pickleballAccent = Color(0xFF84CC16);

  // ── Occupancy Status ──────────────────────────────────────────────────

  /// Slot is available.
  static const Color available = Color(0xFF22C55E);

  /// Slot is filling up fast.
  static const Color fillingFast = Color(0xFFFACC15);

  /// Slot is fully booked.
  static const Color fullyBooked = Color(0xFFEF4444);

  // ── Gradients ─────────────────────────────────────────────────────────

  /// Gradient used behind hero / stadium banners.
  static const LinearGradient stadiumGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF0F172A),
      Color(0xFF1E293B),
    ],
  );

  /// Gradient used on CTA buttons.
  static const LinearGradient actionGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF22C55E),
      Color(0xFF16A34A),
    ],
  );

  /// Gradient overlay for venue card images.
  static const LinearGradient cardImageOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.transparent,
      Color(0xCC0F172A), // 80 % opacity
    ],
  );

  // ── Material Color Swatch (for ThemeData.colorScheme) ─────────────────

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
