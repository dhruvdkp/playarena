import 'package:flutter/material.dart';
import 'package:gamebooking/core/constants/app_colors.dart';
import 'package:gamebooking/data/models/venue_model.dart';

/// A small widget that displays an amenity icon with a label below.
///
/// Maps each [Amenity] enum value to an appropriate Material icon
/// and a human-readable label.
class AmenityIcon extends StatelessWidget {
  final Amenity amenity;

  /// Optional size multiplier. Defaults to 1.0.
  final double scale;

  const AmenityIcon({
    super.key,
    required this.amenity,
    this.scale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final data = _amenityData(amenity);

    return SizedBox(
      width: 64 * scale,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 44 * scale,
            height: 44 * scale,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12 * scale),
              border: Border.all(
                color: AppColors.divider.withValues(alpha: 0.5),
              ),
            ),
            child: Icon(
              data.icon,
              size: 22 * scale,
              color: AppColors.actionGreen,
            ),
          ),
          SizedBox(height: 6 * scale),
          Text(
            data.label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10 * scale,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  static _AmenityDisplayData _amenityData(Amenity amenity) {
    switch (amenity) {
      case Amenity.parking:
        return const _AmenityDisplayData(
          icon: Icons.local_parking,
          label: 'Parking',
        );
      case Amenity.cctv:
        return const _AmenityDisplayData(
          icon: Icons.videocam,
          label: 'CCTV',
        );
      case Amenity.shower:
        return const _AmenityDisplayData(
          icon: Icons.shower,
          label: 'Shower',
        );
      case Amenity.drinkingWater:
        return const _AmenityDisplayData(
          icon: Icons.water_drop_outlined,
          label: 'Drinking\nWater',
        );
      case Amenity.changingRoom:
        return const _AmenityDisplayData(
          icon: Icons.checkroom,
          label: 'Changing\nRoom',
        );
      case Amenity.cafeteria:
        return const _AmenityDisplayData(
          icon: Icons.restaurant,
          label: 'Cafeteria',
        );
      case Amenity.firstAid:
        return const _AmenityDisplayData(
          icon: Icons.medical_services_outlined,
          label: 'First Aid',
        );
      case Amenity.wifi:
        return const _AmenityDisplayData(
          icon: Icons.wifi,
          label: 'Wi-Fi',
        );
      case Amenity.floodlights:
        return const _AmenityDisplayData(
          icon: Icons.highlight,
          label: 'Floodlights',
        );
      case Amenity.scoreboard:
        return const _AmenityDisplayData(
          icon: Icons.scoreboard_outlined,
          label: 'Scoreboard',
        );
    }
  }
}

class _AmenityDisplayData {
  final IconData icon;
  final String label;

  const _AmenityDisplayData({
    required this.icon,
    required this.label,
  });
}
