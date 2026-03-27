import 'package:equatable/equatable.dart';

class SlotModel extends Equatable {
  final String id;
  final String venueId;
  final DateTime date;
  final String startTime;
  final String endTime;
  final int duration;
  final double price;
  final bool isAvailable;
  final bool isHappyHour;
  final bool isPeakHour;
  final String? bookedBy;

  const SlotModel({
    required this.id,
    required this.venueId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.duration,
    required this.price,
    required this.isAvailable,
    required this.isHappyHour,
    required this.isPeakHour,
    this.bookedBy,
  });

  factory SlotModel.fromJson(Map<String, dynamic> json) {
    return SlotModel(
      id: json['id'] as String,
      venueId: json['venueId'] as String,
      date: DateTime.parse(json['date'] as String),
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      duration: json['duration'] as int,
      price: (json['price'] as num).toDouble(),
      isAvailable: json['isAvailable'] as bool? ?? true,
      isHappyHour: json['isHappyHour'] as bool? ?? false,
      isPeakHour: json['isPeakHour'] as bool? ?? false,
      bookedBy: json['bookedBy'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'venueId': venueId,
      'date': date.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'duration': duration,
      'price': price,
      'isAvailable': isAvailable,
      'isHappyHour': isHappyHour,
      'isPeakHour': isPeakHour,
      'bookedBy': bookedBy,
    };
  }

  SlotModel copyWith({
    String? id,
    String? venueId,
    DateTime? date,
    String? startTime,
    String? endTime,
    int? duration,
    double? price,
    bool? isAvailable,
    bool? isHappyHour,
    bool? isPeakHour,
    String? bookedBy,
  }) {
    return SlotModel(
      id: id ?? this.id,
      venueId: venueId ?? this.venueId,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      price: price ?? this.price,
      isAvailable: isAvailable ?? this.isAvailable,
      isHappyHour: isHappyHour ?? this.isHappyHour,
      isPeakHour: isPeakHour ?? this.isPeakHour,
      bookedBy: bookedBy ?? this.bookedBy,
    );
  }

  @override
  List<Object?> get props => [
        id,
        venueId,
        date,
        startTime,
        endTime,
        duration,
        price,
        isAvailable,
        isHappyHour,
        isPeakHour,
        bookedBy,
      ];
}
