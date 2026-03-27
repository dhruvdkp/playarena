part of 'venue_bloc.dart';

abstract class VenueEvent extends Equatable {
  const VenueEvent();

  @override
  List<Object?> get props => [];
}

class VenueLoadAll extends VenueEvent {
  const VenueLoadAll();
}

class VenueSearch extends VenueEvent {
  final String query;

  const VenueSearch({required this.query});

  @override
  List<Object?> get props => [query];
}

class VenueFilterBySport extends VenueEvent {
  final SportType sportType;

  const VenueFilterBySport({required this.sportType});

  @override
  List<Object?> get props => [sportType];
}

class VenueLoadDetail extends VenueEvent {
  final String venueId;

  const VenueLoadDetail({required this.venueId});

  @override
  List<Object?> get props => [venueId];
}

class VenueLoadSlots extends VenueEvent {
  final String venueId;
  final DateTime date;

  const VenueLoadSlots({required this.venueId, required this.date});

  @override
  List<Object?> get props => [venueId, date];
}

class VenueLoadReviews extends VenueEvent {
  final String venueId;

  const VenueLoadReviews({required this.venueId});

  @override
  List<Object?> get props => [venueId];
}

class VenueAddReview extends VenueEvent {
  final ReviewModel review;

  const VenueAddReview({required this.review});

  @override
  List<Object?> get props => [review];
}
