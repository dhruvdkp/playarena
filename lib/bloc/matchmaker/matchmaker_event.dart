part of 'matchmaker_bloc.dart';

abstract class MatchmakerEvent extends Equatable {
  const MatchmakerEvent();

  @override
  List<Object?> get props => [];
}

class MatchmakerLoadMatches extends MatchmakerEvent {
  const MatchmakerLoadMatches();
}

class MatchmakerCreateRequest extends MatchmakerEvent {
  final MatchRequestModel request;

  const MatchmakerCreateRequest({required this.request});

  @override
  List<Object?> get props => [request];
}

class MatchmakerJoinMatch extends MatchmakerEvent {
  final String matchId;
  final String userId;

  const MatchmakerJoinMatch({
    required this.matchId,
    required this.userId,
  });

  @override
  List<Object?> get props => [matchId, userId];
}

class MatchmakerFilterBySport extends MatchmakerEvent {
  final SportType sportType;

  const MatchmakerFilterBySport({required this.sportType});

  @override
  List<Object?> get props => [sportType];
}
