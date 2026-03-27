import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamebooking/data/models/tournament_model.dart';
import 'package:gamebooking/data/repositories/tournament_repository.dart';

part 'tournament_event.dart';
part 'tournament_state.dart';

class TournamentBloc extends Bloc<TournamentEvent, TournamentState> {
  final TournamentRepository _tournamentRepository;

  TournamentBloc({required TournamentRepository tournamentRepository})
      : _tournamentRepository = tournamentRepository,
        super(const TournamentInitial()) {
    on<TournamentLoadAll>(_onLoadAll);
    on<TournamentLoadDetail>(_onLoadDetail);
    on<TournamentRegisterTeam>(_onRegisterTeam);
    on<TournamentLoadMatches>(_onLoadMatches);
  }

  Future<void> _onLoadAll(
    TournamentLoadAll event,
    Emitter<TournamentState> emit,
  ) async {
    emit(const TournamentLoading());
    try {
      final tournaments = await _tournamentRepository.getTournaments();
      emit(TournamentListLoaded(tournaments: tournaments));
    } catch (e) {
      emit(TournamentError(message: e.toString()));
    }
  }

  Future<void> _onLoadDetail(
    TournamentLoadDetail event,
    Emitter<TournamentState> emit,
  ) async {
    emit(const TournamentLoading());
    try {
      final tournament =
          await _tournamentRepository.getTournamentById(event.id);
      if (tournament == null) {
        emit(const TournamentError(message: 'Tournament not found'));
        return;
      }
      final matches =
          await _tournamentRepository.getTournamentMatches(event.id);
      emit(TournamentDetailLoaded(
        tournament: tournament,
        matches: matches,
      ));
    } catch (e) {
      emit(TournamentError(message: e.toString()));
    }
  }

  Future<void> _onRegisterTeam(
    TournamentRegisterTeam event,
    Emitter<TournamentState> emit,
  ) async {
    emit(const TournamentLoading());
    try {
      await _tournamentRepository.registerTeam(
        event.tournamentId,
        event.teamId,
      );
      emit(const TournamentRegistered());
    } catch (e) {
      emit(TournamentError(message: e.toString()));
    }
  }

  Future<void> _onLoadMatches(
    TournamentLoadMatches event,
    Emitter<TournamentState> emit,
  ) async {
    emit(const TournamentLoading());
    try {
      final matches = await _tournamentRepository
          .getTournamentMatches(event.tournamentId);

      final currentState = state;
      if (currentState is TournamentDetailLoaded) {
        emit(TournamentDetailLoaded(
          tournament: currentState.tournament,
          matches: matches,
        ));
      } else {
        final tournament = await _tournamentRepository
            .getTournamentById(event.tournamentId);
        if (tournament == null) {
          emit(const TournamentError(message: 'Tournament not found'));
          return;
        }
        emit(TournamentDetailLoaded(
          tournament: tournament,
          matches: matches,
        ));
      }
    } catch (e) {
      emit(TournamentError(message: e.toString()));
    }
  }
}
