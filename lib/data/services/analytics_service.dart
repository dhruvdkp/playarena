import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // ===========================================================================
  // Navigator observer
  // ===========================================================================

  /// Returns an observer that automatically logs screen transitions when
  /// attached to [MaterialApp.navigatorObservers].
  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  // ===========================================================================
  // Authentication events
  // ===========================================================================

  /// Logs a login event. [method] should be `google`, `apple`, or `email`.
  Future<void> logLogin(String method) async {
    await _analytics.logLogin(loginMethod: method);
  }

  /// Logs a sign-up event. [method] should be `google`, `apple`, or `email`.
  Future<void> logSignUp(String method) async {
    await _analytics.logSignUp(signUpMethod: method);
  }

  // ===========================================================================
  // Booking events
  // ===========================================================================

  /// Logs a custom event when a booking is created.
  Future<void> logBookingCreated(
    String venueId,
    String sportType,
    double amount,
  ) async {
    await _analytics.logEvent(
      name: 'booking_created',
      parameters: {
        'venue_id': venueId,
        'sport_type': sportType,
        'amount': amount,
      },
    );
  }

  /// Logs a custom event when a booking is cancelled.
  Future<void> logBookingCancelled(String bookingId) async {
    await _analytics.logEvent(
      name: 'booking_cancelled',
      parameters: {
        'booking_id': bookingId,
      },
    );
  }

  // ===========================================================================
  // Venue events
  // ===========================================================================

  /// Logs an event when a user views a venue detail page.
  Future<void> logVenueViewed(String venueId, String venueName) async {
    await _analytics.logEvent(
      name: 'venue_viewed',
      parameters: {
        'venue_id': venueId,
        'venue_name': venueName,
      },
    );
  }

  // ===========================================================================
  // Match events
  // ===========================================================================

  /// Logs an event when the user joins an existing match.
  Future<void> logMatchJoined(String matchId) async {
    await _analytics.logEvent(
      name: 'match_joined',
      parameters: {
        'match_id': matchId,
      },
    );
  }

  /// Logs an event when the user creates a new match request.
  Future<void> logMatchCreated(String sportType) async {
    await _analytics.logEvent(
      name: 'match_created',
      parameters: {
        'sport_type': sportType,
      },
    );
  }

  // ===========================================================================
  // Tournament events
  // ===========================================================================

  /// Logs an event when a team registers for a tournament.
  Future<void> logTournamentRegistered(String tournamentId) async {
    await _analytics.logEvent(
      name: 'tournament_registered',
      parameters: {
        'tournament_id': tournamentId,
      },
    );
  }

  // ===========================================================================
  // Search & navigation
  // ===========================================================================

  /// Logs a search event with the user's [query].
  Future<void> logSearch(String query) async {
    await _analytics.logSearch(searchTerm: query);
  }

  /// Logs a screen-view event with the given [screenName].
  Future<void> logScreenView(String screenName) async {
    await _analytics.logScreenView(screenName: screenName);
  }

  // ===========================================================================
  // User properties
  // ===========================================================================

  /// Sets the Firebase Analytics user ID so all subsequent events are
  /// attributed to this user.
  Future<void> setUserId(String userId) async {
    await _analytics.setUserId(id: userId);
  }

  /// Sets a custom user property (e.g. `preferred_sport`, `membership_tier`).
  Future<void> setUserProperty(String name, String value) async {
    await _analytics.setUserProperty(name: name, value: value);
  }
}
