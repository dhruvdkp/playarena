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

    // Mark the slot as unavailable in Firestore
    try {
      await _firestoreService.updateSlotAvailability(
        booking.venueId,
        booking.slot.id,
        false,
      );
    } catch (_) {
      // Slot might not exist in subcollection (e.g., demo data) — ignore
    }

    return booking.copyWith(id: id);
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
    await _firestoreService.cancelBooking(id);
    final data = await _firestoreService.getBookingById(id);
    if (data == null) throw Exception('Booking not found');
    return BookingModel.fromJson(data);
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
