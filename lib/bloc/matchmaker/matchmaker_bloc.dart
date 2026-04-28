import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamebooking/data/models/match_request_model.dart';
import 'package:gamebooking/data/models/venue_model.dart';
import 'package:gamebooking/data/repositories/matchmaker_repository.dart';

part 'matchmaker_event.dart';
part 'matchmaker_state.dart';

class MatchmakerBloc extends Bloc<MatchmakerEvent, MatchmakerState> {
  final MatchmakerRepository _matchmakerRepository;
  StreamSubscription<List<MatchRequestModel>>? _subscription;

  MatchmakerBloc({required MatchmakerRepository matchmakerRepository})
      : _matchmakerRepository = matchmakerRepository,
        super(const MatchmakerInitial()) {
    on<MatchmakerSubscribe>(_onSubscribe);
    on<MatchmakerSnapshotReceived>(_onSnapshotReceived);
    on<MatchmakerCreateRequest>(_onCreateRequest);
    on<MatchmakerJoinMatch>(_onJoinMatch);
    on<MatchmakerLeaveMatch>(_onLeaveMatch);
    on<MatchmakerFilterBySport>(_onFilterBySport);
  }

  // ── Loaded-state helpers ───────────────────────────────────────────────

  /// Returns the current `MatchmakerLoaded` or `null` if the bloc is not yet
  /// in the loaded state. Used by handlers that want to apply an optimistic
  /// update without blanking the screen with a `Loading` emit.
  MatchmakerLoaded? get _current =>
      state is MatchmakerLoaded ? state as MatchmakerLoaded : null;

  // ── Event handlers ─────────────────────────────────────────────────────

  Future<void> _onSubscribe(
    MatchmakerSubscribe event,
    Emitter<MatchmakerState> emit,
  ) async {
    await _subscription?.cancel();
    if (_current == null) emit(const MatchmakerLoading());
    _subscription =
        _matchmakerRepository.openMatchesLiveStream().listen(
      (matches) => add(MatchmakerSnapshotReceived(matches)),
      onError: (Object e) =>
          add(MatchmakerSnapshotReceived.error(e.toString())),
    );
  }

  void _onSnapshotReceived(
    MatchmakerSnapshotReceived event,
    Emitter<MatchmakerState> emit,
  ) {
    if (event.error != null) {
      emit(MatchmakerError(message: event.error!));
      return;
    }
    emit(MatchmakerLoaded(
      matches: event.matches ?? const [],
      sportFilter: _current?.sportFilter,
      submittingMatchId: _current?.submittingMatchId,
    ));
  }

  Future<void> _onCreateRequest(
    MatchmakerCreateRequest event,
    Emitter<MatchmakerState> emit,
  ) async {
    try {
      final created =
          await _matchmakerRepository.createMatchRequest(event.request);
      // If we're already in a Loaded state, prepend the new match so the
      // user sees it immediately. If we later add a live stream (Phase C),
      // this prepend is harmless because the stream will resolve duplicates
      // by id on the next snapshot.
      final current = _current;
      if (current != null) {
        emit(current.copyWith(matches: [created, ...current.matches]));
      } else {
        emit(MatchmakerLoaded(matches: [created]));
      }
    } catch (e) {
      emit(MatchmakerError(message: e.toString()));
      // Restore the prior list so the error SnackBar doesn't leave the screen
      // stuck on the error state.
      if (_current != null) emit(_current!);
    }
  }

  Future<void> _onJoinMatch(
    MatchmakerJoinMatch event,
    Emitter<MatchmakerState> emit,
  ) async {
    final current = _current;
    if (current == null) return;
    emit(current.copyWith(submittingMatchId: event.matchId));
    try {
      final updated = await _matchmakerRepository.joinMatch(
        event.matchId,
        event.userId,
      );
      final newList = current.matches
          .map((m) => m.id == updated.id ? updated : m)
          .toList();
      emit(current.copyWith(
        matches: newList,
        clearSubmittingMatchId: true,
      ));
    } catch (e) {
      emit(MatchmakerError(message: e.toString()));
      emit(current.copyWith(clearSubmittingMatchId: true));
    }
  }

  Future<void> _onLeaveMatch(
    MatchmakerLeaveMatch event,
    Emitter<MatchmakerState> emit,
  ) async {
    final current = _current;
    if (current == null) return;
    emit(current.copyWith(submittingMatchId: event.matchId));
    try {
      final updated = await _matchmakerRepository.leaveMatch(
        event.matchId,
        event.userId,
      );
      final newList = current.matches
          .map((m) => m.id == updated.id ? updated : m)
          .toList();
      emit(current.copyWith(
        matches: newList,
        clearSubmittingMatchId: true,
      ));
    } catch (e) {
      emit(MatchmakerError(message: e.toString()));
      emit(current.copyWith(clearSubmittingMatchId: true));
    }
  }

  void _onFilterBySport(
    MatchmakerFilterBySport event,
    Emitter<MatchmakerState> emit,
  ) {
    final current = _current;
    if (current == null) return;
    emit(current.copyWith(
      sportFilter: event.sportType,
      clearSportFilter: event.sportType == null,
    ));
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
