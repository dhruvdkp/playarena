import 'package:equatable/equatable.dart';
import 'package:gamebooking/data/models/venue_model.dart';

enum MatchStatus { open, full, inProgress, completed, cancelled }

enum SkillLevel { beginner, intermediate, advanced, professional }

class MatchModel extends Equatable {
  final String id;
  final String createdByUserId;
  final String createdByUserName;
  final String venueId;
  final String venueName;
  final SportType sportType;
  final DateTime matchDate;
  final String startTime;
  final String endTime;
  final int maxPlayers;
  final int currentPlayers;
  final List<String> playerIds;
  final SkillLevel requiredSkillLevel;
  final double costPerPlayer;
  final MatchStatus status;
  final String? notes;
  final DateTime createdAt;

  const MatchModel({
    required this.id,
    required this.createdByUserId,
    required this.createdByUserName,
    required this.venueId,
    required this.venueName,
    required this.sportType,
    required this.matchDate,
    required this.startTime,
    required this.endTime,
    required this.maxPlayers,
    required this.currentPlayers,
    required this.playerIds,
    required this.requiredSkillLevel,
    required this.costPerPlayer,
    required this.status,
    this.notes,
    required this.createdAt,
  });

  factory MatchModel.fromJson(Map<String, dynamic> json) {
    return MatchModel(
      id: json['id'] as String,
      createdByUserId: json['createdByUserId'] as String,
      createdByUserName: json['createdByUserName'] as String,
      venueId: json['venueId'] as String,
      venueName: json['venueName'] as String,
      sportType: SportType.values.firstWhere(
        (e) => e.name == json['sportType'],
        orElse: () => SportType.football,
      ),
      matchDate: DateTime.parse(json['matchDate'] as String),
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      maxPlayers: json['maxPlayers'] as int,
      currentPlayers: json['currentPlayers'] as int? ?? 0,
      playerIds: List<String>.from(json['playerIds'] ?? []),
      requiredSkillLevel: SkillLevel.values.firstWhere(
        (e) => e.name == json['requiredSkillLevel'],
        orElse: () => SkillLevel.beginner,
      ),
      costPerPlayer: (json['costPerPlayer'] as num).toDouble(),
      status: MatchStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => MatchStatus.open,
      ),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdByUserId': createdByUserId,
      'createdByUserName': createdByUserName,
      'venueId': venueId,
      'venueName': venueName,
      'sportType': sportType.name,
      'matchDate': matchDate.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'maxPlayers': maxPlayers,
      'currentPlayers': currentPlayers,
      'playerIds': playerIds,
      'requiredSkillLevel': requiredSkillLevel.name,
      'costPerPlayer': costPerPlayer,
      'status': status.name,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  MatchModel copyWith({
    String? id,
    String? createdByUserId,
    String? createdByUserName,
    String? venueId,
    String? venueName,
    SportType? sportType,
    DateTime? matchDate,
    String? startTime,
    String? endTime,
    int? maxPlayers,
    int? currentPlayers,
    List<String>? playerIds,
    SkillLevel? requiredSkillLevel,
    double? costPerPlayer,
    MatchStatus? status,
    String? notes,
    DateTime? createdAt,
  }) {
    return MatchModel(
      id: id ?? this.id,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      createdByUserName: createdByUserName ?? this.createdByUserName,
      venueId: venueId ?? this.venueId,
      venueName: venueName ?? this.venueName,
      sportType: sportType ?? this.sportType,
      matchDate: matchDate ?? this.matchDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      maxPlayers: maxPlayers ?? this.maxPlayers,
      currentPlayers: currentPlayers ?? this.currentPlayers,
      playerIds: playerIds ?? this.playerIds,
      requiredSkillLevel: requiredSkillLevel ?? this.requiredSkillLevel,
      costPerPlayer: costPerPlayer ?? this.costPerPlayer,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id, createdByUserId, createdByUserName, venueId, venueName,
        sportType, matchDate, startTime, endTime, maxPlayers,
        currentPlayers, playerIds, requiredSkillLevel, costPerPlayer,
        status, notes, createdAt,
      ];
}
