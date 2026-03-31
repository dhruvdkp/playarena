import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class CrashlyticsService {
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  // ===========================================================================
  // Initialization
  // ===========================================================================

  /// Initializes Crashlytics error handlers.
  ///
  /// Call this once during app startup, after `WidgetsFlutterBinding` and
  /// `Firebase.initializeApp()` have completed.
  ///
  /// - Hooks into [FlutterError.onError] to capture framework-level errors as
  ///   fatal crashes.
  /// - Hooks into [PlatformDispatcher.instance.onError] to capture async /
  ///   platform-level errors that escape the Flutter framework.
  Future<void> init() async {
    // Pass all uncaught Flutter framework errors to Crashlytics.
    FlutterError.onError = _crashlytics.recordFlutterFatalError;

    // Pass all uncaught asynchronous errors that are not caught by the Flutter
    // framework to Crashlytics.
    PlatformDispatcher.instance.onError = (error, stack) {
      _crashlytics.recordError(error, stack, fatal: true);
      return true;
    };
  }

  // ===========================================================================
  // User identification
  // ===========================================================================

  /// Associates the given [userId] with future crash reports so they can be
  /// filtered in the Firebase console.
  void setUserIdentifier(String userId) {
    _crashlytics.setUserIdentifier(userId);
  }

  // ===========================================================================
  // Logging
  // ===========================================================================

  /// Adds a log [message] that will be sent with the next crash report.
  ///
  /// Useful for breadcrumb-style debugging context.
  void log(String message) {
    _crashlytics.log(message);
  }

  // ===========================================================================
  // Error recording
  // ===========================================================================

  /// Records a caught [exception] along with its [stackTrace].
  ///
  /// Set [fatal] to `true` if the error is unrecoverable and should be treated
  /// as a crash in the Firebase console.
  Future<void> recordError(
    dynamic exception,
    StackTrace? stackTrace, {
    bool fatal = false,
  }) async {
    await _crashlytics.recordError(
      exception,
      stackTrace,
      fatal: fatal,
    );
  }

  // ===========================================================================
  // Custom keys
  // ===========================================================================

  /// Sets a custom key-value pair that will be attached to future crash
  /// reports.
  ///
  /// [value] can be a `String`, `bool`, `int`, or `double`.
  void setCustomKey(String key, dynamic value) {
    _crashlytics.setCustomKey(key, value);
  }
}
