import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Singleton controller that holds the app-wide `ThemeMode` and persists the
/// choice across launches via `SharedPreferences`.
///
/// Usage:
/// ```dart
/// await ThemeController.instance.init();   // call once in main()
/// MaterialApp.router(
///   theme: AppTheme.lightTheme,
///   darkTheme: AppTheme.darkTheme,
///   themeMode: ThemeController.instance.mode,
///   ...
/// );
/// ```
class ThemeController extends ChangeNotifier {
  ThemeController._();

  static final ThemeController instance = ThemeController._();

  static const _prefsKey = 'pref_theme_mode';

  ThemeMode _mode = ThemeMode.dark;
  ThemeMode get mode => _mode;

  /// The effective brightness right now (resolves `system` mode via the
  /// platform setting). Used by the app.dart tree-rebuild key so every
  /// widget re-evaluates `AppColors.*` getters when the effective
  /// brightness changes.
  Brightness get effectiveBrightness {
    switch (_mode) {
      case ThemeMode.light:
        return Brightness.light;
      case ThemeMode.dark:
        return Brightness.dark;
      case ThemeMode.system:
        return WidgetsBinding
            .instance.platformDispatcher.platformBrightness;
    }
  }

  /// Loads the persisted theme mode (if any). Call once at app start
  /// before `runApp`. Also subscribes to OS-level brightness changes so
  /// `system` mode reacts without requiring a restart.
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey);
    _mode = _decode(saved);

    // Notify listeners whenever the OS brightness flips (only matters
    // while we're in `system` mode, but cheap to listen unconditionally).
    WidgetsBinding.instance.platformDispatcher.onPlatformBrightnessChanged =
        () {
      if (_mode == ThemeMode.system) notifyListeners();
    };

    notifyListeners();
  }

  Future<void> setMode(ThemeMode mode) async {
    if (_mode == mode) return;
    _mode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, _encode(mode));
  }

  // ── Encoding helpers ────────────────────────────────────────────────────

  static String _encode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  static ThemeMode _decode(String? value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'system':
        return ThemeMode.system;
      case 'dark':
      default:
        return ThemeMode.dark;
    }
  }
}
