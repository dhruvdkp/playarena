import 'package:flutter/material.dart';
import 'package:gamebooking/core/constants/app_colors.dart';
import 'package:gamebooking/data/models/match_request_model.dart';
import 'package:gamebooking/data/models/venue_model.dart';

class MatchCard extends StatelessWidget {
  final MatchRequestModel match;
  final VoidCallback? onJoin;

  const MatchCard({
    super.key,
    required this.match,
    this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    final joined = match.playersJoined.length;
    final needed = match.playersNeeded;
    final progress = needed > 0 ? (joined / needed).clamp(0.0, 1.0) : 0.0;
    final isFull = joined >= needed;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isCompact = screenWidth < 360;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isCompact ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Top row: Host info + Skill badge ──
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.actionGreen.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      match.hostName.isNotEmpty
                          ? match.hostName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: AppColors.actionGreen,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        match.hostName,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: isCompact ? 13 : 14,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Host',
                        style: TextStyle(
                          color:
                              AppColors.textSecondary.withValues(alpha: 0.7),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _buildSkillBadge(match.skillLevel),
              ],
            ),

            const SizedBox(height: 12),

            // ── Sport & Venue ──
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _infoChip(
                  _sportIcon(match.sportType),
                  _sportLabel(match.sportType),
                  _sportColor(match.sportType),
                ),
                _infoChip(
                  Icons.location_on_outlined,
                  match.venueName,
                  AppColors.textSecondary,
                ),
              ],
            ),

            const SizedBox(height: 8),

            // ── Date & Time ──
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                _infoChip(
                  Icons.calendar_today_outlined,
                  _formatDate(match.date),
                  AppColors.textSecondary,
                ),
                _infoChip(
                  Icons.access_time_outlined,
                  match.time,
                  AppColors.textSecondary,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ── Player progress bar ──
            Row(
              children: [
                Icon(Icons.people_outline,
                    size: 15, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  '$joined / $needed players',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: TextStyle(
                    color: isFull
                        ? AppColors.actionGreen
                        : AppColors.accentYellow,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.surface,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isFull ? AppColors.actionGreen : AppColors.accentYellow,
                ),
                minHeight: 5,
              ),
            ),

            const SizedBox(height: 14),

            // ── Join button ──
            SizedBox(
              width: double.infinity,
              height: 42,
              child: ElevatedButton(
                onPressed:
                    isFull || match.status != MatchRequestStatus.open
                        ? null
                        : onJoin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.actionGreen,
                  disabledBackgroundColor: AppColors.surface,
                  foregroundColor: Colors.white,
                  disabledForegroundColor: AppColors.textDisabled,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    isFull
                        ? 'Game Full'
                        : match.status == MatchRequestStatus.open
                            ? 'Join Game'
                            : match.status.name.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            style: TextStyle(
              color: color == AppColors.textSecondary
                  ? AppColors.textPrimary
                  : color,
              fontSize: 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildSkillBadge(SkillLevel level) {
    final Color color;
    final String label;

    switch (level) {
      case SkillLevel.beginner:
        color = AppColors.actionGreen;
        label = 'Beginner';
      case SkillLevel.intermediate:
        color = AppColors.accentYellow;
        label = 'Intermediate';
      case SkillLevel.advanced:
        color = AppColors.error;
        label = 'Advanced';
      case SkillLevel.any:
        color = AppColors.footballAccent;
        label = 'Any Level';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
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
    return '${date.day} ${months[date.month - 1]} ${date.year}';
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
