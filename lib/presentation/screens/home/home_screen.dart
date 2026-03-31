import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:gamebooking/bloc/auth/auth_bloc.dart';
import 'package:gamebooking/bloc/booking/booking_bloc.dart';
import 'package:gamebooking/bloc/matchmaker/matchmaker_bloc.dart';
import 'package:gamebooking/bloc/tournament/tournament_bloc.dart';
import 'package:gamebooking/bloc/venue/venue_bloc.dart';
import 'package:gamebooking/core/constants/app_colors.dart';
import 'package:gamebooking/core/constants/app_strings.dart';
import 'package:gamebooking/core/routes/app_router.dart';
import 'package:gamebooking/core/utils/helpers.dart';
import 'package:gamebooking/data/models/booking_model.dart';
import 'package:gamebooking/data/models/match_request_model.dart';
import 'package:gamebooking/data/models/tournament_model.dart' hide MatchModel, MatchStatus;
import 'package:gamebooking/data/models/venue_model.dart';
import 'package:gamebooking/presentation/widgets/venue_card.dart';

/// Main home screen of the GameBooking app.
///
/// Displays a greeting header, search bar, quick sport filter chips,
/// upcoming bookings, popular venues, open games from matchmaker,
/// and live tournaments. Integrates with [VenueBloc], [BookingBloc],
/// [MatchmakerBloc], and [TournamentBloc].
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedSportIndex = 0;

  static const List<_SportFilterItem> _sportFilters = [
    _SportFilterItem(label: 'All', icon: Icons.sports),
    _SportFilterItem(label: 'Box Cricket', icon: Icons.sports_cricket),
    _SportFilterItem(label: 'Football', icon: Icons.sports_soccer),
    _SportFilterItem(label: 'Pickleball', icon: Icons.sports_tennis),
    _SportFilterItem(label: 'Badminton', icon: Icons.sports_tennis),
    _SportFilterItem(label: 'Basketball', icon: Icons.sports_basketball),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<VenueBloc>().add(const VenueLoadAll());
    context.read<MatchmakerBloc>().add(const MatchmakerLoadMatches());
    context.read<TournamentBloc>().add(const TournamentLoadAll());

    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context
          .read<BookingBloc>()
          .add(BookingLoadUser(userId: authState.user.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        color: AppColors.actionGreen,
        backgroundColor: AppColors.surface,
        onRefresh: () async => _loadData(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Greeting Header ──────────────────────────────────
              _buildGreetingHeader(),

              // ── Search Bar ───────────────────────────────────────
              _buildSearchBar(),
              const SizedBox(height: 20),

              // ── Quick Sport Filter Chips ─────────────────────────
              _buildSportFilterChips(),
              const SizedBox(height: 24),

              // ── Upcoming Bookings ────────────────────────────────
              _buildSectionHeader(AppStrings.upcomingBookings, onSeeAll: () {
                // TODO: Navigate to bookings list
              }),
              const SizedBox(height: 12),
              _buildUpcomingBookings(),
              const SizedBox(height: 24),

              // ── Popular Venues ───────────────────────────────────
              _buildSectionHeader('Popular Venues', onSeeAll: () {
                context.go(AppRoutes.venues);
              }),
              const SizedBox(height: 12),
              _buildPopularVenues(),
              const SizedBox(height: 24),

              // ── Open Games ───────────────────────────────────────
              _buildSectionHeader('Open Games', onSeeAll: () {
                context.go(AppRoutes.matchmaker);
              }),
              const SizedBox(height: 12),
              _buildOpenGames(),
              const SizedBox(height: 24),

              // ── Live Tournaments ─────────────────────────────────
              _buildSectionHeader('Live Tournaments', onSeeAll: () {
                context.push(AppRoutes.tournaments);
              }),
              const SizedBox(height: 12),
              _buildLiveTournaments(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ── Greeting Header ──────────────────────────────────────────────────────

  Widget _buildGreetingHeader() {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final userName =
            state is AuthAuthenticated ? state.user.name : 'Player';
        final avatarUrl =
            state is AuthAuthenticated ? state.user.avatarUrl : null;

        return Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 16,
            left: 20,
            right: 20,
            bottom: 16,
          ),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF0A0F1E),
                AppColors.primaryBackground,
              ],
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${Helpers.getGreeting()},',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userName.split(' ').first,
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                    ),
                  ],
                ),
              ),
              // Avatar
              GestureDetector(
                onTap: () => context.go(AppRoutes.profile),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.actionGreen,
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: avatarUrl != null
                        ? Image.network(
                            avatarUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                _buildAvatarPlaceholder(userName),
                          )
                        : _buildAvatarPlaceholder(userName),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Notification bell
              IconButton(
                onPressed: () {
                  // TODO: Navigate to notifications
                },
                icon: Stack(
                  children: [
                    const Icon(
                      Icons.notifications_outlined,
                      color: AppColors.textPrimary,
                      size: 26,
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.actionGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAvatarPlaceholder(String name) {
    return Container(
      color: AppColors.surface,
      alignment: Alignment.center,
      child: Text(
        Helpers.getInitials(name),
        style: const TextStyle(
          color: AppColors.actionGreen,
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
    );
  }

  // ── Search Bar ───────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => context.go(AppRoutes.venues),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.divider),
          ),
          child: const Row(
            children: [
              Icon(Icons.search, color: AppColors.textDisabled, size: 22),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Search venues, sports, locations...',
                  style: TextStyle(
                    color: AppColors.textDisabled,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8),
              Icon(Icons.tune, color: AppColors.textDisabled, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ── Sport Filter Chips ───────────────────────────────────────────────────

  Widget _buildSportFilterChips() {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _sportFilters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final filter = _sportFilters[index];
          final isSelected = _selectedSportIndex == index;

          return GestureDetector(
            onTap: () {
              setState(() => _selectedSportIndex = index);
              if (index == 0) {
                context.read<VenueBloc>().add(const VenueLoadAll());
              } else {
                final sportType = _mapIndexToSportType(index);
                if (sportType != null) {
                  context
                      .read<VenueBloc>()
                      .add(VenueFilterBySport(sportType: sportType));
                }
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.actionGreen
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isSelected
                      ? AppColors.actionGreen
                      : AppColors.divider,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    filter.icon,
                    size: 18,
                    color: isSelected
                        ? AppColors.primaryBackground
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    filter.label,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.primaryBackground
                          : AppColors.textPrimary,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  SportType? _mapIndexToSportType(int index) {
    switch (index) {
      case 1:
        return SportType.boxCricket;
      case 2:
        return SportType.football;
      case 3:
        return SportType.pickleball;
      case 4:
        return SportType.badminton;
      default:
        return null;
    }
  }

  // ── Section Header ───────────────────────────────────────────────────────

  Widget _buildSectionHeader(String title, {VoidCallback? onSeeAll}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          if (onSeeAll != null)
            GestureDetector(
              onTap: onSeeAll,
              child: Text(
                AppStrings.seeAll,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.actionGreen,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Upcoming Bookings ────────────────────────────────────────────────────

  Widget _buildUpcomingBookings() {
    return BlocBuilder<BookingBloc, BookingState>(
      builder: (context, state) {
        if (state is BookingLoading) {
          return const _ShimmerHorizontalCards();
        }

        List<BookingModel> upcomingBookings = [];
        if (state is BookingListLoaded) {
          upcomingBookings = state.bookings
              .where((b) => b.bookingStatus == BookingStatus.upcoming)
              .toList();
        }

        if (upcomingBookings.isEmpty) {
          return _buildEmptyState(
            icon: Icons.calendar_today_outlined,
            message: AppStrings.noBookings,
            actionLabel: 'Book a Venue',
            onAction: () => context.go(AppRoutes.venues),
          );
        }

        return SizedBox(
          height: 160,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: upcomingBookings.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              return _UpcomingBookingCard(booking: upcomingBookings[index]);
            },
          ),
        );
      },
    );
  }

  // ── Popular Venues ───────────────────────────────────────────────────────

  Widget _buildPopularVenues() {
    return BlocBuilder<VenueBloc, VenueState>(
      builder: (context, state) {
        if (state is VenueLoading) {
          return const _ShimmerVenueCards();
        }

        if (state is VenueLoaded) {
          final venues = state.venues;
          if (venues.isEmpty) {
            return _buildEmptyState(
              icon: Icons.stadium_outlined,
              message: AppStrings.noResults,
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: venues.length > 3 ? 3 : venues.length,
            itemBuilder: (context, index) {
              return VenueCard(
                venue: venues[index],
                onTap: () => context.push('/venues/${venues[index].id}'),
              );
            },
          );
        }

        if (state is VenueError) {
          return _buildErrorState(state.message);
        }

        return const SizedBox.shrink();
      },
    );
  }

  // ── Open Games ───────────────────────────────────────────────────────────

  Widget _buildOpenGames() {
    return BlocBuilder<MatchmakerBloc, MatchmakerState>(
      builder: (context, state) {
        if (state is MatchmakerLoading) {
          return const _ShimmerHorizontalCards();
        }

        if (state is MatchmakerLoaded) {
          final matches = state.matches;
          if (matches.isEmpty) {
            return _buildEmptyState(
              icon: Icons.group_outlined,
              message: 'No open games right now',
              actionLabel: AppStrings.createMatch,
              onAction: () => context.go(AppRoutes.matchmaker),
            );
          }

          return SizedBox(
            height: 170,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: matches.length > 3 ? 3 : matches.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                return _OpenGameCard(match: matches[index]);
              },
            ),
          );
        }

        if (state is MatchmakerError) {
          return _buildErrorState(state.message);
        }

        return const SizedBox.shrink();
      },
    );
  }

  // ── Live Tournaments ─────────────────────────────────────────────────────

  Widget _buildLiveTournaments() {
    return BlocBuilder<TournamentBloc, TournamentState>(
      builder: (context, state) {
        if (state is TournamentLoading) {
          return const _ShimmerHorizontalCards();
        }

        if (state is TournamentListLoaded) {
          final liveTournaments = state.tournaments
              .where((t) =>
                  t.status == TournamentStatus.ongoing ||
                  t.status == TournamentStatus.upcoming)
              .toList();

          if (liveTournaments.isEmpty) {
            return _buildEmptyState(
              icon: Icons.emoji_events_outlined,
              message: AppStrings.noTournaments,
            );
          }

          return SizedBox(
            height: 170,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: liveTournaments.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                return _TournamentCard(tournament: liveTournaments[index]);
              },
            ),
          );
        }

        if (state is TournamentError) {
          return _buildErrorState(state.message);
        }

        return const SizedBox.shrink();
      },
    );
  }

  // ── Empty / Error States ─────────────────────────────────────────────────

  Widget _buildEmptyState({
    required IconData icon,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: AppColors.textDisabled),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 16),
            TextButton(
              onPressed: onAction,
              child: Text(actionLabel),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: AppColors.error, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Data Classes ─────────────────────────────────────────────────────────────

class _SportFilterItem {
  final String label;
  final IconData icon;

  const _SportFilterItem({required this.label, required this.icon});
}

// ── Upcoming Booking Card ────────────────────────────────────────────────────

class _UpcomingBookingCard extends StatelessWidget {
  final BookingModel booking;

  const _UpcomingBookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.actionGreen.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sport icon + venue name
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.actionGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Helpers.getSportIcon(booking.sportType.name),
                  size: 20,
                  color: AppColors.actionGreen,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  booking.venueName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Date
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                Helpers.formatDateRelative(booking.slot.date),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Time
          Row(
            children: [
              const Icon(Icons.access_time,
                  size: 14, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                '${booking.slot.startTime} - ${booking.slot.endTime}',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Spacer(),

          // Price + status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                Helpers.formatPrice(booking.totalAmount),
                style: const TextStyle(
                  color: AppColors.actionGreen,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _statusColor(booking.paymentStatus)
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  booking.paymentStatus.name.toUpperCase(),
                  style: TextStyle(
                    color: _statusColor(booking.paymentStatus),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _statusColor(PaymentStatus status) {
    switch (status) {
      case PaymentStatus.completed:
        return AppColors.actionGreen;
      case PaymentStatus.pending:
        return AppColors.accentYellow;
      case PaymentStatus.failed:
        return AppColors.error;
      case PaymentStatus.refunded:
        return AppColors.textSecondary;
    }
  }
}

// ── Open Game Card ───────────────────────────────────────────────────────────

class _OpenGameCard extends StatelessWidget {
  final MatchRequestModel match;

  const _OpenGameCard({required this.match});

  @override
  Widget build(BuildContext context) {
    final spotsLeft = match.playersNeeded - match.playersJoined.length;

    return Container(
      width: 240,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sport type + spots
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.actionGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Helpers.getSportIcon(match.sportType.name),
                      size: 14,
                      color: AppColors.actionGreen,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      match.sportType.name.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.actionGreen,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: spotsLeft <= 2
                      ? AppColors.error.withValues(alpha: 0.15)
                      : AppColors.accentYellow.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$spotsLeft spots left',
                  style: TextStyle(
                    color: spotsLeft <= 2
                        ? AppColors.error
                        : AppColors.accentYellow,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Venue
          Text(
            match.venueName,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),

          // Host
          Text(
            'Hosted by ${match.hostName}',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const Spacer(),

          // Date + time
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined,
                  size: 13, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                Helpers.formatDateRelative(match.date),
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 11),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.access_time,
                  size: 13, color: AppColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                match.time,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Skill level + Join button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                match.skillLevel.name.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.actionGreen,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.actionGreen,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Join',
                  style: TextStyle(
                    color: AppColors.primaryBackground,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Tournament Card ──────────────────────────────────────────────────────────

class _TournamentCard extends StatelessWidget {
  final TournamentModel tournament;

  const _TournamentCard({required this.tournament});

  @override
  Widget build(BuildContext context) {
    final isLive = tournament.status == TournamentStatus.ongoing;

    return GestureDetector(
      onTap: () => context.push('/tournaments/${tournament.id}'),
      child: Container(
        width: 260,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isLive
                ? AppColors.error.withValues(alpha: 0.4)
                : AppColors.divider.withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Live badge + sport
            Row(
              children: [
                if (isLive)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'LIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                Icon(
                  Helpers.getSportIcon(tournament.sportType.name),
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  tournament.sportType.name.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Tournament name
            Text(
              tournament.name,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),

            // Venue
            Text(
              tournament.venueName,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),

            // Prize pool + teams
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.emoji_events,
                        size: 14, color: AppColors.accentYellow),
                    const SizedBox(width: 4),
                    Text(
                      Helpers.formatPrice(tournament.prizePool),
                      style: const TextStyle(
                        color: AppColors.accentYellow,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${tournament.registeredTeams.length}/${tournament.maxTeams} teams',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shimmer Placeholders ─────────────────────────────────────────────────────

class _ShimmerHorizontalCards extends StatelessWidget {
  const _ShimmerHorizontalCards();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (_, __) => _ShimmerBox(width: 260, height: 160),
      ),
    );
  }
}

class _ShimmerVenueCards extends StatelessWidget {
  const _ShimmerVenueCards();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        2,
        (_) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: _ShimmerBox(
            width: double.infinity,
            height: 260,
          ),
        ),
      ),
    );
  }
}

class _ShimmerBox extends StatefulWidget {
  final double width;
  final double height;

  const _ShimmerBox({required this.width, required this.height});

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment(-1.0 + 2.0 * _controller.value, 0),
              end: Alignment(1.0 + 2.0 * _controller.value, 0),
              colors: const [
                AppColors.surface,
                AppColors.card,
                AppColors.surface,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}
