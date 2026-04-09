import 'package:gamebooking/data/models/booking_model.dart';
import 'package:gamebooking/data/services/firestore_service.dart';

class BookingRepository {
  final FirestoreService _firestoreService;

  BookingRepository({required FirestoreService firestoreService})
      : _firestoreService = firestoreService;

  Future<BookingModel> createBooking(BookingModel booking) async {
    final json = booking.toJson();
    json.remove('id');
    final id = await _firestoreService.createBooking(json);

    // Mark the slot as booked by this user (records bookedBy + bookingId).
    // If the slot document doesn't exist (demo data), don't fail the booking
    // — but log other errors so real issues aren't hidden.
    try {
      await _firestoreService.markSlotBooked(
        booking.venueId,
        booking.slot.id,
        booking.userId,
        id,
      );
    } catch (e) {
      // ignore: avoid_print
      print('[BookingRepository] markSlotBooked failed: $e');
    }

    return booking.copyWith(
      id: id,
      slot: booking.slot.copyWith(
        isAvailable: false,
        bookedBy: booking.userId,
      ),
    );
  }

  Future<List<BookingModel>> getUserBookings(String userId) async {
    final data = await _firestoreService.getUserBookings(userId);
    return data.map((json) => BookingModel.fromJson(json)).toList();
  }

  Future<BookingModel?> getBookingById(String id) async {
    final data = await _firestoreService.getBookingById(id);
    if (data == null) return null;
    return BookingModel.fromJson(data);
  }

  Future<BookingModel> cancelBooking(String id) async {
    // Load first so we know which slot to release.
    final existing = await _firestoreService.getBookingById(id);
    if (existing == null) throw Exception('Booking not found');
    final booking = BookingModel.fromJson(existing);

    await _firestoreService.cancelBooking(id);

    // Release the slot back to available so others can book it.
    try {
      await _firestoreService.releaseSlot(booking.venueId, booking.slot.id);
    } catch (e) {
      // ignore: avoid_print
      print('[BookingRepository] releaseSlot failed: $e');
    }

    final updated = await _firestoreService.getBookingById(id);
    return BookingModel.fromJson(updated!);
  }

  Future<List<BookingModel>> getBookingHistory(String userId) async {
    final bookings = await getUserBookings(userId);
    return bookings
        .where((b) =>
            b.bookingStatus == BookingStatus.completed ||
            b.bookingStatus == BookingStatus.cancelled)
        .toList();
  }
}
