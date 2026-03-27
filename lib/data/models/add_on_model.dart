import 'package:equatable/equatable.dart';

class AddOnModel extends Equatable {
  final String id;
  final String name;
  final double price;
  final String? description;
  final String? iconUrl;

  const AddOnModel({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    this.iconUrl,
  });

  factory AddOnModel.fromJson(Map<String, dynamic> json) {
    return AddOnModel(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String?,
      iconUrl: json['iconUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'iconUrl': iconUrl,
    };
  }

  @override
  List<Object?> get props => [id, name, price, description, iconUrl];
}
