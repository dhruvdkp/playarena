import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamebooking/data/models/review_model.dart';
import 'package:gamebooking/data/models/slot_model.dart';
import 'package:gamebooking/data/models/venue_model.dart';
import 'package:gamebooking/data/repositories/venue_repository.dart';

part 'venue_event.dart';
part 'venue_state.dart';

class VenueBloc extends Bloc<VenueEvent, VenueState> {
  final VenueRepository _venueRepository;

  VenueModel? _currentVenue;
  List<SlotModel> _currentSlots = [];
  List<ReviewModel> _currentReviews = [];
  List<DateTime> _currentAvailableDates = [];

  VenueBloc({required VenueRepository venueRepository})
      : _venueRepository = venueRepository,
        super(const VenueInitial()) {
    on<VenueLoadAll>(_onLoadAll);
    on<VenueSearch>(_onSearch);
    on<VenueFilterBySport>(_onFilterBySport);
    on<VenueLoadDetail>(_onLoadDetail);
    on<VenueLoadSlots>(_onLoadSlots);
    on<VenueLoadReviews>(_onLoadReviews);
    on<VenueAddReview>(_onAddReview);
  }

  Future<void> _onLoadAll(
    VenueLoadAll event,
    Emitter<VenueState> emit,
  ) async {
    emit(const VenueLoading());
    try {
      final venues = await _venueRepository.getVenues();
      emit(VenueLoaded(venues: venues));
    } catch (e) {
      emit(VenueError(message: e.toString()));
    }
  }

  Future<void> _onSearch(
    VenueSearch event,
    Emitter<VenueState> emit,
  ) async {
    emit(const VenueLoading());
    try {
      final venues = await _venueRepository.searchVenues(event.query);
      emit(VenueLoaded(venues: venues));
    } catch (e) {
      emit(VenueError(message: e.toString()));
    }
  }

  Future<void> _onFilterBySport(
    VenueFilterBySport event,
    Emitter<VenueState> emit,
  ) async {
    emit(const VenueLoading());
    try {
      final venues = await _venueRepository.filterBySport(event.sportType);
      emit(VenueLoaded(venues: venues));
    } catch (e) {
      emit(VenueError(message: e.toString()));
    }
  }

  Future<void> _onLoadDetail(
    VenueLoadDetail event,
    Emitter<VenueState> emit,
  ) async {
    emit(const VenueLoading());
    try {
      final venue = await _venueRepository.getVenueById(event.venueId);
      if (venue == null) {
        emit(const VenueError(message: 'Venue not found'));
        return;
      }
      final dates =
          await _venueRepository.getAvailableSlotDates(event.venueId);
      final initialDate = dates.isNotEmpty ? dates.first : DateTime.now();
      final slots = await _venueRepository.getVenueSlots(
        event.venueId,
        initialDate,
      );
      final reviews = await _venueRepository.getVenueReviews(event.venueId);

      _currentVenue = venue;
      _currentSlots = slots;
      _currentReviews = reviews;
      _currentAvailableDates = dates;

      emit(VenueDetailLoaded(
        venue: venue,
        slots: slots,
        reviews: reviews,
        availableDates: dates,
      ));
    } catch (e) {
      emit(VenueError(message: e.toString()));
    }
  }

  Future<void> _onLoadSlots(
    VenueLoadSlots event,
    Emitter<VenueState> emit,
  ) async {
    // Don't emit Loading — would blank the venue detail page and reset
    // scroll. Just fetch + emit the new Loaded state.
    try {
      final slots = await _venueRepository.getVenueSlots(
        event.venueId,
        event.date,
      );
      _currentSlots = slots;

      if (_currentVenue != null) {
        emit(VenueDetailLoaded(
          venue: _currentVenue!,
          slots: _currentSlots,
          reviews: _currentReviews,
          availableDates: _currentAvailableDates,
        ));
      }
    } catch (e) {
      emit(VenueError(message: e.toString()));
    }
  }

  Future<void> _onLoadReviews(
    VenueLoadReviews event,
    Emitter<VenueState> emit,
  ) async {
    emit(const VenueLoading());
    try {
      final reviews = await _venueRepository.getVenueReviews(event.venueId);
      _currentReviews = reviews;

      if (_currentVenue != null) {
        emit(VenueDetailLoaded(
          venue: _currentVenue!,
          slots: _currentSlots,
          reviews: _currentReviews,
          availableDates: _currentAvailableDates,
        ));
      }
    } catch (e) {
      emit(VenueError(message: e.toString()));
    }
  }

  Future<void> _onAddReview(
    VenueAddReview event,
    Emitter<VenueState> emit,
  ) async {
    emit(const VenueLoading());
    try {
      final newReview = await _venueRepository.addReview(event.review);
      _currentReviews = [..._currentReviews, newReview];

      if (_currentVenue != null) {
        emit(VenueDetailLoaded(
          venue: _currentVenue!,
          slots: _currentSlots,
          reviews: _currentReviews,
          availableDates: _currentAvailableDates,
        ));
      }
    } catch (e) {
      emit(VenueError(message: e.toString()));
    }
  }
}
