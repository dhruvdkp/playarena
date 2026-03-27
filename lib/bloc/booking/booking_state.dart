part of 'booking_bloc.dart';

abstract class BookingState extends Equatable {
  const BookingState();

  @override
  List<Object?> get props => [];
}

class BookingInitial extends BookingState {
  const BookingInitial();
}

class BookingLoading extends BookingState {
  const BookingLoading();
}

class BookingCreated extends BookingState {
  final BookingModel booking;

  const BookingCreated({required this.booking});

  @override
  List<Object?> get props => [booking];
}

class BookingListLoaded extends BookingState {
  final List<BookingModel> bookings;

  const BookingListLoaded({required this.bookings});

  @override
  List<Object?> get props => [bookings];
}

class BookingInProgress extends BookingState {
  final SlotModel? selectedSlot;
  final List<AddOnModel> addOns;
  final double totalAmount;

  const BookingInProgress({
    this.selectedSlot,
    required this.addOns,
    required this.totalAmount,
  });

  @override
  List<Object?> get props => [selectedSlot, addOns, totalAmount];
}

class BookingError extends BookingState {
  final String message;

  const BookingError({required this.message});

  @override
  List<Object?> get props => [message];
}

class BookingCancelled extends BookingState {
  const BookingCancelled();
}
