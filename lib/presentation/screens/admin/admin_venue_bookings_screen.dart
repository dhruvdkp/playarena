import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gamebooking/core/constants/app_colors.dart';
import 'package:gamebooking/data/models/booking_model.dart';
import 'package:gamebooking/data/services/firestore_service.dart';

class AdminVenueBookingsScreen extends StatefulWidget {
  final String venueId;
  final String venueName;
  const AdminVenueBookingsScreen({
    super.key,
    required this.venueId,
    required this.venueName,
  });

  @override
  State<AdminVenueBookingsScreen> createState() =>
      _AdminVenueBookingsScreenState();
}

class _AdminVenueBookingsScreenState extends State<AdminVenueBookingsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  List<BookingModel> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);
    try {
      final data =
          await _firestoreService.getBookingsByVenue(widget.venueId);
      setState(() {
        _bookings = data.map((j) => BookingModel.fromJson(j)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBackground,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back_ios_new,
              color: AppColors.textPrimary),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Venue Bookings',
                style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700)),
            Text(widget.venueName,
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accentYellow))
          : _bookings.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.receipt_long_outlined,
                          size: 48, color: AppColors.textDisabled),
                      SizedBox(height: 12),
                      Text('No bookings for this venue',
                          style: TextStyle(color: AppColors.textSecondary)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadBookings,
                  color: AppColors.accentYellow,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _bookings.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final booking = _bookings[index];
                      return _VenueBookingCard(booking: booking);
                    },
                  ),
                ),
    );
  }
}

class _VenueBookingCard extends StatelessWidget {
  final BookingModel booking;
  const _VenueBookingCard({required this.booking});

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
    final date = booking.slot.date;
    final dateStr =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          // User avatar
          CircleAvatar(
            radius: 22,
            backgroundColor: _statusColor.withValues(alpha: 0.15),
            child: Text(
              booking.userName.isNotEmpty
                  ? booking.userName[0].toUpperCase()
                  : '?',
              style: TextStyle(
                color: _statusColor,
                fontWeight: FontWeight.w700,
                fontSize: 18,
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
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$dateStr  |  ${booking.slot.startTime} – ${booking.slot.endTime}',
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 12),
                ),
                const SizedBox(height: 2),
                Text(
                  booking.sportType.name,
                  style: const TextStyle(
                      color: AppColors.textDisabled, fontSize: 11),
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
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 4),
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
        ],
      ),
    );
  }
}
