import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:gamebooking/presentation/screens/splash/splash_screen.dart';
import 'package:gamebooking/presentation/screens/auth/login_screen.dart';
import 'package:gamebooking/presentation/screens/auth/register_screen.dart';
import 'package:gamebooking/presentation/screens/home/home_screen.dart';
import 'package:gamebooking/presentation/screens/venues/venue_list_screen.dart';
import 'package:gamebooking/presentation/screens/venues/venue_detail_screen.dart';
import 'package:gamebooking/presentation/screens/booking/booking_screen.dart';
import 'package:gamebooking/presentation/screens/booking/booking_confirmation_screen.dart';
import 'package:gamebooking/presentation/screens/booking/payment_success_screen.dart';
import 'package:gamebooking/presentation/screens/booking/my_bookings_screen.dart';
import 'package:gamebooking/presentation/screens/settings/settings_screen.dart';
import 'package:gamebooking/presentation/screens/matchmaker/matchmaker_screen.dart';
import 'package:gamebooking/presentation/screens/matchmaker/match_detail_screen.dart';
import 'package:gamebooking/presentation/screens/tournament/tournament_list_screen.dart';
import 'package:gamebooking/presentation/screens/tournament/tournament_detail_screen.dart';
import 'package:gamebooking/presentation/screens/profile/profile_screen.dart';
import 'package:gamebooking/presentation/screens/teams/my_teams_screen.dart';
import 'package:gamebooking/presentation/screens/teams/team_detail_screen.dart';
import 'package:gamebooking/presentation/screens/live_score/live_score_screen.dart';
import 'package:gamebooking/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:gamebooking/presentation/screens/shell/main_shell_screen.dart';

// Admin screens
import 'package:gamebooking/presentation/screens/admin/admin_shell_screen.dart';
import 'package:gamebooking/presentation/screens/admin/admin_dashboard_screen.dart';
import 'package:gamebooking/presentation/screens/admin/admin_venues_screen.dart';
import 'package:gamebooking/presentation/screens/admin/admin_add_venue_screen.dart';
import 'package:gamebooking/presentation/screens/admin/admin_manage_slots_screen.dart';
import 'package:gamebooking/presentation/screens/admin/admin_bookings_screen.dart';
import 'package:gamebooking/presentation/screens/admin/admin_venue_bookings_screen.dart';
import 'package:gamebooking/presentation/screens/admin/admin_profile_screen.dart';

/// Named-route constants used throughout the app.
abstract class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String venues = '/venues';
  static const String venueDetail = '/venues/:id';
  static const String booking = '/booking/:venueId';
  static const String paymentSuccess = '/booking/payment-success';
  static const String bookingConfirmation = '/booking/confirmation';
  static const String myBookings = '/my-bookings';
  static const String settings = '/settings';
  static const String matchmaker = '/matchmaker';
  static const String matchDetail = '/matchmaker/match/:id';
  static const String tournaments = '/tournaments';
  static const String tournamentDetail = '/tournaments/:id';
  static const String profile = '/profile';
  static const String myTeams = '/profile/teams';
  static const String teamDetail = '/profile/teams/:id';
  static const String liveScores = '/live-scores';

  // Admin routes
  static const String adminDashboard = '/admin/dashboard';
  static const String adminVenues = '/admin/venues';
  static const String adminAddVenue = '/admin/add-venue';
  static const String adminManageSlots = '/admin/manage-slots';
  static const String adminBookings = '/admin/bookings';
  static const String adminVenueBookings = '/admin/venue-bookings';
  static const String adminProfile = '/admin/profile';
}

/// Global navigator key for accessing the root navigator outside of context.
final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

/// Navigator keys for each user bottom-nav branch.
final GlobalKey<NavigatorState> _homeNavKey =
    GlobalKey<NavigatorState>(debugLabel: 'home');
final GlobalKey<NavigatorState> _venuesNavKey =
    GlobalKey<NavigatorState>(debugLabel: 'venues');
final GlobalKey<NavigatorState> _matchmakerNavKey =
    GlobalKey<NavigatorState>(debugLabel: 'matchmaker');
final GlobalKey<NavigatorState> _profileNavKey =
    GlobalKey<NavigatorState>(debugLabel: 'profile');

/// Navigator keys for each admin bottom-nav branch.
final GlobalKey<NavigatorState> _adminDashboardNavKey =
    GlobalKey<NavigatorState>(debugLabel: 'adminDashboard');
final GlobalKey<NavigatorState> _adminVenuesNavKey =
    GlobalKey<NavigatorState>(debugLabel: 'adminVenues');
final GlobalKey<NavigatorState> _adminBookingsNavKey =
    GlobalKey<NavigatorState>(debugLabel: 'adminBookings');
final GlobalKey<NavigatorState> _adminProfileNavKey =
    GlobalKey<NavigatorState>(debugLabel: 'adminProfile');

