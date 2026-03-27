import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:gamebooking/core/constants/app_colors.dart';

/// General-purpose utility functions used across the GameBooking app.
class Helpers {
  Helpers._();

  // ── Price Formatting ──────────────────────────────────────────────────

  /// Formats [amount] as Indian Rupee with no decimals for whole numbers
  /// and two decimals otherwise.
  ///
  /// ```dart
  /// Helpers.formatPrice(1500);    // '₹1,500'
  /// Helpers.formatPrice(1500.50); // '₹1,500.50'
  /// ```
  static String formatPrice(num amount) {
    final formatter = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '\u20B9',
      decimalDigits: amount == amount.toInt() ? 0 : 2,
    );
    return formatter.format(amount);
  }

  // ── Date Formatting ───────────────────────────────────────────────────

  /// Human-friendly date string.
  ///
  /// [pattern] defaults to `'EEE, d MMM yyyy'` → `'Sat, 5 Apr 2025'`.
  static String formatDate(DateTime date, {String pattern = 'EEE, d MMM yyyy'}) {
    return DateFormat(pattern).format(date);
  }

  /// Returns a relative label when the date is today or tomorrow,
  /// otherwise falls back to [formatDate].
  static String formatDateRelative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = target.difference(today).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff == -1) return 'Yesterday';
    return formatDate(date);
  }

  // ── Time Formatting ───────────────────────────────────────────────────

  /// Formats a [TimeOfDay] as `'6:30 PM'`.
  static String formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  /// Formats a [DateTime]'s time portion as `'6:30 PM'`.
  static String formatTimeFromDateTime(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime);
  }

  // ── Duration Formatting ───────────────────────────────────────────────

  /// Formats a slot duration given in **minutes** into a readable string.
  ///
  /// ```dart
  /// Helpers.formatSlotDuration(60);  // '1 hr'
  /// Helpers.formatSlotDuration(90);  // '1 hr 30 min'
  /// Helpers.formatSlotDuration(30);  // '30 min'
  /// ```
  static String formatSlotDuration(int minutes) {
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final remaining = minutes % 60;
    if (remaining == 0) {
      return '$hours hr${hours > 1 ? 's' : ''}';
    }
    return '$hours hr${hours > 1 ? 's' : ''} $remaining min';
  }

  // ── Greeting ──────────────────────────────────────────────────────────

  /// Returns a time-appropriate greeting.
  ///
  /// | Hour range  | Greeting          |
  /// |-------------|-------------------|
  /// | 05 – 11     | Good Morning      |
  /// | 12 – 16     | Good Afternoon    |
  /// | 17 – 20     | Good Evening      |
  /// | 21 – 04     | Good Night        |
  static String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Good Morning';
    if (hour >= 12 && hour < 17) return 'Good Afternoon';
    if (hour >= 17 && hour < 21) return 'Good Evening';
    return 'Good Night';
  }

  // ── Sport Icons ───────────────────────────────────────────────────────

  /// Maps a sport-type key to a Material [IconData].
  ///
  /// Recognised keys (case-insensitive): `box_cricket`, `cricket`,
  /// `football`, `pickleball`, `tennis`, `badminton`, `basketball`.
  /// Falls back to [Icons.sports] for unknown types.
  static IconData getSportIcon(String sportType) {
    switch (sportType.toLowerCase().replaceAll(' ', '_')) {
      case 'box_cricket':
      case 'cricket':
        return Icons.sports_cricket;
      case 'football':
      case 'soccer':
        return Icons.sports_soccer;
      case 'pickleball':
      case 'tennis':
        return Icons.sports_tennis;
      case 'badminton':
        return Icons.sports_tennis; // closest Material icon
      case 'basketball':
        return Icons.sports_basketball;
      case 'volleyball':
        return Icons.sports_volleyball;
      case 'hockey':
        return Icons.sports_hockey;
      default:
        return Icons.sports;
    }
  }

  // ── Occupancy ─────────────────────────────────────────────────────────

  /// Returns a colour representing the current occupancy level.
  ///
  /// [occupancyPercentage] should be between 0 and 100.
  ///
  /// * 0 – 49 → [AppColors.available]  (green)
  /// * 50 – 84 → [AppColors.fillingFast] (yellow)
  /// * 85 – 100 → [AppColors.fullyBooked] (red)
  static Color getOccupancyColor(double occupancyPercentage) {
    if (occupancyPercentage < 50) return AppColors.available;
    if (occupancyPercentage < 85) return AppColors.fillingFast;
    return AppColors.fullyBooked;
  }

  /// Returns a human-readable label for the occupancy level.
  static String getOccupancyLabel(double occupancyPercentage) {
    if (occupancyPercentage < 50) return 'Available';
    if (occupancyPercentage < 85) return 'Filling Fast';
    return 'Fully Booked';
  }

  // ── Booking ID Generator ──────────────────────────────────────────────

  /// Generates a unique booking ID in the format `GB-YYYYMMDD-XXXXXX`
  /// where `X` is a random alphanumeric character.
  ///
  /// ```dart
  /// Helpers.generateBookingId(); // 'GB-20250405-A3F9K2'
  /// ```
  static String generateBookingId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    final now = DateTime.now();
    final datePart = DateFormat('yyyyMMdd').format(now);
    final randomPart = List.generate(
      6,
      (_) => chars[random.nextInt(chars.length)],
    ).join();
    return 'GB-$datePart-$randomPart';
  }

  // ── Miscellaneous ─────────────────────────────────────────────────────

  /// Validates an email address with a simple regex.
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// Validates that a phone number contains 10 digits (Indian format).
  static bool isValidPhone(String phone) {
    return RegExp(r'^[6-9]\d{9}$').hasMatch(phone.replaceAll(RegExp(r'\D'), ''));
  }

  /// Returns initials from a full name (e.g. "Dhara Thummar" → "DT").
  static String getInitials(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  /// Truncates [text] to [maxLength] characters and appends '...' if needed.
  static String truncate(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }

  /// Calculates the distance label from meters.
  static String formatDistance(double meters) {
    if (meters < 1000) return '${meters.round()} m';
    return '${(meters / 1000).toStringAsFixed(1)} km';
  }

  /// Returns the star-rating label (e.g. "4.5 / 5").
  static String formatRating(double rating, {int maxStars = 5}) {
    return '${rating.toStringAsFixed(1)} / $maxStars';
  }
}
