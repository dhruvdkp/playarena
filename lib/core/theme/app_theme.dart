import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gamebooking/core/constants/app_colors.dart';

/// Builds the dark and light [ThemeData]s used throughout GameBooking.
///
/// Both variants are produced from a single `_build()` helper so their
/// widget-theme structure is byte-for-byte identical — only the palette
/// differs. This is a **requirement** for `AnimatedTheme.lerp` to succeed
/// when the user toggles modes at runtime; if one theme defines (e.g.)
/// an `outlinedButtonTheme` with a `GoogleFonts.poppins(...)` text style
/// and the other doesn't, Flutter throws
/// `"Cannot interpolate between these two TextStyles"` the moment the
/// animated crossfade kicks in.
class AppTheme {
  AppTheme._();

  // ── Palettes ──────────────────────────────────────────────────────────

  static const _Palette _darkPalette = _Palette(
    primaryBackground: Color(0xFF0F172A),
    surface: Color(0xFF1E293B),
    card: Color(0xFF334155),
    divider: Color(0xFF475569),
    textPrimary: Color(0xFFF8FAFC),
    textSecondary: Color(0xFF94A3B8),
    textDisabled: Color(0xFF64748B),
  );

  static const _Palette _lightPalette = _Palette(
    // Soft gray page — white surfaces/cards pop cleanly on this.
    primaryBackground: Color(0xFFF1F5F9),
    // Pure white for AppBar, cards, sheets, dialogs, input fields, etc.
    // — visually distinct from the gray page bg.
    surface: Color(0xFFFFFFFF),
    // Cards on the page also pure white (same elevation feel as surface).
    card: Color(0xFFFFFFFF),
    divider: Color(0xFFCBD5E1),
    textPrimary: Color(0xFF0F172A),
    textSecondary: Color(0xFF475569),
    textDisabled: Color(0xFF94A3B8),
  );

  // ── Shared TextTheme builder ─────────────────────────────────────────

