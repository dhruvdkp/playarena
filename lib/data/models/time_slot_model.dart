import 'package:equatable/equatable.dart';

enum SlotStatus { available, booked, blocked }

enum SlotType { regular, happyHour, peak }

class TimeSlotModel extends Equatable {
  final String id;
  final String venueId;
  final DateTime date;
  final String startTime;
  final String endTime;
  final SlotStatus status;
  final SlotType slotType;
  final double price;
  final String? bookedByUserId;

  const TimeSlotModel({
    required this.id,
    required this.venueId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.slotType,
    required this.price,
    this.bookedByUserId,
  });

  factory TimeSlotModel.fromJson(Map<String, dynamic> json) {
    return TimeSlotModel(
      id: json['id'] as String,
      venueId: json['venueId'] as String,
      date: DateTime.parse(json['date'] as String),
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
      status: SlotStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SlotStatus.available,
      ),
      slotType: SlotType.values.firstWhere(
        (e) => e.name == json['slotType'],
        orElse: () => SlotType.regular,
      ),
      price: (json['price'] as num).toDouble(),
      bookedByUserId: json['bookedByUserId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'venueId': venueId,
      'date': date.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'status': status.name,
      'slotType': slotType.name,
      'price': price,
      'bookedByUserId': bookedByUserId,
    };
  }

  TimeSlotModel copyWith({
    String? id,
    String? venueId,
    DateTime? date,
    String? startTime,
    String? endTime,
    SlotStatus? status,
    SlotType? slotType,
    double? price,
    String? bookedByUserId,
  }) {
    return TimeSlotModel(
      id: id ?? this.id,
      venueId: venueId ?? this.venueId,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      slotType: slotType ?? this.slotType,
      price: price ?? this.price,
      bookedByUserId: bookedByUserId ?? this.bookedByUserId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        venueId,
        date,
        startTime,
        endTime,
        status,
        slotType,
        price,
        bookedByUserId,
      ];
}
