import 'package:equatable/equatable.dart';

import 'venue_model.dart';

class TeamMember extends Equatable {
  final String userId;
  final String name;
  final String role;

  const TeamMember({
    required this.userId,
    required this.name,
    required this.role,
  });

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    return TeamMember(
      userId: json['userId'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'role': role,
    };
  }

  TeamMember copyWith({
    String? userId,
    String? name,
    String? role,
  }) {
    return TeamMember(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      role: role ?? this.role,
    );
  }

  @override
  List<Object?> get props => [userId, name, role];
}

class TeamModel extends Equatable {
  final String id;
  final String name;
  final String captainId;
  final String captainName;
  final SportType sportType;
  final List<TeamMember> members;
  final int matchesPlayed;
  final int wins;
  final int losses;
  final double rating;

  const TeamModel({
    required this.id,
    required this.name,
    required this.captainId,
    required this.captainName,
    required this.sportType,
    required this.members,
    required this.matchesPlayed,
    required this.wins,
    required this.losses,
    required this.rating,
  });

  factory TeamModel.fromJson(Map<String, dynamic> json) {
    return TeamModel(
      id: json['id'] as String,
      name: json['name'] as String,
      captainId: json['captainId'] as String,
      captainName: json['captainName'] as String,
      sportType: SportType.values.firstWhere(
        (e) => e.name == json['sportType'],
        orElse: () => SportType.boxCricket,
      ),
      members: (json['members'] as List<dynamic>?)
              ?.map((e) => TeamMember.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      matchesPlayed: json['matchesPlayed'] as int? ?? 0,
      wins: json['wins'] as int? ?? 0,
      losses: json['losses'] as int? ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'captainId': captainId,
      'captainName': captainName,
      'sportType': sportType.name,
      'members': members.map((e) => e.toJson()).toList(),
      'matchesPlayed': matchesPlayed,
      'wins': wins,
      'losses': losses,
      'rating': rating,
    };
  }

  TeamModel copyWith({
    String? id,
    String? name,
    String? captainId,
    String? captainName,
    SportType? sportType,
    List<TeamMember>? members,
    int? matchesPlayed,
    int? wins,
    int? losses,
    double? rating,
  }) {
    return TeamModel(
      id: id ?? this.id,
      name: name ?? this.name,
      captainId: captainId ?? this.captainId,
      captainName: captainName ?? this.captainName,
      sportType: sportType ?? this.sportType,
      members: members ?? this.members,
      matchesPlayed: matchesPlayed ?? this.matchesPlayed,
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
      rating: rating ?? this.rating,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        captainId,
        captainName,
        sportType,
        members,
        matchesPlayed,
        wins,
        losses,
        rating,
      ];
}
