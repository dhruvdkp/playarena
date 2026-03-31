part of 'tournament_bloc.dart';

abstract class TournamentEvent extends Equatable {
  const TournamentEvent();

  @override
  List<Object?> get props => [];
}

class TournamentLoadAll extends TournamentEvent {
  const TournamentLoadAll();
}

class TournamentLoadDetail extends TournamentEvent {
  final String id;

  const TournamentLoadDetail({required this.id});

  @override
  List<Object?> get props => [id];
}

class TournamentRegisterTeam extends TournamentEvent {
  final String tournamentId;
  final String teamId;

  const TournamentRegisterTeam({
    required this.tournamentId,
    required this.teamId,
  });

  @override
  List<Object?> get props => [tournamentId, teamId];
}

class TournamentLoadMatches extends TournamentEvent {
  final String tournamentId;

  const TournamentLoadMatches({required this.tournamentId});

  @override
  List<Object?> get props => [tournamentId];
}
