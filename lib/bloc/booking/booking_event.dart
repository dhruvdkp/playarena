part of 'booking_bloc.dart';

abstract class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object?> get props => [];
}

class BookingCreate extends BookingEvent {
  final BookingModel booking;

  const BookingCreate({required this.booking});

  @override
  List<Object?> get props => [booking];
}

class BookingLoadUser extends BookingEvent {
  final String userId;

  const BookingLoadUser({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class BookingCancel extends BookingEvent {
  final String bookingId;

  const BookingCancel({required this.bookingId});

  @override
  List<Object?> get props => [bookingId];
}

class BookingLoadHistory extends BookingEvent {
  final String userId;

  const BookingLoadHistory({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class BookingSelectSlot extends BookingEvent {
  final SlotModel slot;

  const BookingSelectSlot({required this.slot});

  @override
  List<Object?> get props => [slot];
}

class BookingAddAddOn extends BookingEvent {
  final AddOnModel addOn;

  const BookingAddAddOn({required this.addOn});

  @override
  List<Object?> get props => [addOn];
}

class BookingRemoveAddOn extends BookingEvent {
  final String addOnId;

  const BookingRemoveAddOn({required this.addOnId});

  @override
  List<Object?> get props => [addOnId];
}

class BookingCalculateTotal extends BookingEvent {
  const BookingCalculateTotal();
}
