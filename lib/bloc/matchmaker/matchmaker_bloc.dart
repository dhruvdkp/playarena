import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamebooking/data/models/match_request_model.dart';
import 'package:gamebooking/data/models/venue_model.dart';
import 'package:gamebooking/data/repositories/matchmaker_repository.dart';

part 'matchmaker_event.dart';
part 'matchmaker_state.dart';

class MatchmakerBloc extends Bloc<MatchmakerEvent, MatchmakerState> {
  final MatchmakerRepository _matchmakerRepository;

  MatchmakerBloc({required MatchmakerRepository matchmakerRepository})
      : _matchmakerRepository = matchmakerRepository,
        super(const MatchmakerInitial()) {
    on<MatchmakerLoadMatches>(_onLoadMatches);
    on<MatchmakerCreateRequest>(_onCreateRequest);
    on<MatchmakerJoinMatch>(_onJoinMatch);
    on<MatchmakerFilterBySport>(_onFilterBySport);
  }

  List<MatchRequestModel> _allMatches = [];

  Future<void> _onLoadMatches(
    MatchmakerLoadMatches event,
    Emitter<MatchmakerState> emit,
  ) async {
    emit(const MatchmakerLoading());
    try {
      _allMatches = await _matchmakerRepository.getOpenMatches();
      emit(MatchmakerLoaded(matches: _allMatches));
    } catch (e) {
      emit(MatchmakerError(message: e.toString()));
    }
  }

  Future<void> _onCreateRequest(
    MatchmakerCreateRequest event,
    Emitter<MatchmakerState> emit,
  ) async {
    emit(const MatchmakerLoading());
    try {
      await _matchmakerRepository.createMatchRequest(event.request);
      _allMatches = await _matchmakerRepository.getOpenMatches();
      emit(MatchmakerLoaded(matches: _allMatches));
    } catch (e) {
      emit(MatchmakerError(message: e.toString()));
    }
  }

  Future<void> _onJoinMatch(
    MatchmakerJoinMatch event,
    Emitter<MatchmakerState> emit,
  ) async {
    emit(const MatchmakerLoading());
    try {
      final updatedMatch = await _matchmakerRepository.joinMatch(
        event.matchId,
        event.userId,
      );
      emit(MatchmakerJoined(match: updatedMatch));
    } catch (e) {
      emit(MatchmakerError(message: e.toString()));
    }
  }

  Future<void> _onFilterBySport(
    MatchmakerFilterBySport event,
    Emitter<MatchmakerState> emit,
  ) async {
    emit(const MatchmakerLoading());
    try {
      if (_allMatches.isEmpty) {
        _allMatches = await _matchmakerRepository.getOpenMatches();
      }
      final filtered = _allMatches
          .where((m) => m.sportType == event.sportType)
          .toList();
      emit(MatchmakerLoaded(matches: filtered));
    } catch (e) {
      emit(MatchmakerError(message: e.toString()));
    }
  }
}
