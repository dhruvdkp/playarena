import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:gamebooking/bloc/booking/booking_bloc.dart';
import 'package:gamebooking/core/constants/app_colors.dart';
import 'package:gamebooking/core/routes/app_router.dart';
import 'package:gamebooking/data/models/booking_model.dart';
import 'package:intl/intl.dart';

/// Shown immediately after a (bypassed) payment succeeds. Displays a
/// success animation, the amount paid, and the booking ID, then lets the
/// user view the full booking details or go back home.
class PaymentSuccessScreen extends StatefulWidget {
  const PaymentSuccessScreen({super.key});

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scale = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  BookingModel? _resolveBooking(BuildContext context) {
    final state = context.read<BookingBloc>().state;
    if (state is BookingCreated) return state.booking;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final booking = _resolveBooking(context);

    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: booking == null
            ? _buildEmptyState(context)
            : _buildSuccessContent(context, booking),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline,
              color: AppColors.textDisabled, size: 64),
          const SizedBox(height: 16),
          Text(
            'No payment information available',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go(AppRoutes.home),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.actionGreen,
            ),
            child:
                const Text('Go Home', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessContent(BuildContext context, BookingModel booking) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 40),
          _buildSuccessIcon(),
          const SizedBox(height: 28),
          Text(
            'Payment Successful!',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your slot has been booked successfully',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 32),
          _buildAmountCard(booking),
          const SizedBox(height: 16),
          _buildSummaryCard(booking),
          const SizedBox(height: 32),
          _buildViewBookingButton(context),
          const SizedBox(height: 12),
          _buildHomeButton(context),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.actionGreen.withValues(alpha: 0.15),
            border: Border.all(color: AppColors.actionGreen, width: 4),
          ),
          child: const Icon(
            Icons.check_rounded,
            color: AppColors.actionGreen,
            size: 72,
          ),
        ),
      ),
    );
  }

  Widget _buildAmountCard(BookingModel booking) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.actionGreen.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        children: [
          Text(
            'Amount Paid',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '\u20B9${booking.totalAmount.toStringAsFixed(0)}',
            style: const TextStyle(
              color: AppColors.actionGreen,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.actionGreen.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.verified, color: AppColors.actionGreen, size: 16),
                SizedBox(width: 6),
                Text(
                  'PAID (TEST MODE)',
                  style: TextStyle(
                    color: AppColors.actionGreen,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BookingModel booking) {
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
          _row('Booking ID', booking.id),
          const SizedBox(height: 10),
          _row('Venue', booking.venueName),
          const SizedBox(height: 10),
          _row(
            'Date',
            DateFormat('EEE, dd MMM yyyy').format(booking.slot.date),
          ),
          const SizedBox(height: 10),
          _row(
            'Time',
            '${booking.slot.startTime} - ${booking.slot.endTime}',
          ),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildViewBookingButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () => context.go(AppRoutes.bookingConfirmation),
        icon: const Icon(Icons.receipt_long, color: Colors.white),
        label: const Text(
          'View Booking Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.actionGreen,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  Widget _buildHomeButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: () => context.go(AppRoutes.home),
        icon: Icon(Icons.home_outlined, color: AppColors.textPrimary),
        label: Text(
          'Back to Home',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.divider),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}
