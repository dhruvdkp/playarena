import 'package:flutter/material.dart';
import 'package:gamebooking/core/constants/app_colors.dart';
import 'package:gamebooking/data/models/venue_model.dart';
import 'package:gamebooking/presentation/widgets/rating_stars.dart';
import 'package:gamebooking/presentation/widgets/sport_chip.dart';

/// A sleek card widget that displays venue information with an image,
/// gradient overlay, sport type chips, rating, price, and live occupancy.
class VenueCard extends StatelessWidget {
  final VenueModel venue;
  final VoidCallback? onTap;

  const VenueCard({
    super.key,
    required this.venue,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image with gradient overlay ──
            _buildImageSection(),
            // ── Details section ──
            _buildDetailsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return SizedBox(
      height: 180,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Venue image
          venue.imageUrls.isNotEmpty
              ? Image.network(
                  venue.imageUrls.first,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
                )
              : _buildPlaceholderImage(),

          // Gradient overlay
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: AppColors.cardImageOverlay,
            ),
          ),

          // Verified badge
          if (venue.isVerified)
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.actionGreen,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified, size: 14, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'Verified',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Occupancy badge
          Positioned(
            top: 12,
            right: 12,
            child: _buildOccupancyBadge(),
          ),

          // Price tag on image
          Positioned(
            bottom: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryBackground.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.actionGreen.withValues(alpha: 0.5),
                ),
              ),
              child: Text(
                '\u20B9${venue.pricePerHour.toInt()}/hr',
                style: const TextStyle(
                  color: AppColors.actionGreen,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection() {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Venue name
          Text(
            venue.name,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),

          // Address
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 14,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  venue.address,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Sport type chips
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: venue.sportTypes
                .map((sport) => SportChip(
                      sportType: sport,
                      isSelected: false,
                      compact: true,
                    ))
                .toList(),
          ),
          const SizedBox(height: 10),

          // Rating stars
          RatingStars(
            rating: venue.rating,
            reviewCount: venue.totalReviews,
          ),
        ],
      ),
    );
  }

  Widget _buildOccupancyBadge() {
    final slotsLeft = venue.availableSlots;
    final Color badgeColor;
    final String badgeText;

    if (slotsLeft == 0) {
      badgeColor = AppColors.fullyBooked;
      badgeText = 'Fully Booked';
    } else if (slotsLeft <= 3) {
      badgeColor = AppColors.fillingFast;
      badgeText = '$slotsLeft slots left today';
    } else {
      badgeColor = AppColors.available;
      badgeText = '$slotsLeft slots left today';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: badgeColor.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: badgeColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            badgeText,
            style: TextStyle(
              color: badgeColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: AppColors.surface,
      child: const Center(
        child: Icon(
          Icons.stadium_outlined,
          size: 48,
          color: AppColors.textDisabled,
        ),
      ),
    );
  }
}
