import 'package:equatable/equatable.dart';

import 'slot_model.dart';
import 'venue_model.dart';

enum PaymentStatus { pending, completed, failed, refunded }

enum BookingStatus { upcoming, ongoing, completed, cancelled }

class AddOn extends Equatable {
  final String id;
  final String name;
  final double price;
  final int quantity;

  const AddOn({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
  });

  factory AddOn.fromJson(Map<String, dynamic> json) {
    return AddOn(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }

  AddOn copyWith({
    String? id,
    String? name,
    double? price,
    int? quantity,
  }) {
    return AddOn(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object?> get props => [id, name, price, quantity];
}

class SplitPaymentModel extends Equatable {
  final String userId;
  final String userName;
  final double amount;
  final bool isPaid;

  const SplitPaymentModel({
    required this.userId,
    required this.userName,
    required this.amount,
    required this.isPaid,
  });

  factory SplitPaymentModel.fromJson(Map<String, dynamic> json) {
    return SplitPaymentModel(
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      amount: (json['amount'] as num).toDouble(),
      isPaid: json['isPaid'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'amount': amount,
      'isPaid': isPaid,
    };
  }

  SplitPaymentModel copyWith({
    String? userId,
    String? userName,
    double? amount,
    bool? isPaid,
  }) {
    return SplitPaymentModel(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      amount: amount ?? this.amount,
      isPaid: isPaid ?? this.isPaid,
    );
  }

  @override
  List<Object?> get props => [userId, userName, amount, isPaid];
}

class BookingModel extends Equatable {
  final String id;
  final String venueId;
  final String venueName;
  final String userId;
  final String userName;
  final SportType sportType;
  final SlotModel slot;
  final List<AddOn> addOns;
  final double totalAmount;
  final PaymentStatus paymentStatus;
  final BookingStatus bookingStatus;
  final String? qrCode;
  final List<SplitPaymentModel> splitPayment;
  final DateTime createdAt;

  const BookingModel({
    required this.id,
    required this.venueId,
    required this.venueName,
    required this.userId,
    required this.userName,
    required this.sportType,
    required this.slot,
    required this.addOns,
    required this.totalAmount,
    required this.paymentStatus,
    required this.bookingStatus,
    this.qrCode,
    required this.splitPayment,
    required this.createdAt,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String,
      venueId: json['venueId'] as String,
      venueName: json['venueName'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      sportType: SportType.values.firstWhere(
        (e) => e.name == json['sportType'],
        orElse: () => SportType.boxCricket,
      ),
      slot: SlotModel.fromJson(json['slot'] as Map<String, dynamic>),
      addOns: (json['addOns'] as List<dynamic>?)
              ?.map((e) => AddOn.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalAmount: (json['totalAmount'] as num).toDouble(),
      paymentStatus: PaymentStatus.values.firstWhere(
        (e) => e.name == json['paymentStatus'],
        orElse: () => PaymentStatus.pending,
      ),
      bookingStatus: BookingStatus.values.firstWhere(
        (e) => e.name == json['bookingStatus'],
        orElse: () => BookingStatus.upcoming,
      ),
      qrCode: json['qrCode'] as String?,
      splitPayment: (json['splitPayment'] as List<dynamic>?)
              ?.map(
                  (e) => SplitPaymentModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'venueId': venueId,
      'venueName': venueName,
      'userId': userId,
      'userName': userName,
      'sportType': sportType.name,
      'slot': slot.toJson(),
      'addOns': addOns.map((e) => e.toJson()).toList(),
      'totalAmount': totalAmount,
      'paymentStatus': paymentStatus.name,
      'bookingStatus': bookingStatus.name,
      'qrCode': qrCode,
      'splitPayment': splitPayment.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  BookingModel copyWith({
    String? id,
    String? venueId,
    String? venueName,
    String? userId,
    String? userName,
    SportType? sportType,
    SlotModel? slot,
    List<AddOn>? addOns,
    double? totalAmount,
    PaymentStatus? paymentStatus,
    BookingStatus? bookingStatus,
    String? qrCode,
    List<SplitPaymentModel>? splitPayment,
    DateTime? createdAt,
  }) {
    return BookingModel(
      id: id ?? this.id,
      venueId: venueId ?? this.venueId,
      venueName: venueName ?? this.venueName,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      sportType: sportType ?? this.sportType,
      slot: slot ?? this.slot,
      addOns: addOns ?? this.addOns,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      bookingStatus: bookingStatus ?? this.bookingStatus,
      qrCode: qrCode ?? this.qrCode,
      splitPayment: splitPayment ?? this.splitPayment,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        venueId,
        venueName,
        userId,
        userName,
        sportType,
        slot,
        addOns,
        totalAmount,
        paymentStatus,
        bookingStatus,
        qrCode,
        splitPayment,
        createdAt,
      ];
}
