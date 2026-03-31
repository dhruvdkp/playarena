import 'package:equatable/equatable.dart';

enum UserRole { player, admin, groundManager }

enum MembershipType { free, silver, gold, platinum }

class UserModel extends Equatable {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String? avatarUrl;
  final UserRole role;
  final MembershipType membershipType;
  final int totalBookings;
  final List<String> favoriteVenues;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.avatarUrl,
    required this.role,
    required this.membershipType,
    required this.totalBookings,
    required this.favoriteVenues,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.player,
      ),
      membershipType: MembershipType.values.firstWhere(
        (e) => e.name == json['membershipType'],
        orElse: () => MembershipType.free,
      ),
      totalBookings: json['totalBookings'] as int? ?? 0,
      favoriteVenues: List<String>.from(json['favoriteVenues'] ?? []),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatarUrl': avatarUrl,
      'role': role.name,
      'membershipType': membershipType.name,
      'totalBookings': totalBookings,
      'favoriteVenues': favoriteVenues,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
    UserRole? role,
    MembershipType? membershipType,
    int? totalBookings,
    List<String>? favoriteVenues,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      membershipType: membershipType ?? this.membershipType,
      totalBookings: totalBookings ?? this.totalBookings,
      favoriteVenues: favoriteVenues ?? this.favoriteVenues,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        avatarUrl,
        role,
        membershipType,
        totalBookings,
        favoriteVenues,
        createdAt,
      ];
}
