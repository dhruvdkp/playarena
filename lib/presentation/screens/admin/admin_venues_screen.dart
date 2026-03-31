import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gamebooking/core/constants/app_colors.dart';
import 'package:gamebooking/core/routes/app_router.dart';
import 'package:gamebooking/data/models/venue_model.dart';
import 'package:gamebooking/data/services/firestore_service.dart';

class AdminVenuesScreen extends StatefulWidget {
  const AdminVenuesScreen({super.key});

  @override
  State<AdminVenuesScreen> createState() => _AdminVenuesScreenState();
}

class _AdminVenuesScreenState extends State<AdminVenuesScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<VenueModel> _venues = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVenues();
  }

  Future<void> _loadVenues() async {
    setState(() => _isLoading = true);
    try {
      final data = await _firestoreService.getVenues();
      setState(() {
        _venues = data.map((j) => VenueModel.fromJson(j)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteVenue(VenueModel venue) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Venue',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'Are you sure you want to delete "${venue.name}"? This will also delete all slots and reviews.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child:
                const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _firestoreService.deleteVenue(venue.id);
      _loadVenues();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${venue.name} deleted'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground,
        title: const Text(
          'Manage Venues',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _loadVenues,
            icon: const Icon(Icons.refresh, color: AppColors.textSecondary),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push(AppRoutes.adminAddVenue);
          _loadVenues();
        },
        backgroundColor: AppColors.actionGreen,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Venue',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accentYellow))
          : _venues.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.stadium_outlined,
                          size: 64, color: AppColors.textDisabled),
                      const SizedBox(height: 16),
                      const Text('No venues yet',
                          style: TextStyle(
                              color: AppColors.textSecondary, fontSize: 16)),
                      const SizedBox(height: 8),
                      const Text('Tap + to add your first venue',
                          style: TextStyle(
                              color: AppColors.textDisabled, fontSize: 13)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadVenues,
                  color: AppColors.accentYellow,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _venues.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final venue = _venues[index];
                      return _VenueListTile(
                        venue: venue,
                        onEdit: () async {
                          await context.push(
                            '${AppRoutes.adminAddVenue}?venueId=${venue.id}',
                          );
                          _loadVenues();
                        },
                        onManageSlots: () {
                          context.push(
                            '${AppRoutes.adminManageSlots}?venueId=${venue.id}',
                          );
                        },
                        onDelete: () => _deleteVenue(venue),
                        onViewBookings: () {
                          context.push(
                            '${AppRoutes.adminVenueBookings}?venueId=${venue.id}&venueName=${Uri.encodeComponent(venue.name)}',
                          );
                        },
                      );
                    },
                  ),
                ),
    );
  }
}

class _VenueListTile extends StatelessWidget {
  final VenueModel venue;
  final VoidCallback onEdit;
  final VoidCallback onManageSlots;
  final VoidCallback onDelete;
  final VoidCallback onViewBookings;

  const _VenueListTile({
    required this.venue,
    required this.onEdit,
    required this.onManageSlots,
    required this.onDelete,
    required this.onViewBookings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          // Venue image or placeholder
          ClipRRect(
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(14)),
            child: venue.imageUrls.isNotEmpty
                ? Image.network(
                    venue.imageUrls.first,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _imagePlaceholder(),
                  )
                : _imagePlaceholder(),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        venue.name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (venue.isVerified)
                      const Icon(Icons.verified,
                          color: AppColors.actionGreen, size: 18),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${venue.address}, ${venue.city}',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _InfoChip(
                      icon: Icons.star,
                      label: venue.rating.toStringAsFixed(1),
                      color: AppColors.accentYellow,
                    ),
                    const SizedBox(width: 8),
                    _InfoChip(
                      icon: Icons.currency_rupee,
                      label: '${venue.pricePerHour.toStringAsFixed(0)}/hr',
                      color: AppColors.actionGreen,
                    ),
                    const SizedBox(width: 8),
                    _InfoChip(
                      icon: Icons.sports,
                      label: '${venue.sportTypes.length} sports',
                      color: AppColors.footballAccent,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _ActionButton(
                      icon: Icons.edit,
                      label: 'Edit',
                      color: AppColors.accentYellow,
                      onTap: onEdit,
                    ),
                    const SizedBox(width: 8),
                    _ActionButton(
                      icon: Icons.event_available,
                      label: 'Slots',
                      color: AppColors.actionGreen,
                      onTap: onManageSlots,
                    ),
                    const SizedBox(width: 8),
                    _ActionButton(
                      icon: Icons.receipt_long,
                      label: 'Bookings',
                      color: AppColors.footballAccent,
                      onTap: onViewBookings,
                    ),
                    const SizedBox(width: 8),
                    _ActionButton(
                      icon: Icons.delete_outline,
                      label: 'Delete',
                      color: AppColors.error,
                      onTap: onDelete,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      height: 120,
      width: double.infinity,
      color: AppColors.card,
      child: const Center(
        child:
            Icon(Icons.stadium, size: 40, color: AppColors.textDisabled),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                    color: color, fontSize: 10, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
