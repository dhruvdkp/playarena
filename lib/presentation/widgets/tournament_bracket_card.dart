import 'package:flutter/material.dart';
import 'package:gamebooking/core/constants/app_colors.dart';
import 'package:gamebooking/data/models/tournament_model.dart';
import 'package:gamebooking/data/models/venue_model.dart';

/// A card displaying tournament information including name, sport,
/// format badge, dates, entry fee, prize pool, team registration
/// progress, status badge, and a register button.
class TournamentBracketCard extends StatelessWidget {
  final TournamentModel tournament;
  final VoidCallback? onRegister;

  const TournamentBracketCard({
    super.key,
    required this.tournament,
    this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    final registered = tournament.registeredTeams.length;
    final max = tournament.maxTeams;
    final progress = max > 0 ? (registered / max).clamp(0.0, 1.0) : 0.0;
    final isFull = registered >= max;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header with format and status badges ──
          _buildHeader(),
          const Divider(color: AppColors.divider, height: 1),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Sport & Venue ──
                _buildDetailRow(
                  _sportIcon(tournament.sportType),
                  _sportLabel(tournament.sportType),
                  _sportColor(tournament.sportType),
                ),
                const SizedBox(height: 6),
                _buildDetailRow(
                  Icons.location_on_outlined,
                  tournament.venueName,
                  AppColors.textSecondary,
                ),
                const SizedBox(height: 6),

                // ── Dates ──
                _buildDetailRow(
                  Icons.date_range_outlined,
                  '${_formatDate(tournament.startDate)} - ${_formatDate(tournament.endDate)}',
                  AppColors.textSecondary,
                ),
                const SizedBox(height: 16),

                // ── Fee & Prize row ──
                Row(
                  children: [
                    Expanded(
                      child: _buildStatBlock(
                        'Entry Fee',
                        '\u20B9${tournament.entryFee.toInt()}',
                        AppColors.accentYellow,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 36,
                      color: AppColors.divider,
                    ),
                    Expanded(
                      child: _buildStatBlock(
                        'Prize Pool',
                        '\u20B9${_formatPrize(tournament.prizePool)}',
                        AppColors.actionGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── Team registration progress ──
                Row(
                  children: [
                    const Icon(
                      Icons.groups_outlined,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$registered / $max teams registered',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: TextStyle(
                        color: isFull
                            ? AppColors.error
                            : AppColors.actionGreen,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.surface,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isFull ? AppColors.error : AppColors.actionGreen,
                    ),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 16),

                // ── Register button ──
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: isFull ||
                            tournament.status != TournamentStatus.upcoming
                        ? null
                        : onRegister,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.actionGreen,
                      disabledBackgroundColor: AppColors.surface,
                      foregroundColor: Colors.white,
                      disabledForegroundColor: AppColors.textDisabled,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      isFull
                          ? 'Registrations Full'
                          : tournament.status == TournamentStatus.upcoming
                              ? 'Register Now'
                              : tournament.status == TournamentStatus.ongoing
                                  ? 'Tournament Live'
                                  : 'Tournament Ended',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Tournament name
          Expanded(
            child: Text(
              tournament.name,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          _buildFormatBadge(tournament.format),
          const SizedBox(width: 8),
          _buildStatusBadge(tournament.status),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text, Color iconColor) {
    return Row(
      children: [
        Icon(icon, size: 15, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatBlock(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildFormatBadge(TournamentFormat format) {
    final String label;
    switch (format) {
      case TournamentFormat.knockout:
        label = 'Knockout';
      case TournamentFormat.roundRobin:
        label = 'Round Robin';
      case TournamentFormat.league:
        label = 'League';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.footballAccent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppColors.footballAccent.withValues(alpha: 0.4),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.footballAccent,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(TournamentStatus status) {
    final Color color;
    final String label;

    switch (status) {
      case TournamentStatus.upcoming:
        color = AppColors.accentYellow;
        label = 'Upcoming';
      case TournamentStatus.ongoing:
        color = AppColors.actionGreen;
        label = 'Live';
      case TournamentStatus.completed:
        color = AppColors.textSecondary;
        label = 'Ended';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  String _formatPrize(double amount) {
    if (amount >= 100000) {
      return '${(amount / 100000).toStringAsFixed(amount % 100000 == 0 ? 0 : 1)}L';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(amount % 1000 == 0 ? 0 : 1)}K';
    }
    return amount.toInt().toString();
  }

  IconData _sportIcon(SportType type) {
    switch (type) {
      case SportType.boxCricket:
        return Icons.sports_cricket;
      case SportType.football:
        return Icons.sports_soccer;
      case SportType.pickleball:
      case SportType.badminton:
      case SportType.tennis:
        return Icons.sports_tennis;
    }
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

  Color _sportColor(SportType type) {
    switch (type) {
      case SportType.boxCricket:
        return AppColors.cricketAccent;
      case SportType.football:
        return AppColors.footballAccent;
      case SportType.pickleball:
        return AppColors.pickleballAccent;
      case SportType.badminton:
        return const Color(0xFF8B5CF6);
      case SportType.tennis:
        return const Color(0xFF06B6D4);
    }
  }
}
