import 'package:flutter/material.dart';
import 'package:gamebooking/core/constants/app_colors.dart';
import 'package:gamebooking/data/models/booking_model.dart';
import 'package:gamebooking/data/services/firestore_service.dart';

class AdminBookingsScreen extends StatefulWidget {
  const AdminBookingsScreen({super.key});

  @override
  State<AdminBookingsScreen> createState() => _AdminBookingsScreenState();
}

class _AdminBookingsScreenState extends State<AdminBookingsScreen>
    with SingleTickerProviderStateMixin {
  final FirestoreService _firestoreService = FirestoreService();
  List<BookingModel> _allBookings = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);
    try {
      final data = await _firestoreService.getAllBookings();
      setState(() {
        _allBookings = data.map((j) => BookingModel.fromJson(j)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<BookingModel> _filteredBookings(BookingStatus? status) {
    if (status == null) return _allBookings;
    return _allBookings.where((b) => b.bookingStatus == status).toList();
  }

  Future<void> _cancelBooking(BookingModel booking) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancel Booking',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'Cancel booking by ${booking.userName} at ${booking.venueName}?',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Cancel Booking',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _firestoreService.cancelBooking(booking.id);
      _loadBookings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground,
        title: const Text(
          'All Bookings',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _loadBookings,
            icon: const Icon(Icons.refresh, color: AppColors.textSecondary),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppColors.accentYellow,
          labelColor: AppColors.accentYellow,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: [
            Tab(text: 'All (${_allBookings.length})'),
            Tab(
                text:
                    'Upcoming (${_filteredBookings(BookingStatus.upcoming).length})'),
            Tab(
                text:
                    'Completed (${_filteredBookings(BookingStatus.completed).length})'),
            Tab(
                text:
                    'Cancelled (${_filteredBookings(BookingStatus.cancelled).length})'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accentYellow))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildBookingList(null),
                _buildBookingList(BookingStatus.upcoming),
                _buildBookingList(BookingStatus.completed),
                _buildBookingList(BookingStatus.cancelled),
              ],
            ),
    );
  }

  Widget _buildBookingList(BookingStatus? status) {
    final bookings = _filteredBookings(status);
    if (bookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.receipt_long_outlined,
                size: 48, color: AppColors.textDisabled),
            const SizedBox(height: 12),
            Text(
              status == null ? 'No bookings yet' : 'No ${status.name} bookings',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBookings,
      color: AppColors.accentYellow,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: bookings.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return _AdminBookingCard(
            booking: booking,
            onCancel: booking.bookingStatus == BookingStatus.upcoming
                ? () => _cancelBooking(booking)
                : null,
          );
        },
      ),
    );
  }
}

class _AdminBookingCard extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback? onCancel;

  const _AdminBookingCard({required this.booking, this.onCancel});

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

  @override
  Widget build(BuildContext context) {
    final date = booking.slot.date;
    final dateStr =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _statusColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _statusColor.withValues(alpha: 0.08),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(Icons.person, color: _statusColor, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    booking.userName,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
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
          // Body
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                _DetailRow(
                  icon: Icons.stadium,
                  label: 'Venue',
                  value: booking.venueName,
                ),
                const SizedBox(height: 8),
                _DetailRow(
                  icon: Icons.sports,
                  label: 'Sport',
                  value: booking.sportType.name,
                ),
                const SizedBox(height: 8),
                _DetailRow(
                  icon: Icons.calendar_today,
                  label: 'Date',
                  value: dateStr,
                ),
                const SizedBox(height: 8),
                _DetailRow(
                  icon: Icons.access_time,
                  label: 'Time',
                  value: '${booking.slot.startTime} – ${booking.slot.endTime}',
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _DetailRow(
                        icon: Icons.currency_rupee,
                        label: 'Amount',
                        value:
                            '\u20B9${booking.totalAmount.toStringAsFixed(0)}',
                        valueColor: AppColors.actionGreen,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
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
                if (onCancel != null) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: onCancel,
                      icon: const Icon(Icons.cancel_outlined, size: 16),
                      label: const Text('Cancel Booking'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
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
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textDisabled),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
              color: AppColors.textSecondary, fontSize: 13),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: valueColor ?? AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
