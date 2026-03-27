import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gamebooking/bloc/booking/booking_bloc.dart';
import 'package:gamebooking/core/constants/app_colors.dart';
import 'package:gamebooking/core/routes/app_router.dart';
import 'package:gamebooking/data/models/booking_model.dart';
import 'package:gamebooking/data/models/venue_model.dart';
import 'package:intl/intl.dart';

class BookingConfirmationScreen extends StatefulWidget {
  final BookingModel? booking;

  const BookingConfirmationScreen({super.key, this.booking});

  @override
  State<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _checkAnimController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _checkAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _checkAnimController,
      curve: Curves.elasticOut,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _checkAnimController,
      curve: Curves.easeIn,
    );
    _checkAnimController.forward();
  }

  @override
  void dispose() {
    _checkAnimController.dispose();
    super.dispose();
  }

  BookingModel? _resolveBooking(BuildContext context) {
    if (widget.booking != null) return widget.booking;
    final state = context.read<BookingBloc>().state;
    if (state is BookingCreated) return state.booking;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final booking = _resolveBooking(context);

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Booking Confirmed',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: booking == null
          ? _buildNoBookingState()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  _buildSuccessAnimation(),
                  const SizedBox(height: 24),
                  _buildBookingIdCard(booking),
                  const SizedBox(height: 20),
                  _buildQrCodePlaceholder(booking),
                  const SizedBox(height: 20),
                  _buildBookingDetailsSummary(booking),
                  const SizedBox(height: 32),
                  _buildShareButton(context, booking),
                  const SizedBox(height: 12),
                  _buildBackToHomeButton(context),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildNoBookingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: AppColors.textDisabled,
            size: 64,
          ),
          const SizedBox(height: 16),
          const Text(
            'No booking data available',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go(AppRoutes.home),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.actionGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child:
                const Text('Go Home', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessAnimation() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.actionGreen.withValues(alpha: 0.15),
            border: Border.all(color: AppColors.actionGreen, width: 3),
          ),
          child: const Icon(
            Icons.check_rounded,
            color: AppColors.actionGreen,
            size: 56,
          ),
        ),
      ),
    );
  }

  Widget _buildBookingIdCard(BookingModel booking) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.actionGreen.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        children: [
          const Text(
            'Booking ID',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            booking.id,
            style: const TextStyle(
              color: AppColors.actionGreen,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQrCodePlaceholder(BookingModel booking) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.qr_code_2_rounded,
            size: 120,
            color: AppColors.primaryBackground.withValues(alpha: 0.85),
          ),
          const SizedBox(height: 8),
          Text(
            'Scan at venue',
            style: TextStyle(
              color: AppColors.primaryBackground.withValues(alpha: 0.6),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingDetailsSummary(BookingModel booking) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Booking Details',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          _detailRow(Icons.stadium_outlined, 'Venue', booking.venueName),
          _detailRow(Icons.sports, 'Sport', _sportLabel(booking.sportType)),
          _detailRow(
            Icons.calendar_today,
            'Date',
            DateFormat('EEE, dd MMM yyyy').format(booking.slot.date),
          ),
          _detailRow(
            Icons.schedule,
            'Time',
            '${booking.slot.startTime} - ${booking.slot.endTime}',
          ),
          _detailRow(
            Icons.timer_outlined,
            'Duration',
            '${booking.slot.duration} mins',
          ),
          if (booking.addOns.isNotEmpty)
            _detailRow(
              Icons.add_shopping_cart,
              'Add-ons',
              booking.addOns.map((a) => a.name).join(', '),
            ),
          if (booking.splitPayment.isNotEmpty)
            _detailRow(
              Icons.group,
              'Split With',
              '${booking.splitPayment.length} friend${booking.splitPayment.length > 1 ? 's' : ''}',
            ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(color: AppColors.divider, height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Paid',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '\u20B9${booking.totalAmount.toStringAsFixed(0)}',
                style: const TextStyle(
                  color: AppColors.actionGreen,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 18),
          const SizedBox(width: 10),
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
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareButton(BuildContext context, BookingModel booking) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sharing booking details...'),
              backgroundColor: AppColors.surface,
            ),
          );
        },
        icon: const Icon(Icons.share_outlined, color: AppColors.actionGreen),
        label: const Text(
          'Share Booking',
          style: TextStyle(
            color: AppColors.actionGreen,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.actionGreen, width: 1.5),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  Widget _buildBackToHomeButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () {
          context.go(AppRoutes.home);
        },
        icon: const Icon(Icons.home_outlined, color: Colors.white),
        label: const Text(
          'Back to Home',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.card,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
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
