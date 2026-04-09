import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gamebooking/bloc/auth/auth_bloc.dart';
import 'package:gamebooking/core/constants/app_colors.dart';
import 'package:gamebooking/core/routes/app_router.dart';
import 'package:gamebooking/data/models/booking_model.dart';
import 'package:gamebooking/data/models/venue_model.dart';
import 'package:gamebooking/data/services/firestore_service.dart';
import 'package:intl/intl.dart';

/// Live "My Bookings" screen — every value comes from a Firestore snapshot
/// stream so cancellations, new bookings, and status changes appear in real
/// time without any pull-to-refresh.
class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen>
    with SingleTickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;

    if (authState is! AuthAuthenticated) {
      return Scaffold(
        backgroundColor: AppColors.primaryBackground,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          title: const Text(
            'My Bookings',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          iconTheme: const IconThemeData(color: AppColors.textPrimary),
        ),
        body: _buildSignedOutState(context),
      );
    }

    final userId = authState.user.id;

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          'My Bookings',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _firestoreService.userBookingsStream(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.actionGreen),
            );
          }

          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }

          final bookings = (snapshot.data ?? [])
              .map((j) {
                try {
                  return BookingModel.fromJson(j);
                } catch (_) {
                  return null;
                }
              })
              .whereType<BookingModel>()
              .toList();

          return Column(
            children: [
              _buildSummaryStrip(bookings),
              _buildTabBar(bookings),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildBookingList(bookings, null),
                    _buildBookingList(bookings, BookingStatus.upcoming),
                    _buildBookingList(bookings, BookingStatus.completed),
                    _buildBookingList(bookings, BookingStatus.cancelled),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── States ──────────────────────────────────────────────────────────────

  Widget _buildSignedOutState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock_outline,
              color: AppColors.textDisabled, size: 64),
          const SizedBox(height: 16),
          const Text(
            'Please sign in to view your bookings',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => context.go(AppRoutes.login),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.actionGreen,
            ),
            child:
                const Text('Sign In', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline,
                color: AppColors.error, size: 56),
            const SizedBox(height: 12),
            const Text(
              'Could not load bookings',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Summary strip ───────────────────────────────────────────────────────

  Widget _buildSummaryStrip(List<BookingModel> bookings) {
    final total = bookings.length;
    final upcoming = bookings
        .where((b) => b.bookingStatus == BookingStatus.upcoming)
        .length;
    final totalSpent = bookings
        .where((b) => b.paymentStatus == PaymentStatus.completed)
        .fold<double>(0, (sum, b) => sum + b.totalAmount);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      decoration: BoxDecoration(
        gradient: AppColors.stadiumGradient,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.actionGreen.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _summaryItem(
            icon: Icons.receipt_long,
            label: 'Total',
            value: '$total',
          ),
          Container(width: 1, height: 36, color: AppColors.divider),
          _summaryItem(
            icon: Icons.event_available,
            label: 'Upcoming',
            value: '$upcoming',
          ),
          Container(width: 1, height: 36, color: AppColors.divider),
          _summaryItem(
            icon: Icons.currency_rupee,
            label: 'Spent',
            value: '\u20B9${totalSpent.toStringAsFixed(0)}',
          ),
        ],
      ),
    );
  }

  Widget _summaryItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppColors.actionGreen, size: 18),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  // ── Tab bar ─────────────────────────────────────────────────────────────

  Widget _buildTabBar(List<BookingModel> bookings) {
    int countOf(BookingStatus s) =>
        bookings.where((b) => b.bookingStatus == s).length;

    return Container(
      color: AppColors.primaryBackground,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        indicatorColor: AppColors.actionGreen,
        labelColor: AppColors.actionGreen,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        unselectedLabelStyle:
            const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        tabs: [
          Tab(text: 'All (${bookings.length})'),
          Tab(text: 'Upcoming (${countOf(BookingStatus.upcoming)})'),
          Tab(text: 'Completed (${countOf(BookingStatus.completed)})'),
          Tab(text: 'Cancelled (${countOf(BookingStatus.cancelled)})'),
        ],
      ),
    );
  }

  // ── Booking list ────────────────────────────────────────────────────────

  Widget _buildBookingList(
    List<BookingModel> all,
    BookingStatus? filter,
  ) {
    final filtered = filter == null
        ? all
        : all.where((b) => b.bookingStatus == filter).toList();

    if (filtered.isEmpty) {
      return _buildEmptyState(filter);
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final booking = filtered[index];
        return _BookingCard(
          booking: booking,
          onCancel: booking.bookingStatus == BookingStatus.upcoming
              ? () => _confirmCancel(booking)
              : null,
        );
      },
    );
  }

  Widget _buildEmptyState(BookingStatus? filter) {
    final message = switch (filter) {
      null => 'You have no bookings yet',
      BookingStatus.upcoming => 'No upcoming bookings',
      BookingStatus.completed => 'No completed bookings yet',
      BookingStatus.cancelled => 'No cancelled bookings',
      _ => 'No bookings',
    };

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.event_busy_outlined,
            color: AppColors.textDisabled,
            size: 56,
          ),
          const SizedBox(height: 14),
          Text(
            message,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 18),
          if (filter == null || filter == BookingStatus.upcoming)
            OutlinedButton.icon(
              onPressed: () => context.go(AppRoutes.venues),
              icon: const Icon(Icons.search, color: AppColors.actionGreen),
              label: const Text(
                'Browse venues',
                style: TextStyle(color: AppColors.actionGreen),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.actionGreen),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Cancel flow ─────────────────────────────────────────────────────────

  Future<void> _confirmCancel(BookingModel booking) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Cancel booking?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Cancel your booking at ${booking.venueName}? '
          'The slot will be released and made available to others.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Keep',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text(
              'Cancel booking',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _firestoreService.cancelBooking(booking.id);
      // The stream will auto-refresh; also release the slot manually so the
      // venue page can re-show it as available.
      await _firestoreService.releaseSlot(booking.venueId, booking.slot.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking cancelled'),
            backgroundColor: AppColors.actionGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Booking card
// ─────────────────────────────────────────────────────────────────────────────

class _BookingCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback? onCancel;

  const _BookingCard({required this.booking, this.onCancel});

  Color get _statusColor {
    switch (booking.bookingStatus) {
      case BookingStatus.upcoming:
        return AppColors.actionGreen;
      case BookingStatus.ongoing:
        return AppColors.accentYellow;
      case BookingStatus.completed:
        return AppColors.textSecondary;
      case BookingStatus.cancelled:
        return AppColors.error;
    }
  }

  Color get _paymentColor {
    switch (booking.paymentStatus) {
      case PaymentStatus.completed:
        return AppColors.actionGreen;
      case PaymentStatus.pending:
        return AppColors.accentYellow;
      case PaymentStatus.failed:
        return AppColors.error;
      case PaymentStatus.refunded:
        return AppColors.textSecondary;
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

  @override
  Widget build(BuildContext context) {
    final dateLabel =
        DateFormat('EEE, dd MMM yyyy').format(booking.slot.date);
    final timeLabel = '${booking.slot.startTime} – ${booking.slot.endTime}';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _statusColor.withValues(alpha: 0.35)),
      ),
      child: Column(
        children: [
          // Header row — venue name + status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _statusColor.withValues(alpha: 0.08),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Row(
              children: [
                Icon(Icons.stadium, color: _statusColor, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    booking.venueName,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    booking.bookingStatus.name.toUpperCase(),
                    style: TextStyle(
                      color: _statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Body — details
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                _row(Icons.sports, 'Sport', _sportLabel(booking.sportType)),
                const SizedBox(height: 8),
                _row(Icons.calendar_today, 'Date', dateLabel),
                const SizedBox(height: 8),
                _row(Icons.access_time, 'Time', timeLabel),
                const SizedBox(height: 8),
                _row(
                  Icons.timer_outlined,
                  'Duration',
                  '${booking.slot.duration} mins',
                ),
                if (booking.addOns.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _row(
                    Icons.add_shopping_cart,
                    'Add-ons',
                    booking.addOns.map((a) => a.name).join(', '),
                  ),
                ],
                if (booking.splitPayment.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _row(
                    Icons.group_outlined,
                    'Split with',
                    '${booking.splitPayment.length} friend${booking.splitPayment.length > 1 ? 's' : ''}',
                  ),
                ],
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(color: AppColors.divider, height: 1),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '\u20B9${booking.totalAmount.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: AppColors.actionGreen,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _paymentColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        booking.paymentStatus.name.toUpperCase(),
                        style: TextStyle(
                          color: _paymentColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Booking ID · ${booking.id}',
                  style: const TextStyle(
                    color: AppColors.textDisabled,
                    fontSize: 11,
                  ),
                ),
                if (onCancel != null) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: onCancel,
                      icon: const Icon(Icons.cancel_outlined, size: 16),
                      label: const Text('Cancel booking'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textDisabled),
        const SizedBox(width: 8),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
