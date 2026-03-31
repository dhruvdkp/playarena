import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gamebooking/bloc/auth/auth_bloc.dart';
import 'package:gamebooking/core/constants/app_colors.dart';
import 'package:gamebooking/core/routes/app_router.dart';
import 'package:gamebooking/data/models/booking_model.dart';
import 'package:gamebooking/data/models/venue_model.dart';
import 'package:gamebooking/data/services/firestore_service.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  List<BookingModel> _allBookings = [];
  List<VenueModel> _allVenues = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final venueData = await _firestoreService.getVenues();
      final allBookingsSnapshot = await _firestoreService.getAllBookings();

      setState(() {
        _allVenues = venueData.map((j) => VenueModel.fromJson(j)).toList();
        _allBookings =
            allBookingsSnapshot.map((j) => BookingModel.fromJson(j)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  double get _revenueToday {
    final today = DateTime.now();
    return _allBookings
        .where((b) =>
            b.createdAt.year == today.year &&
            b.createdAt.month == today.month &&
            b.createdAt.day == today.day &&
            b.paymentStatus == PaymentStatus.completed)
        .fold(0.0, (sum, b) => sum + b.totalAmount);
  }

  double get _totalRevenue {
    return _allBookings
        .where((b) => b.paymentStatus == PaymentStatus.completed)
        .fold(0.0, (sum, b) => sum + b.totalAmount);
  }

  int get _todayBookings {
    final today = DateTime.now();
    return _allBookings
        .where((b) =>
            b.createdAt.year == today.year &&
            b.createdAt.month == today.month &&
            b.createdAt.day == today.day)
        .length;
  }

  int get _upcomingBookings {
    return _allBookings
        .where((b) => b.bookingStatus == BookingStatus.upcoming)
        .length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Admin Dashboard',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Manage your venues & bookings',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              context.read<AuthBloc>().add(const AuthLogoutRequested());
              context.go(AppRoutes.login);
            },
            icon: const Icon(Icons.logout, color: AppColors.textSecondary),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.accentYellow,
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadDashboardData,
              color: AppColors.accentYellow,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatCards(),
                    const SizedBox(height: 24),
                    _buildQuickActions(),
                    const SizedBox(height: 24),
                    _buildRecentBookings(),
                    const SizedBox(height: 24),
                    _buildVenueOverview(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildStatCards() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _StatCard(
          title: 'Total Revenue',
          value: '\u20B9${_totalRevenue.toStringAsFixed(0)}',
          icon: Icons.account_balance_wallet,
          color: AppColors.actionGreen,
        ),
        _StatCard(
          title: "Today's Revenue",
          value: '\u20B9${_revenueToday.toStringAsFixed(0)}',
          icon: Icons.trending_up,
          color: AppColors.accentYellow,
        ),
        _StatCard(
          title: "Today's Bookings",
          value: '$_todayBookings',
          icon: Icons.calendar_today,
          color: AppColors.footballAccent,
        ),
        _StatCard(
          title: 'Upcoming',
          value: '$_upcomingBookings',
          icon: Icons.upcoming,
          color: AppColors.pickleballAccent,
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionButton(
                icon: Icons.add_business,
                label: 'Add Venue',
                color: AppColors.actionGreen,
                onTap: () => context.go(AppRoutes.adminAddVenue),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.event_available,
                label: 'Manage Slots',
                color: AppColors.accentYellow,
                onTap: () {
                  if (_allVenues.isNotEmpty) {
                    context.go(
                      '${AppRoutes.adminManageSlots}?venueId=${_allVenues.first.id}',
                    );
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.receipt_long,
                label: 'All Bookings',
                color: AppColors.footballAccent,
                onTap: () {
                  // Navigate to bookings tab
                  final shell = StatefulNavigationShell.maybeOf(context);
                  shell?.goBranch(2);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentBookings() {
    final recent = _allBookings.take(5).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Bookings',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextButton(
              onPressed: () {
                final shell = StatefulNavigationShell.maybeOf(context);
                shell?.goBranch(2);
              },
              child: const Text(
                'See All',
                style: TextStyle(color: AppColors.accentYellow),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (recent.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                'No bookings yet',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          )
        else
          ...recent.map((booking) => _BookingTile(booking: booking)),
      ],
    );
  }

  Widget _buildVenueOverview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Your Venues',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextButton(
              onPressed: () {
                final shell = StatefulNavigationShell.maybeOf(context);
                shell?.goBranch(1);
              },
              child: const Text(
                'Manage',
                style: TextStyle(color: AppColors.accentYellow),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_allVenues.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                children: [
                  const Icon(Icons.stadium_outlined,
                      size: 48, color: AppColors.textDisabled),
                  const SizedBox(height: 12),
                  const Text(
                    'No venues added yet',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => context.go(AppRoutes.adminAddVenue),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Venue'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.actionGreen,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          SizedBox(
            height: 140,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _allVenues.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final venue = _allVenues[index];
                final venueBookings = _allBookings
                    .where((b) => b.venueId == venue.id)
                    .length;
                return _VenueCard(
                  venue: venue,
                  bookingCount: venueBookings,
                  onTap: () => context.go(
                    '${AppRoutes.adminManageSlots}?venueId=${venue.id}',
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

// ── Stat Card ────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 24),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ── Quick Action Button ──────────────────────────────────────────────────────

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Booking Tile ─────────────────────────────────────────────────────────────

class _BookingTile extends StatelessWidget {
  final BookingModel booking;

  const _BookingTile({required this.booking});

  Color get _statusColor {
    switch (booking.bookingStatus) {
      case BookingStatus.upcoming:
        return AppColors.footballAccent;
      case BookingStatus.ongoing:
        return AppColors.actionGreen;
      case BookingStatus.completed:
        return AppColors.textSecondary;
      case BookingStatus.cancelled:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Icon(
                Icons.sports_cricket,
                color: _statusColor,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.userName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${booking.venueName} · ${booking.slot.startTime}–${booking.slot.endTime}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\u20B9${booking.totalAmount.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: AppColors.actionGreen,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  booking.bookingStatus.name.toUpperCase(),
                  style: TextStyle(
                    color: _statusColor,
                    fontSize: 9,
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
}

// ── Venue Card ───────────────────────────────────────────────────────────────

class _VenueCard extends StatelessWidget {
  final VenueModel venue;
  final int bookingCount;
  final VoidCallback onTap;

  const _VenueCard({
    required this.venue,
    required this.bookingCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.accentYellow.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(Icons.stadium,
                        color: AppColors.accentYellow, size: 20),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    venue.name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              venue.city,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\u20B9${venue.pricePerHour.toStringAsFixed(0)}/hr',
                  style: const TextStyle(
                    color: AppColors.actionGreen,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '$bookingCount bookings',
                  style: const TextStyle(
                    color: AppColors.textDisabled,
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
