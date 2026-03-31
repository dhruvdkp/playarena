part of 'venue_bloc.dart';

abstract class VenueState extends Equatable {
  const VenueState();

  @override
  List<Object?> get props => [];
}

class VenueInitial extends VenueState {
  const VenueInitial();
}

class VenueLoading extends VenueState {
  const VenueLoading();
}

class VenueLoaded extends VenueState {
  final List<VenueModel> venues;

  const VenueLoaded({required this.venues});

  @override
  List<Object?> get props => [venues];
}

class VenueDetailLoaded extends VenueState {
  final VenueModel venue;
  final List<SlotModel> slots;
  final List<ReviewModel> reviews;

  const VenueDetailLoaded({
    required this.venue,
    required this.slots,
    required this.reviews,
  });

  @override
  List<Object?> get props => [venue, slots, reviews];
}

class VenueError extends VenueState {
  final String message;

  const VenueError({required this.message});

  @override
  List<Object?> get props => [message];
}