/// Central GoRouter configuration for GameBooking.
class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    routes: <RouteBase>[
      // ── Splash ────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // ── Onboarding ────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // ── Auth ──────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // ══════════════════════════════════════════════════════════════════
      // USER SHELL (Bottom Navigation)
      // ══════════════════════════════════════════════════════════════════
      StatefulShellRoute.indexedStack(
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state, navigationShell) {
          return MainShellScreen(navigationShell: navigationShell);
        },
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            navigatorKey: _homeNavKey,
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.home,
                name: 'home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _venuesNavKey,
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.venues,
                name: 'venues',
                builder: (context, state) => const VenueListScreen(),
                routes: <RouteBase>[
                  GoRoute(
                    parentNavigatorKey: _rootNavigatorKey,
                    path: ':id',
                    name: 'venueDetail',
                    builder: (context, state) {
                      final venueId = state.pathParameters['id']!;
                      return VenueDetailScreen(venueId: venueId);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _matchmakerNavKey,
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.matchmaker,
                name: 'matchmaker',
                builder: (context, state) => const MatchmakerScreen(),
                routes: <RouteBase>[
                  GoRoute(
                    parentNavigatorKey: _rootNavigatorKey,
                    path: 'match/:id',
                    name: 'matchDetail',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return MatchDetailScreen(matchId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _profileNavKey,
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.profile,
                name: 'profile',
                builder: (context, state) => const ProfileScreen(),
                routes: <RouteBase>[
                  GoRoute(
                    parentNavigatorKey: _rootNavigatorKey,
                    path: 'teams',
                    name: 'myTeams',
                    builder: (context, state) => const MyTeamsScreen(),
                    routes: <RouteBase>[
                      GoRoute(
                        parentNavigatorKey: _rootNavigatorKey,
                        path: ':id',
                        name: 'teamDetail',
                        builder: (context, state) {
                          final id = state.pathParameters['id']!;
                          return TeamDetailScreen(teamId: id);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      // ══════════════════════════════════════════════════════════════════
      // ADMIN SHELL (Bottom Navigation — completely separate from user)
      // ══════════════════════════════════════════════════════════════════
      StatefulShellRoute.indexedStack(
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state, navigationShell) {
          return AdminShellScreen(navigationShell: navigationShell);
        },
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            navigatorKey: _adminDashboardNavKey,
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.adminDashboard,
                name: 'adminDashboard',
                builder: (context, state) => const AdminDashboardScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _adminVenuesNavKey,
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.adminVenues,
                name: 'adminVenues',
                builder: (context, state) => const AdminVenuesScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _adminBookingsNavKey,
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.adminBookings,
                name: 'adminBookings',
                builder: (context, state) => const AdminBookingsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _adminProfileNavKey,
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.adminProfile,
                name: 'adminProfile',
                builder: (context, state) => const AdminProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // ── Admin sub-pages (pushed on top of admin shell) ────────────────
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.adminAddVenue,
        name: 'adminAddVenue',
        builder: (context, state) {
          final venueId = state.uri.queryParameters['venueId'];
          return AdminAddVenueScreen(venueId: venueId);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.adminManageSlots,
        name: 'adminManageSlots',
        builder: (context, state) {
          final venueId = state.uri.queryParameters['venueId'] ?? '';
          return AdminManageSlotsScreen(venueId: venueId);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.adminVenueBookings,
        name: 'adminVenueBookings',
        builder: (context, state) {
          final venueId = state.uri.queryParameters['venueId'] ?? '';
          final venueName = state.uri.queryParameters['venueName'] ?? '';
          return AdminVenueBookingsScreen(
            venueId: venueId,
            venueName: venueName,
          );
        },
      ),

      // ── Booking (pushed on top of user shell) ────────────────────────
      // IMPORTANT: static paths MUST come before the parameterized
      // `/booking/:venueId` route, otherwise GoRouter matches them as a
      // venueId parameter and silently renders the wrong screen.
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.paymentSuccess,
        name: 'paymentSuccess',
        builder: (context, state) => const PaymentSuccessScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.bookingConfirmation,
        name: 'bookingConfirmation',
        builder: (context, state) => const BookingConfirmationScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.booking,
        name: 'booking',
        builder: (context, state) {
          final venueId = state.pathParameters['venueId']!;
          return BookingScreen(venueId: venueId);
        },
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.myBookings,
        name: 'myBookings',
        builder: (context, state) => const MyBookingsScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.settings,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),

      // ── Tournaments ─────────────────────────────────────────────────
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.tournaments,
        name: 'tournaments',
        builder: (context, state) => const TournamentListScreen(),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.tournamentDetail,
        name: 'tournamentDetail',
        builder: (context, state) {
          final tournamentId = state.pathParameters['id']!;
          return TournamentDetailScreen(tournamentId: tournamentId);
        },
      ),

      // ── Live Scores ─────────────────────────────────────────────────
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.liveScores,
        name: 'liveScores',
        builder: (context, state) => const LiveScoreScreen(),
      ),
    ],

    // ── Error Page ──────────────────────────────────────────────────────
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.uri.toString(),
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
}
