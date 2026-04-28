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
  final SportType? sportFilter;
  final String? submittingMatchId;

  const MatchmakerLoaded({
    required this.matches,
    this.sportFilter,
    this.submittingMatchId,
  });

  MatchmakerLoaded copyWith({
    List<MatchRequestModel>? matches,
    SportType? sportFilter,
    bool clearSportFilter = false,
    String? submittingMatchId,
    bool clearSubmittingMatchId = false,
  }) {
    return MatchmakerLoaded(
      matches: matches ?? this.matches,
      sportFilter:
          clearSportFilter ? null : (sportFilter ?? this.sportFilter),
      submittingMatchId: clearSubmittingMatchId
          ? null
          : (submittingMatchId ?? this.submittingMatchId),
    );
  }

  @override
  List<Object?> get props => [matches, sportFilter, submittingMatchId];
}

class MatchmakerError extends MatchmakerState {
  final String message;

  const MatchmakerError({required this.message});

  @override
  List<Object?> get props => [message];
}
