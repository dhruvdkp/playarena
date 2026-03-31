import 'package:flutter/material.dart';
import 'package:gamebooking/core/constants/app_colors.dart';
import 'package:gamebooking/data/models/venue_model.dart';

/// A compact chip widget that displays a sport icon and name.
///
/// When [isSelected] is true the chip is highlighted with a green accent.
/// Use [compact] for a smaller variant suitable for embedding inside cards.
class SportChip extends StatelessWidget {
  final SportType sportType;
  final bool isSelected;
  final VoidCallback? onTap;

  /// When true, renders a smaller chip without the icon (used inside cards).
  final bool compact;

  const SportChip({
    super.key,
    required this.sportType,
    this.isSelected = false,
    this.onTap,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final data = _sportData(sportType);

    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: data.color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          data.label,
          style: TextStyle(
            color: data.color,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.actionGreen.withValues(alpha: 0.15)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.actionGreen : AppColors.divider,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              data.icon,
              size: 18,
              color: isSelected ? AppColors.actionGreen : data.color,
            ),
            const SizedBox(width: 8),
            Text(
              data.label,
              style: TextStyle(
                color: isSelected
                    ? AppColors.actionGreen
                    : AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static _SportDisplayData _sportData(SportType type) {
    switch (type) {
      case SportType.boxCricket:
        return _SportDisplayData(
          label: 'Box Cricket',
          icon: Icons.sports_cricket,
          color: AppColors.cricketAccent,
        );
      case SportType.football:
        return _SportDisplayData(
          label: 'Football',
          icon: Icons.sports_soccer,
          color: AppColors.footballAccent,
        );
      case SportType.pickleball:
        return _SportDisplayData(
          label: 'Pickleball',
          icon: Icons.sports_tennis,
          color: AppColors.pickleballAccent,
        );
      case SportType.badminton:
        return _SportDisplayData(
          label: 'Badminton',
          icon: Icons.sports_tennis,
          color: const Color(0xFF8B5CF6),
        );
      case SportType.tennis:
        return _SportDisplayData(
          label: 'Tennis',
          icon: Icons.sports_tennis,
          color: const Color(0xFF06B6D4),
        );
    }
  }
}

class _SportDisplayData {
  final String label;
  final IconData icon;
  final Color color;

  const _SportDisplayData({
    required this.label,
    required this.icon,
    required this.color,
  });
}
