import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamebooking/core/theme/app_theme.dart';
import 'package:gamebooking/core/routes/app_router.dart';
import 'package:gamebooking/bloc/auth/auth_bloc.dart';
import 'package:gamebooking/bloc/venue/venue_bloc.dart';
import 'package:gamebooking/bloc/booking/booking_bloc.dart';
import 'package:gamebooking/bloc/matchmaker/matchmaker_bloc.dart';
import 'package:gamebooking/bloc/tournament/tournament_bloc.dart';
import 'package:gamebooking/data/repositories/auth_repository.dart';
import 'package:gamebooking/data/repositories/venue_repository.dart';
import 'package:gamebooking/data/repositories/booking_repository.dart';
import 'package:gamebooking/data/repositories/matchmaker_repository.dart';
import 'package:gamebooking/data/repositories/tournament_repository.dart';
import 'package:gamebooking/data/services/firebase_auth_service.dart';
import 'package:gamebooking/data/services/firestore_service.dart';
import 'package:gamebooking/data/services/analytics_service.dart';
import 'package:gamebooking/data/services/crashlytics_service.dart';
class GameBookingApp extends StatelessWidget {
  const GameBookingApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = FirebaseAuthService();
    final firestoreService = FirestoreService();
    final analyticsService = AnalyticsService();
    final crashlyticsService = CrashlyticsService();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (_) => AuthRepository(
            authService: authService,
            firestoreService: firestoreService,
          ),
        ),
        RepositoryProvider(
          create: (_) => VenueRepository(
            firestoreService: firestoreService,
          ),
        ),
        RepositoryProvider(
          create: (_) => BookingRepository(
            firestoreService: firestoreService,
          ),
        ),
        RepositoryProvider(
          create: (_) => MatchmakerRepository(
            firestoreService: firestoreService,
          ),
        ),
        RepositoryProvider(
          create: (_) => TournamentRepository(
            firestoreService: firestoreService,
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AuthBloc(
              authRepository: context.read<AuthRepository>(),
              analyticsService: analyticsService,
              crashlyticsService: crashlyticsService,
            )..add(const AuthCheckStatus()),
          ),
          BlocProvider(
            create: (context) => VenueBloc(
              venueRepository: context.read<VenueRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => BookingBloc(
              bookingRepository: context.read<BookingRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => MatchmakerBloc(
              matchmakerRepository: context.read<MatchmakerRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => TournamentBloc(
              tournamentRepository: context.read<TournamentRepository>(),
            ),
          ),
        ],
        child: MaterialApp.router(
          title: 'Play Arena',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          routerConfig: AppRouter.router,
        ),
      ),
    );
  }
}
