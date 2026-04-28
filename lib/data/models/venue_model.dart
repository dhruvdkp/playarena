import 'package:equatable/equatable.dart';

enum SportType { boxCricket, football, pickleball, badminton, tennis }

enum Amenity {
  parking,
  cctv,
  shower,
  drinkingWater,
  changingRoom,
  cafeteria,
  firstAid,
  wifi,
  floodlights,
  scoreboard,
}

class VenueModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final String address;
  final String city;
  final double latitude;
  final double longitude;
  final List<String> imageUrls;
  final List<SportType> sportTypes;
  final List<Amenity> amenities;
  final double rating;
  final int totalReviews;
  final double pricePerHour;
  final double peakPricePerHour;
  final double happyHourPrice;
  final String openTime;
  final String closeTime;
  final bool isVerified;
  final String ownerId;
  final String contactPhone;
  final int availableSlots;
  final int totalSlots;
  final String rules;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const VenueModel({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.imageUrls,
    required this.sportTypes,
    required this.amenities,
    required this.rating,
    required this.totalReviews,
    required this.pricePerHour,
    required this.peakPricePerHour,
    required this.happyHourPrice,
    required this.openTime,
    required this.closeTime,
    required this.isVerified,
    required this.ownerId,
    required this.contactPhone,
    required this.availableSlots,
    required this.totalSlots,
    this.rules = '',
    this.createdAt,
    this.updatedAt,
  });

  factory VenueModel.fromJson(Map<String, dynamic> json) {
    return VenueModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      address: json['address'] as String,
      city: json['city'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      sportTypes: (json['sportTypes'] as List<dynamic>?)
              ?.map((e) => SportType.values.firstWhere(
                    (s) => s.name == e,
                    orElse: () => SportType.boxCricket,
                  ))
              .toList() ??
          [],
      amenities: (json['amenities'] as List<dynamic>?)
              ?.map((e) => Amenity.values.firstWhere(
                    (a) => a.name == e,
                    orElse: () => Amenity.parking,
                  ))
              .toList() ??
          [],
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      totalReviews: json['totalReviews'] as int? ?? 0,
      pricePerHour: (json['pricePerHour'] as num).toDouble(),
      peakPricePerHour: (json['peakPricePerHour'] as num).toDouble(),
      happyHourPrice: (json['happyHourPrice'] as num).toDouble(),
      openTime: json['openTime'] as String? ?? '06:00',
      closeTime: json['closeTime'] as String? ?? '23:00',
      isVerified: json['isVerified'] as bool? ?? false,
      ownerId: json['ownerId'] as String,
      contactPhone: json['contactPhone'] as String? ?? '',
      availableSlots: json['availableSlots'] as int? ?? 0,
      totalSlots: json['totalSlots'] as int? ?? 0,
      rules: json['rules'] as String? ?? '',
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
      'name': name,
      'description': description,
      'address': address,
      'city': city,
      'latitude': latitude,
      'longitude': longitude,
      'imageUrls': imageUrls,
      'sportTypes': sportTypes.map((e) => e.name).toList(),
      'amenities': amenities.map((e) => e.name).toList(),
      'rating': rating,
      'totalReviews': totalReviews,
      'pricePerHour': pricePerHour,
      'peakPricePerHour': peakPricePerHour,
      'happyHourPrice': happyHourPrice,
      'openTime': openTime,
      'closeTime': closeTime,
      'isVerified': isVerified,
      'ownerId': ownerId,
      'contactPhone': contactPhone,
      'availableSlots': availableSlots,
      'totalSlots': totalSlots,
      'rules': rules,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  VenueModel copyWith({
    String? id,
    String? name,
    String? description,
    String? address,
    String? city,
    double? latitude,
    double? longitude,
    List<String>? imageUrls,
    List<SportType>? sportTypes,
    List<Amenity>? amenities,
    double? rating,
    int? totalReviews,
    double? pricePerHour,
    double? peakPricePerHour,
    double? happyHourPrice,
    String? openTime,
    String? closeTime,
    bool? isVerified,
    String? ownerId,
    String? contactPhone,
    int? availableSlots,
    int? totalSlots,
    String? rules,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VenueModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      city: city ?? this.city,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      imageUrls: imageUrls ?? this.imageUrls,
      sportTypes: sportTypes ?? this.sportTypes,
      amenities: amenities ?? this.amenities,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      pricePerHour: pricePerHour ?? this.pricePerHour,
      peakPricePerHour: peakPricePerHour ?? this.peakPricePerHour,
      happyHourPrice: happyHourPrice ?? this.happyHourPrice,
      openTime: openTime ?? this.openTime,
      closeTime: closeTime ?? this.closeTime,
      isVerified: isVerified ?? this.isVerified,
      ownerId: ownerId ?? this.ownerId,
      contactPhone: contactPhone ?? this.contactPhone,
      availableSlots: availableSlots ?? this.availableSlots,
      totalSlots: totalSlots ?? this.totalSlots,
      rules: rules ?? this.rules,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        address,
        city,
        latitude,
        longitude,
        imageUrls,
        sportTypes,
        amenities,
        rating,
        totalReviews,
        pricePerHour,
        peakPricePerHour,
        happyHourPrice,
        openTime,
        closeTime,
        isVerified,
        ownerId,
        contactPhone,
        availableSlots,
        totalSlots,
        rules,
        createdAt,
        updatedAt,
      ];
}
