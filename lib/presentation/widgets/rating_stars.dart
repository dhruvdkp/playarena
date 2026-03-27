import 'package:flutter/material.dart';
import 'package:gamebooking/core/constants/app_colors.dart';

/// Displays a star rating (1-5) with half-star support, the numeric
/// rating value, and an optional review count.
class RatingStars extends StatelessWidget {
  /// Rating value between 0.0 and 5.0.
  final double rating;

  /// Number of reviews. If 0, the review count label is hidden.
  final int reviewCount;

  /// Size of each star icon. Defaults to 16.
  final double starSize;

  const RatingStars({
    super.key,
    required this.rating,
    this.reviewCount = 0,
    this.starSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Stars
        ...List.generate(5, (index) {
          final starValue = index + 1;
          if (rating >= starValue) {
            return Icon(
              Icons.star_rounded,
              size: starSize,
              color: AppColors.accentYellow,
            );
          } else if (rating >= starValue - 0.5) {
            return Icon(
              Icons.star_half_rounded,
              size: starSize,
              color: AppColors.accentYellow,
            );
          } else {
            return Icon(
              Icons.star_outline_rounded,
              size: starSize,
              color: AppColors.textDisabled,
            );
          }
        }),
        const SizedBox(width: 6),

        // Numeric rating
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: starSize * 0.8,
            fontWeight: FontWeight.w700,
          ),
        ),

        // Review count
        if (reviewCount > 0) ...[
          const SizedBox(width: 4),
          Text(
            '($reviewCount)',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: starSize * 0.7,
            ),
          ),
        ],
      ],
    );
  }
}