  static TextTheme _buildTextTheme(_Palette p) {
    return GoogleFonts.poppinsTextTheme().copyWith(
      displayLarge: GoogleFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: p.textPrimary,
          letterSpacing: -0.5),
      displayMedium: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: p.textPrimary,
          letterSpacing: -0.25),
      displaySmall: GoogleFonts.poppins(
          fontSize: 24, fontWeight: FontWeight.w600, color: p.textPrimary),
      headlineLarge: GoogleFonts.poppins(
          fontSize: 22, fontWeight: FontWeight.w600, color: p.textPrimary),
      headlineMedium: GoogleFonts.poppins(
          fontSize: 20, fontWeight: FontWeight.w600, color: p.textPrimary),
      headlineSmall: GoogleFonts.poppins(
          fontSize: 18, fontWeight: FontWeight.w600, color: p.textPrimary),
      titleLarge: GoogleFonts.poppins(
          fontSize: 16, fontWeight: FontWeight.w600, color: p.textPrimary),
      titleMedium: GoogleFonts.poppins(
          fontSize: 14, fontWeight: FontWeight.w600, color: p.textPrimary),
      titleSmall: GoogleFonts.poppins(
          fontSize: 12, fontWeight: FontWeight.w600, color: p.textPrimary),
      bodyLarge: GoogleFonts.poppins(
          fontSize: 16, fontWeight: FontWeight.w400, color: p.textPrimary),
      bodyMedium: GoogleFonts.poppins(
          fontSize: 14, fontWeight: FontWeight.w400, color: p.textPrimary),
      bodySmall: GoogleFonts.poppins(
          fontSize: 12, fontWeight: FontWeight.w400, color: p.textSecondary),
      labelLarge: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: p.textPrimary,
          letterSpacing: 0.5),
      labelMedium: GoogleFonts.poppins(
          fontSize: 12, fontWeight: FontWeight.w500, color: p.textSecondary),
      labelSmall: GoogleFonts.poppins(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: p.textSecondary,
          letterSpacing: 0.5),
    );
  }

  // ── Shared theme builder ─────────────────────────────────────────────

  static ThemeData _build({
    required Brightness brightness,
    required _Palette p,
  }) {
    final isDark = brightness == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: p.primaryBackground,
      textTheme: _buildTextTheme(p),

      // ── ColorScheme ───────────────────────────────────────────────
      colorScheme: (isDark ? const ColorScheme.dark() : const ColorScheme.light())
          .copyWith(
        primary: AppColors.actionGreen,
        onPrimary: isDark ? p.primaryBackground : Colors.white,
        secondary: AppColors.accentYellow,
        onSecondary: p.primaryBackground,
        error: AppColors.error,
        onError: isDark ? p.textPrimary : Colors.white,
        surface: p.surface,
        onSurface: p.textPrimary,
        outline: p.divider,
      ),

      // ── AppBar ────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 2,
        backgroundColor: p.primaryBackground,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
              isDark ? Brightness.light : Brightness.dark,
          statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        ),
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: p.textPrimary,
        ),
        iconTheme: IconThemeData(color: p.textPrimary, size: 24),
        actionsIconTheme: IconThemeData(color: p.textPrimary, size: 24),
      ),

      // ── Card ──────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: p.card,
        surfaceTintColor: Colors.transparent,
        elevation: isDark ? 0 : 1,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
      ),

      // ── Elevated Button ───────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.actionGreen,
          foregroundColor: isDark ? p.primaryBackground : Colors.white,
          disabledBackgroundColor: p.divider,
          disabledForegroundColor: p.textDisabled,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── Outlined Button ───────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.actionGreen,
          side: const BorderSide(color: AppColors.actionGreen, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── Text Button ───────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.actionGreen,
          textStyle: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── Icon Button ───────────────────────────────────────────────
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: p.textPrimary,
        ),
      ),

      // ── FAB ───────────────────────────────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.actionGreen,
        foregroundColor: isDark ? p.primaryBackground : Colors.white,
        elevation: 4,
        shape: const StadiumBorder(),
      ),

      // ── Input Decoration ──────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: GoogleFonts.poppins(
          fontSize: 14,
          color: p.textDisabled,
        ),
        labelStyle: GoogleFonts.poppins(
          fontSize: 14,
          color: p.textSecondary,
        ),
        floatingLabelStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.actionGreen,
        ),
        prefixIconColor: p.textSecondary,
        suffixIconColor: p.textSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: p.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: p.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.actionGreen,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        errorStyle: GoogleFonts.poppins(
          fontSize: 12,
          color: AppColors.error,
        ),
      ),

      // ── Bottom Navigation Bar ─────────────────────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: p.surface,
        selectedItemColor: AppColors.actionGreen,
        unselectedItemColor: p.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        showUnselectedLabels: true,
        selectedLabelStyle: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
      ),

      // ── Navigation Bar (Material 3) ───────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: p.surface,
        indicatorColor: AppColors.actionGreen.withValues(alpha: 0.15),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 72,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.actionGreen,
            );
          }
          return GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: p.textSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(
              color: AppColors.actionGreen,
              size: 24,
            );
          }
          return IconThemeData(color: p.textSecondary, size: 24);
        }),
      ),

      // ── Chip ──────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: p.surface,
        selectedColor: AppColors.actionGreen.withValues(alpha: 0.15),
        disabledColor: p.surface,
        labelStyle: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: p.textPrimary,
        ),
        secondaryLabelStyle: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.actionGreen,
        ),
        side: BorderSide(color: p.divider),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        showCheckmark: false,
      ),

      // ── Tab Bar ───────────────────────────────────────────────────
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.actionGreen,
        unselectedLabelColor: p.textSecondary,
        indicatorColor: AppColors.actionGreen,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        dividerColor: Colors.transparent,
      ),

      // ── Bottom Sheet ──────────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: p.surface,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        showDragHandle: true,
        dragHandleColor: p.divider,
      ),

      // ── Dialog ────────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: p.textPrimary,
        ),
        contentTextStyle: GoogleFonts.poppins(
          fontSize: 14,
          color: p.textSecondary,
        ),
      ),

      // ── Snack Bar ─────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: p.card,
        contentTextStyle: GoogleFonts.poppins(
          fontSize: 14,
          color: p.textPrimary,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actionTextColor: AppColors.actionGreen,
      ),

      // ── Divider ───────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: p.divider,
        thickness: 0.5,
        space: 1,
      ),

      // ── List Tile ─────────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        tileColor: Colors.transparent,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: p.textPrimary,
        ),
        subtitleTextStyle: GoogleFonts.poppins(
          fontSize: 12,
          color: p.textSecondary,
        ),
        iconColor: p.textSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // ── Switch / Checkbox / Radio ─────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.actionGreen;
          }
          return p.textSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.actionGreen.withValues(alpha: 0.3);
          }
          return p.divider;
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.actionGreen;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(
            isDark ? p.primaryBackground : Colors.white),
        side: BorderSide(color: p.divider, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.actionGreen;
          }
          return p.textSecondary;
        }),
      ),

      // ── Progress Indicator ────────────────────────────────────────
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.actionGreen,
        linearTrackColor: p.divider,
        circularTrackColor: p.divider,
      ),

      // ── Date / Time Picker ────────────────────────────────────────
      datePickerTheme: DatePickerThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        headerBackgroundColor: p.primaryBackground,
        headerForegroundColor: p.textPrimary,
        dayForegroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return isDark ? p.primaryBackground : Colors.white;
          }
          return p.textPrimary;
        }),
        dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.actionGreen;
          }
          return null;
        }),
        todayForegroundColor: WidgetStateProperty.all(AppColors.actionGreen),
        todayBorder: const BorderSide(color: AppColors.actionGreen),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: p.surface,
        dialBackgroundColor: p.card,
        hourMinuteColor: p.card,
        dayPeriodColor: p.card,
      ),

      // ── Tooltip ───────────────────────────────────────────────────
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: p.card,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: GoogleFonts.poppins(
          fontSize: 12,
          color: p.textPrimary,
        ),
      ),

      // ── Splash / Highlight ────────────────────────────────────────
      splashColor: AppColors.actionGreen.withValues(alpha: 0.08),
      highlightColor: AppColors.actionGreen.withValues(alpha: 0.04),
      splashFactory: InkSparkle.splashFactory,
    );
  }

  // ── Public themes ────────────────────────────────────────────────

  static ThemeData get darkTheme =>
      _build(brightness: Brightness.dark, p: _darkPalette);

  static ThemeData get lightTheme =>
      _build(brightness: Brightness.light, p: _lightPalette);
}

/// Private palette record — a minimal set of mode-dependent colors that
/// the shared theme builder reads. Brand/semantic colors (actionGreen,
/// accentYellow, error, sport accents) come directly from [AppColors].
class _Palette {
  final Color primaryBackground;
  final Color surface;
  final Color card;
  final Color divider;
  final Color textPrimary;
  final Color textSecondary;
  final Color textDisabled;

  const _Palette({
    required this.primaryBackground,
    required this.surface,
    required this.card,
    required this.divider,
    required this.textPrimary,
    required this.textSecondary,
    required this.textDisabled,
  });
}
