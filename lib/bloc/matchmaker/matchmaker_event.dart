part of 'matchmaker_bloc.dart';

abstract class MatchmakerEvent extends Equatable {
  const MatchmakerEvent();

  @override
  List<Object?> get props => [];
}

/// Subscribe to the live open-matches stream. The bloc opens a Firestore
/// snapshot listener; new matches, joins, leaves, and status flips arrive
/// automatically as `MatchmakerSnapshotReceived` events.
///
/// Re-dispatching is safe — the bloc cancels any prior subscription first.
class MatchmakerSubscribe extends MatchmakerEvent {
  const MatchmakerSubscribe();
}

/// Internal event fired by the stream subscription on each snapshot.
class MatchmakerSnapshotReceived extends MatchmakerEvent {
  final List<MatchRequestModel>? matches;
  final String? error;

  const MatchmakerSnapshotReceived(this.matches) : error = null;
  const MatchmakerSnapshotReceived.error(this.error) : matches = null;

  @override
  List<Object?> get props => [matches, error];
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

class MatchmakerLeaveMatch extends MatchmakerEvent {
  final String matchId;
  final String userId;

  const MatchmakerLeaveMatch({
    required this.matchId,
    required this.userId,
  });

  @override
  List<Object?> get props => [matchId, userId];
}

/// Pass [sportType] = null to clear the filter.
class MatchmakerFilterBySport extends MatchmakerEvent {
  final SportType? sportType;

  const MatchmakerFilterBySport({this.sportType});

  @override
  List<Object?> get props => [sportType];
}
