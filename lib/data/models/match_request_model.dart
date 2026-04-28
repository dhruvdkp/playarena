import 'package:equatable/equatable.dart';

import 'venue_model.dart';

enum SkillLevel { beginner, intermediate, advanced, any }

enum MatchRequestStatus { open, full, cancelled, completed }

class MatchRequestModel extends Equatable {
  final String id;
  final String hostUserId;
  final String hostName;
  final SportType sportType;
  final String venueId;
  final String venueName;
  final DateTime date;
  final String time;
  final int playersNeeded;
  final List<String> playersJoined;
  final SkillLevel skillLevel;
  final String description;
  final MatchRequestStatus status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MatchRequestModel({
    required this.id,
    required this.hostUserId,
    required this.hostName,
    required this.sportType,
    required this.venueId,
    required this.venueName,
    required this.date,
    required this.time,
    required this.playersNeeded,
    required this.playersJoined,
    required this.skillLevel,
    required this.description,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory MatchRequestModel.fromJson(Map<String, dynamic> json) {
    return MatchRequestModel(
      id: json['id'] as String,
      hostUserId: json['hostUserId'] as String,
      hostName: json['hostName'] as String,
      sportType: SportType.values.firstWhere(
        (e) => e.name == json['sportType'],
        orElse: () => SportType.boxCricket,
      ),
      venueId: json['venueId'] as String,
      venueName: json['venueName'] as String,
      date: DateTime.parse(json['date'] as String),
      time: json['time'] as String,
      playersNeeded: json['playersNeeded'] as int,
      playersJoined: List<String>.from(json['playersJoined'] ?? []),
      skillLevel: SkillLevel.values.firstWhere(
        (e) => e.name == json['skillLevel'],
        orElse: () => SkillLevel.any,
      ),
      description: json['description'] as String,
      status: MatchRequestStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => MatchRequestStatus.open,
      ),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hostUserId': hostUserId,
      'hostName': hostName,
      'sportType': sportType.name,
      'venueId': venueId,
      'venueName': venueName,
      'date': date.toIso8601String(),
      'time': time,
      'playersNeeded': playersNeeded,
      'playersJoined': playersJoined,
      'skillLevel': skillLevel.name,
      'description': description,
      'status': status.name,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  MatchRequestModel copyWith({
    String? id,
    String? hostUserId,
    String? hostName,
    SportType? sportType,
    String? venueId,
    String? venueName,
    DateTime? date,
    String? time,
    int? playersNeeded,
    List<String>? playersJoined,
    SkillLevel? skillLevel,
    String? description,
    MatchRequestStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MatchRequestModel(
      id: id ?? this.id,
      hostUserId: hostUserId ?? this.hostUserId,
      hostName: hostName ?? this.hostName,
      sportType: sportType ?? this.sportType,
      venueId: venueId ?? this.venueId,
      venueName: venueName ?? this.venueName,
      date: date ?? this.date,
      time: time ?? this.time,
      playersNeeded: playersNeeded ?? this.playersNeeded,
      playersJoined: playersJoined ?? this.playersJoined,
      skillLevel: skillLevel ?? this.skillLevel,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        hostUserId,
        hostName,
        sportType,
        venueId,
        venueName,
        date,
        time,
        playersNeeded,
        playersJoined,
        skillLevel,
        description,
        status,
        createdAt,
        updatedAt,
      ];
}
