import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamebooking/bloc/tournament/tournament_bloc.dart';
import 'package:gamebooking/core/constants/app_colors.dart';
import 'package:gamebooking/data/models/tournament_model.dart';
import 'package:gamebooking/data/models/venue_model.dart';
import 'package:intl/intl.dart';

class TournamentDetailScreen extends StatefulWidget {
  final String tournamentId;

  const TournamentDetailScreen({super.key, required this.tournamentId});

  @override
  State<TournamentDetailScreen> createState() =>
      _TournamentDetailScreenState();
}

class _TournamentDetailScreenState extends State<TournamentDetailScreen> {
  bool _rulesExpanded = false;

  @override
  void initState() {
    super.initState();
    context
        .read<TournamentBloc>()
        .add(TournamentLoadDetail(id: widget.tournamentId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
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
                ],
              ),
            );
          }

          if (state is TournamentDetailLoaded) {
            return _buildContent(state.tournament, state.matches);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(
      TournamentModel tournament, List<MatchModel> matches) {
    final canRegister = tournament.status == TournamentStatus.upcoming &&
        tournament.registeredTeams.length < tournament.maxTeams;

    return CustomScrollView(
      slivers: [
        _buildSliverAppBar(tournament),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(tournament),
                const SizedBox(height: 20),
                _buildPrizeAndEntryCards(tournament),
                const SizedBox(height: 24),
                _buildTeamsSection(tournament),
                const SizedBox(height: 24),
                _buildMatchesSection(matches),
                const SizedBox(height: 24),
                _buildRulesSection(tournament),
                if (canRegister) ...[
                  const SizedBox(height: 32),
                  _buildRegisterButton(tournament),
                ],
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSliverAppBar(TournamentModel tournament) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: AppColors.surface,
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          tournament.name,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _sportColor(tournament.sportType).withValues(alpha: 0.3),
                AppColors.primaryBackground,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: Icon(
              _sportIcon(tournament.sportType),
              size: 64,
              color:
                  _sportColor(tournament.sportType).withValues(alpha: 0.4),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(TournamentModel tournament) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _infoItem(
            Icons.sports,
            'Sport',
            _sportLabel(tournament.sportType),
          ),
          Container(width: 1, height: 40, color: AppColors.divider),
          _infoItem(
            Icons.format_list_numbered,
            'Format',
            _formatLabel(tournament.format),
          ),
          Container(width: 1, height: 40, color: AppColors.divider),
          _infoItem(
            Icons.calendar_today,
            'Duration',
            '${DateFormat('dd MMM').format(tournament.startDate)} - ${DateFormat('dd MMM').format(tournament.endDate)}',
          ),
        ],
      ),
    );
  }

  Widget _infoItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 18),
        const SizedBox(height: 6),
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
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPrizeAndEntryCards(TournamentModel tournament) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.accentYellow.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppColors.accentYellow.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                const Icon(Icons.emoji_events,
                    color: AppColors.accentYellow, size: 28),
                const SizedBox(height: 8),
                const Text(
                  'Prize Pool',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  '\u20B9${tournament.prizePool.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: AppColors.accentYellow,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.actionGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: AppColors.actionGreen.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                const Icon(Icons.confirmation_number,
                    color: AppColors.actionGreen, size: 28),
                const SizedBox(height: 8),
                const Text(
                  'Entry Fee',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  '\u20B9${tournament.entryFee.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: AppColors.actionGreen,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTeamsSection(TournamentModel tournament) {
    final registered = tournament.registeredTeams.length;
    final max = tournament.maxTeams;
    final progress = max > 0 ? registered / max : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Teams',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '$registered / $max registered',
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 14),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.card,
            valueColor:
                AlwaysStoppedAnimation<Color>(
                    progress >= 1.0 ? AppColors.error : AppColors.actionGreen),
            minHeight: 10,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          progress >= 1.0
              ? 'Registration full'
              : '${max - registered} spots remaining',
          style: TextStyle(
            color:
                progress >= 1.0 ? AppColors.error : AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildMatchesSection(List<MatchModel> matches) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Matches',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (matches.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              children: [
                Icon(Icons.sports_score,
                    color: AppColors.textDisabled, size: 40),
                SizedBox(height: 8),
                Text(
                  'Matches will appear here once the tournament begins',
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ...matches.map((match) => _buildMatchCard(match)),
      ],
    );
  }

  Widget _buildMatchCard(MatchModel match) {
    Color statusColor;
    String statusLabel;
    switch (match.status) {
      case MatchStatus.scheduled:
        statusColor = AppColors.footballAccent;
        statusLabel = 'Scheduled';
        break;
      case MatchStatus.live:
        statusColor = AppColors.error;
        statusLabel = 'LIVE';
        break;
      case MatchStatus.completed:
        statusColor = AppColors.textSecondary;
        statusLabel = 'Completed';
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: match.status == MatchStatus.live
              ? AppColors.error.withValues(alpha: 0.4)
              : AppColors.divider,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                match.round,
                style: const TextStyle(
                    color: AppColors.textDisabled, fontSize: 12),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(
                      match.team1Name,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: match.winnerId == match.team1Id
                            ? FontWeight.bold
                            : FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (match.team1Score != null)
                      Text(
                        '${match.team1Score}',
                        style: TextStyle(
                          color: match.winnerId == match.team1Id
                              ? AppColors.actionGreen
                              : AppColors.textSecondary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'VS',
                  style: TextStyle(
                    color: AppColors.textDisabled,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      match.team2Name,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: match.winnerId == match.team2Id
                            ? FontWeight.bold
                            : FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (match.team2Score != null)
                      Text(
                        '${match.team2Score}',
                        style: TextStyle(
                          color: match.winnerId == match.team2Id
                              ? AppColors.actionGreen
                              : AppColors.textSecondary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.schedule,
                  color: AppColors.textDisabled, size: 14),
              const SizedBox(width: 4),
              Text(
                '${DateFormat('dd MMM').format(match.matchDate)} at ${match.matchTime}',
                style: const TextStyle(
                    color: AppColors.textDisabled, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRulesSection(TournamentModel tournament) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _rulesExpanded = !_rulesExpanded),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.rule, color: AppColors.textSecondary, size: 20),
                    SizedBox(width: 10),
                    Text(
                      'Rules & Regulations',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                AnimatedRotation(
                  turns: _rulesExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(Icons.keyboard_arrow_down,
                      color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: Text(
              tournament.rules,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.6,
              ),
            ),
          ),
          crossFadeState: _rulesExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 250),
        ),
      ],
    );
  }

  Widget _buildRegisterButton(TournamentModel tournament) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppColors.actionGradient,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.actionGreen.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: () {
            context.read<TournamentBloc>().add(
                  TournamentRegisterTeam(
                    tournamentId: tournament.id,
                    teamId: 'team_current',
                  ),
                );
          },
          icon: const Icon(Icons.group_add, color: Colors.white),
          label: const Text(
            'Register Team',
            style: TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
        ),
      ),
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
