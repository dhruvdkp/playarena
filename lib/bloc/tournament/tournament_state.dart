part of 'tournament_bloc.dart';

abstract class TournamentState extends Equatable {
  const TournamentState();

  @override
  List<Object?> get props => [];
}

class TournamentInitial extends TournamentState {
  const TournamentInitial();
}

class TournamentLoading extends TournamentState {
  const TournamentLoading();
}

class TournamentListLoaded extends TournamentState {
  final List<TournamentModel> tournaments;

  const TournamentListLoaded({required this.tournaments});

  @override
  List<Object?> get props => [tournaments];
}

class TournamentDetailLoaded extends TournamentState {
  final TournamentModel tournament;
  final List<MatchModel> matches;

  const TournamentDetailLoaded({
    required this.tournament,
    required this.matches,
  });

  @override
  List<Object?> get props => [tournament, matches];
}

class TournamentRegistered extends TournamentState {
  const TournamentRegistered();
}

class TournamentError extends TournamentState {
  final String message;

  const TournamentError({required this.message});

  @override
  List<Object?> get props => [message];
}
