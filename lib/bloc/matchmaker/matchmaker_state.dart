part of 'matchmaker_bloc.dart';

abstract class MatchmakerState extends Equatable {
  const MatchmakerState();

  @override
  List<Object?> get props => [];
}

class MatchmakerInitial extends MatchmakerState {
  const MatchmakerInitial();
}

class MatchmakerLoading extends MatchmakerState {
  const MatchmakerLoading();
}

class MatchmakerLoaded extends MatchmakerState {
  final List<MatchRequestModel> matches;

  const MatchmakerLoaded({required this.matches});

  @override
  List<Object?> get props => [matches];
}

class MatchmakerJoined extends MatchmakerState {
  final MatchRequestModel match;

  const MatchmakerJoined({required this.match});

  @override
  List<Object?> get props => [match];
}

class MatchmakerError extends MatchmakerState {
  final String message;

  const MatchmakerError({required this.message});

  @override
  List<Object?> get props => [message];
}
