import 'package:flutter/material.dart';
import 'package:gamebooking/core/constants/app_colors.dart';
import 'package:gamebooking/data/models/booking_model.dart';
import 'package:gamebooking/data/models/venue_model.dart';

/// A detailed card that displays a complete booking summary including
/// venue, sport, date/time, slot duration, add-ons, split payment info,
/// total amount, QR code placeholder, and booking status badge.
class BookingSummaryCard extends StatelessWidget {
  final BookingModel booking;

  const BookingSummaryCard({
    super.key,
    required this.booking,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header with status badge ──
          _buildHeader(),
          Divider(color: AppColors.divider, height: 1),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Venue & Sport ──
                _buildInfoRow(
                  Icons.stadium_outlined,
                  booking.venueName,
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  _sportIcon(booking.sportType),
                  _sportLabel(booking.sportType),
                ),
                const SizedBox(height: 8),

                // ── Date & Time ──
                _buildInfoRow(
                  Icons.calendar_today_outlined,
                  _formatDate(booking.slot.date),
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.access_time_outlined,
                  '${booking.slot.startTime} - ${booking.slot.endTime}',
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  Icons.timelapse_outlined,
                  '${booking.slot.duration} min',
                ),

                // ── Add-ons ──
                if (booking.addOns.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Divider(color: AppColors.divider, height: 1),
                  const SizedBox(height: 14),
                  Text(
                    'Add-ons',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...booking.addOns.map((addOn) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${addOn.name} x${addOn.quantity}',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              '\u20B9${(addOn.price * addOn.quantity).toInt()}',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      )),
                ],

                // ── Split payment ──
                if (booking.splitPayment.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Divider(color: AppColors.divider, height: 1),
                  const SizedBox(height: 14),
                  Text(
                    'Split Payment',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...booking.splitPayment.map((split) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            Icon(
                              split.isPaid
                                  ? Icons.check_circle
                                  : Icons.pending_outlined,
                              size: 16,
                              color: split.isPaid
                                  ? AppColors.actionGreen
                                  : AppColors.accentYellow,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                split.userName,
                                style: TextStyle(
                                  color: AppColors.textPrimary,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Text(
                              '\u20B9${split.amount.toInt()}',
                              style: TextStyle(
                                color: split.isPaid
                                    ? AppColors.actionGreen
                                    : AppColors.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      )),
                ],

                // ── Total ──
                const SizedBox(height: 14),
                Divider(color: AppColors.divider, height: 1),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Amount',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '\u20B9${booking.totalAmount.toInt()}',
                      style: const TextStyle(
                        color: AppColors.actionGreen,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),

                // ── QR Code Placeholder ──
                if (booking.qrCode != null) ...[
                  const SizedBox(height: 16),
                  Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.qr_code_2,
                          size: 80,
                          color: AppColors.primaryBackground,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Show this QR at venue',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Booking Summary',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'ID: ${booking.id.length > 8 ? booking.id.substring(0, 8).toUpperCase() : booking.id.toUpperCase()}',
                  style: TextStyle(
                    color: AppColors.textDisabled,
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          _buildStatusBadge(booking.bookingStatus),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(BookingStatus status) {
    final Color color;
    final String label;

    switch (status) {
      case BookingStatus.upcoming:
        color = AppColors.footballAccent;
        label = 'Upcoming';
      case BookingStatus.ongoing:
        color = AppColors.actionGreen;
        label = 'Ongoing';
      case BookingStatus.completed:
        color = AppColors.textSecondary;
        label = 'Completed';
      case BookingStatus.cancelled:
        color = AppColors.error;
        label = 'Cancelled';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
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
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
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
}
