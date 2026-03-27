import 'package:equatable/equatable.dart';

import 'venue_model.dart';

enum TournamentFormat { knockout, roundRobin, league }

enum TournamentStatus { upcoming, ongoing, completed }

enum MatchStatus { scheduled, live, completed }

class MatchModel extends Equatable {
  final String id;
  final String tournamentId;
  final String team1Id;
  final String team1Name;
  final String team2Id;
  final String team2Name;
  final int? team1Score;
  final int? team2Score;
  final String? winnerId;
  final DateTime matchDate;
  final String matchTime;
  final MatchStatus status;
  final String round;

  const MatchModel({
    required this.id,
    required this.tournamentId,
    required this.team1Id,
    required this.team1Name,
    required this.team2Id,
    required this.team2Name,
    this.team1Score,
    this.team2Score,
    this.winnerId,
    required this.matchDate,
    required this.matchTime,
    required this.status,
    required this.round,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      id: json['id'] as String,
      tournamentId: json['tournamentId'] as String,
      team1Id: json['team1Id'] as String,
      team1Name: json['team1Name'] as String,
      team2Id: json['team2Id'] as String,
      team2Name: json['team2Name'] as String,
      team1Score: json['team1Score'] as int?,
      team2Score: json['team2Score'] as int?,
      winnerId: json['winnerId'] as String?,
      matchDate: DateTime.parse(json['matchDate'] as String),
      matchTime: json['matchTime'] as String,
      status: MatchStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => MatchStatus.scheduled,
      ),
      round: json['round'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tournamentId': tournamentId,
      'team1Id': team1Id,
      'team1Name': team1Name,
      'team2Id': team2Id,
      'team2Name': team2Name,
      'team1Score': team1Score,
      'team2Score': team2Score,
      'winnerId': winnerId,
      'matchDate': matchDate.toIso8601String(),
      'matchTime': matchTime,
      'status': status.name,
      'round': round,
    };
  }

  MatchModel copyWith({
    String? id,
    String? tournamentId,
    String? team1Id,
    String? team1Name,
    String? team2Id,
    String? team2Name,
    int? team1Score,
    int? team2Score,
    String? winnerId,
    DateTime? matchDate,
    String? matchTime,
    MatchStatus? status,
    String? round,
  }) {
    return MatchModel(
      id: id ?? this.id,
      tournamentId: tournamentId ?? this.tournamentId,
      team1Id: team1Id ?? this.team1Id,
      team1Name: team1Name ?? this.team1Name,
      team2Id: team2Id ?? this.team2Id,
      team2Name: team2Name ?? this.team2Name,
      team1Score: team1Score ?? this.team1Score,
      team2Score: team2Score ?? this.team2Score,
      winnerId: winnerId ?? this.winnerId,
      matchDate: matchDate ?? this.matchDate,
      matchTime: matchTime ?? this.matchTime,
      status: status ?? this.status,
      round: round ?? this.round,
    );
  }

  @override
  List<Object?> get props => [
        id,
        tournamentId,
        team1Id,
        team1Name,
        team2Id,
        team2Name,
        team1Score,
        team2Score,
        winnerId,
        matchDate,
        matchTime,
        status,
        round,
      ];
}

class TournamentModel extends Equatable {
  final String id;
  final String name;
  final SportType sportType;
  final String venueId;
  final String venueName;
  final TournamentFormat format;
  final DateTime startDate;
  final DateTime endDate;
  final double entryFee;
  final double prizePool;
  final int maxTeams;
  final List<String> registeredTeams;
  final List<MatchModel> matches;
  final TournamentStatus status;
  final String rules;

  const TournamentModel({
    required this.id,
    required this.name,
    required this.sportType,
    required this.venueId,
    required this.venueName,
    required this.format,
    required this.startDate,
    required this.endDate,
    required this.entryFee,
    required this.prizePool,
    required this.maxTeams,
    required this.registeredTeams,
    required this.matches,
    required this.status,
    required this.rules,
  });

  factory TournamentModel.fromJson(Map<String, dynamic> json) {
    return TournamentModel(
      id: json['id'] as String,
      name: json['name'] as String,
      sportType: SportType.values.firstWhere(
        (e) => e.name == json['sportType'],
        orElse: () => SportType.boxCricket,
      ),
      venueId: json['venueId'] as String,
      venueName: json['venueName'] as String,
      format: TournamentFormat.values.firstWhere(
        (e) => e.name == json['format'],
        orElse: () => TournamentFormat.knockout,
      ),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      entryFee: (json['entryFee'] as num).toDouble(),
      prizePool: (json['prizePool'] as num).toDouble(),
      maxTeams: json['maxTeams'] as int,
      registeredTeams: List<String>.from(json['registeredTeams'] ?? []),
      matches: (json['matches'] as List<dynamic>?)
              ?.map((e) => MatchModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      status: TournamentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TournamentStatus.upcoming,
      ),
      rules: json['rules'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sportType': sportType.name,
      'venueId': venueId,
      'venueName': venueName,
      'format': format.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'entryFee': entryFee,
      'prizePool': prizePool,
      'maxTeams': maxTeams,
      'registeredTeams': registeredTeams,
      'matches': matches.map((e) => e.toJson()).toList(),
      'status': status.name,
      'rules': rules,
    };
  }

  TournamentModel copyWith({
    String? id,
    String? name,
    SportType? sportType,
    String? venueId,
    String? venueName,
    TournamentFormat? format,
    DateTime? startDate,
    DateTime? endDate,
    double? entryFee,
    double? prizePool,
    int? maxTeams,
    List<String>? registeredTeams,
    List<MatchModel>? matches,
    TournamentStatus? status,
    String? rules,
  }) {
    return TournamentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      sportType: sportType ?? this.sportType,
      venueId: venueId ?? this.venueId,
      venueName: venueName ?? this.venueName,
      format: format ?? this.format,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      entryFee: entryFee ?? this.entryFee,
      prizePool: prizePool ?? this.prizePool,
      maxTeams: maxTeams ?? this.maxTeams,
      registeredTeams: registeredTeams ?? this.registeredTeams,
      matches: matches ?? this.matches,
      status: status ?? this.status,
      rules: rules ?? this.rules,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        sportType,
        venueId,
        venueName,
        format,
        startDate,
        endDate,
        entryFee,
        prizePool,
        maxTeams,
        registeredTeams,
        matches,
        status,
        rules,
      ];
}
