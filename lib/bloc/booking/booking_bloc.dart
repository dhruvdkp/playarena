import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamebooking/data/models/add_on_model.dart';
import 'package:gamebooking/data/models/booking_model.dart';
import 'package:gamebooking/data/models/slot_model.dart';
import 'package:gamebooking/data/repositories/booking_repository.dart';

part 'booking_event.dart';
part 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final BookingRepository _bookingRepository;

  SlotModel? _selectedSlot;
  List<AddOnModel> _addOns = [];
  double _totalAmount = 0.0;

  BookingBloc({required BookingRepository bookingRepository})
      : _bookingRepository = bookingRepository,
        super(const BookingInitial()) {
    on<BookingCreate>(_onCreateBooking);
    on<BookingLoadUser>(_onLoadUserBookings);
    on<BookingCancel>(_onCancelBooking);
    on<BookingLoadHistory>(_onLoadHistory);
    on<BookingSelectSlot>(_onSelectSlot);
    on<BookingAddAddOn>(_onAddAddOn);
    on<BookingRemoveAddOn>(_onRemoveAddOn);
    on<BookingCalculateTotal>(_onCalculateTotal);
  }

  Future<void> _onCreateBooking(
    BookingCreate event,
    Emitter<BookingState> emit,
  ) async {
    emit(const BookingLoading());
    try {
      // ── BYPASSED PAYMENT GATEWAY (test mode) ──────────────────────────
      // Real payment integration (Razorpay/Stripe) is not yet wired up.
      // For now we simulate a short processing delay and treat every
      // booking as paid. The booking is persisted with paymentStatus =
      // completed by the caller (booking_screen.dart).
      await Future.delayed(const Duration(milliseconds: 1500));

      // Force payment status to completed regardless of what the caller
      // sent — guarantees the bypass works even if a screen forgets it.
      final paidBooking = event.booking.copyWith(
        paymentStatus: PaymentStatus.completed,
        bookingStatus: BookingStatus.upcoming,
      );

      final booking = await _bookingRepository.createBooking(paidBooking);
      _resetInProgressState();
      emit(BookingCreated(booking: booking));
    } catch (e) {
      emit(BookingError(message: e.toString()));
    }
  }

  Future<void> _onLoadUserBookings(
    BookingLoadUser event,
    Emitter<BookingState> emit,
  ) async {
    emit(const BookingLoading());
    try {
      final bookings = await _bookingRepository.getUserBookings(event.userId);
      emit(BookingListLoaded(bookings: bookings));
    } catch (e) {
      emit(BookingError(message: e.toString()));
    }
  }

  Future<void> _onCancelBooking(
    BookingCancel event,
    Emitter<BookingState> emit,
  ) async {
    emit(const BookingLoading());
    try {
      await _bookingRepository.cancelBooking(event.bookingId);
      emit(const BookingCancelled());
    } catch (e) {
      emit(BookingError(message: e.toString()));
    }
  }

  Future<void> _onLoadHistory(
    BookingLoadHistory event,
    Emitter<BookingState> emit,
  ) async {
    emit(const BookingLoading());
    try {
      final bookings =
          await _bookingRepository.getBookingHistory(event.userId);
      emit(BookingListLoaded(bookings: bookings));
    } catch (e) {
      emit(BookingError(message: e.toString()));
    }
  }

  Future<void> _onSelectSlot(
    BookingSelectSlot event,
    Emitter<BookingState> emit,
  ) async {
    _selectedSlot = event.slot;
    _calculateTotal();
    emit(BookingInProgress(
      selectedSlot: _selectedSlot,
      addOns: List.unmodifiable(_addOns),
      totalAmount: _totalAmount,
    ));
  }

  Future<void> _onAddAddOn(
    BookingAddAddOn event,
    Emitter<BookingState> emit,
  ) async {
    final alreadyExists = _addOns.any((a) => a.id == event.addOn.id);
    if (!alreadyExists) {
      _addOns = [..._addOns, event.addOn];
      _calculateTotal();
    }
    emit(BookingInProgress(
      selectedSlot: _selectedSlot,
      addOns: List.unmodifiable(_addOns),
      totalAmount: _totalAmount,
    ));
  }

  Future<void> _onRemoveAddOn(
    BookingRemoveAddOn event,
    Emitter<BookingState> emit,
  ) async {
    _addOns = _addOns.where((a) => a.id != event.addOnId).toList();
    _calculateTotal();
    emit(BookingInProgress(
      selectedSlot: _selectedSlot,
      addOns: List.unmodifiable(_addOns),
      totalAmount: _totalAmount,
    ));
  }

  Future<void> _onCalculateTotal(
    BookingCalculateTotal event,
    Emitter<BookingState> emit,
  ) async {
    _calculateTotal();
    emit(BookingInProgress(
      selectedSlot: _selectedSlot,
      addOns: List.unmodifiable(_addOns),
      totalAmount: _totalAmount,
    ));
  }

  void _calculateTotal() {
    double slotPrice = _selectedSlot?.price ?? 0.0;
    double addOnsTotal = _addOns.fold(0.0, (sum, addOn) => sum + addOn.price);
    _totalAmount = slotPrice + addOnsTotal;
  }

  void _resetInProgressState() {
    _selectedSlot = null;
    _addOns = [];
    _totalAmount = 0.0;
  }
}
