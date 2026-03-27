import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gamebooking/bloc/tournament/tournament_bloc.dart';
import 'package:gamebooking/core/constants/app_colors.dart';
import 'package:gamebooking/data/models/tournament_model.dart';
import 'package:gamebooking/data/models/venue_model.dart';
import 'package:intl/intl.dart';

class TournamentListScreen extends StatefulWidget {
  const TournamentListScreen({super.key});

  @override
  State<TournamentListScreen> createState() => _TournamentListScreenState();
}

class _TournamentListScreenState extends State<TournamentListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<TournamentBloc>().add(const TournamentLoadAll());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          'Tournaments',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.actionGreen,
          indicatorWeight: 3,
          labelColor: AppColors.actionGreen,
          unselectedLabelColor: AppColors.textSecondary,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Ongoing'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: BlocBuilder<TournamentBloc, TournamentState>(
        builder: (context, state) {
          if (state is TournamentLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.actionGreen),
            );
          }

          if (state is TournamentError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      color: AppColors.error, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    state.message,
                    style: const TextStyle(
                        color: AppColors.textSecondary, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context
                        .read<TournamentBloc>()
                        .add(const TournamentLoadAll()),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.actionGreen),
                    child: const Text('Retry',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          }

          if (state is TournamentListLoaded) {
            final upcoming = state.tournaments
                .where((t) => t.status == TournamentStatus.upcoming)
                .toList();
            final ongoing = state.tournaments
                .where((t) => t.status == TournamentStatus.ongoing)
                .toList();
            final completed = state.tournaments
                .where((t) => t.status == TournamentStatus.completed)
                .toList();

            return TabBarView(
              controller: _tabController,
              children: [
                _buildTournamentList(
                    upcoming, 'No upcoming tournaments', Icons.event),
                _buildTournamentList(
                    ongoing, 'No ongoing tournaments', Icons.play_circle),
                _buildTournamentList(completed, 'No completed tournaments',
                    Icons.emoji_events),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildTournamentList(
      List<TournamentModel> tournaments, String emptyMsg, IconData emptyIcon) {
    if (tournaments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(emptyIcon,
                color: AppColors.textDisabled.withValues(alpha: 0.5),
                size: 72),
            const SizedBox(height: 16),
            Text(
              emptyMsg,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Check back later for updates',
              style:
                  TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tournaments.length,
      itemBuilder: (context, index) =>
          _buildTournamentBracketCard(tournaments[index]),
    );
  }

  Widget _buildTournamentBracketCard(TournamentModel tournament) {
    return InkWell(
      onTap: () {
        context.push('/tournaments/${tournament.id}');
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _sportColor(tournament.sportType).withValues(alpha: 0.2),
                    AppColors.card,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(14)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          tournament.name,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _statusBadge(tournament.status),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(_sportIcon(tournament.sportType),
                          color: _sportColor(tournament.sportType),
                          size: 16),
                      const SizedBox(width: 6),
                      Text(
                        _sportLabel(tournament.sportType),
                        style: TextStyle(
                          color: _sportColor(tournament.sportType),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.location_on,
                          color: AppColors.textSecondary, size: 14),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          tournament.venueName,
                          style: const TextStyle(
                              color: AppColors.textSecondary, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _infoColumn(
                    Icons.calendar_today,
                    'Dates',
                    '${DateFormat('dd MMM').format(tournament.startDate)} - ${DateFormat('dd MMM').format(tournament.endDate)}',
                  ),
                  _infoColumn(
                    Icons.emoji_events,
                    'Prize Pool',
                    '\u20B9${tournament.prizePool.toStringAsFixed(0)}',
                  ),
                  _infoColumn(
                    Icons.group,
                    'Teams',
                    '${tournament.registeredTeams.length}/${tournament.maxTeams}',
                  ),
                  _infoColumn(
                    Icons.format_list_numbered,
                    'Format',
                    _formatLabel(tournament.format),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(TournamentStatus status) {
    Color color;
    String label;
    switch (status) {
      case TournamentStatus.upcoming:
        color = AppColors.footballAccent;
        label = 'Upcoming';
        break;
      case TournamentStatus.ongoing:
        color = AppColors.actionGreen;
        label = 'Live';
        break;
      case TournamentStatus.completed:
        color = AppColors.textSecondary;
        label = 'Completed';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _infoColumn(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 16),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
              color: AppColors.textDisabled, fontSize: 11),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  String _sportLabel(SportType type) {
    switch (type) {
      case SportType.boxCricket:
        return 'Box Cricket';
      case SportType.football:
        return 'Football';
      case SportType.pickleball:
        return 'Pickleball';
      case SportType.badminton:
        return 'Badminton';
      case SportType.tennis:
        return 'Tennis';
    }
  }

  IconData _sportIcon(SportType type) {
    switch (type) {
      case SportType.boxCricket:
        return Icons.sports_cricket;
      case SportType.football:
        return Icons.sports_soccer;
      case SportType.pickleball:
        return Icons.sports_tennis;
      case SportType.badminton:
        return Icons.sports_tennis;
      case SportType.tennis:
        return Icons.sports_tennis;
    }
  }

  Color _sportColor(SportType type) {
    switch (type) {
      case SportType.boxCricket:
        return AppColors.cricketAccent;
      case SportType.football:
        return AppColors.footballAccent;
      case SportType.pickleball:
        return AppColors.pickleballAccent;
      case SportType.badminton:
        return AppColors.accentYellow;
      case SportType.tennis:
        return AppColors.actionGreen;
    }
  }

  String _formatLabel(TournamentFormat format) {
    switch (format) {
      case TournamentFormat.knockout:
        return 'Knockout';
      case TournamentFormat.roundRobin:
        return 'Round Robin';
      case TournamentFormat.league:
        return 'League';
    }
  }
}
