import 'package:json_annotation/json_annotation.dart';
import 'flashing.dart';

part 'order_model.g.dart';

@JsonSerializable(explicitToJson: true)
class Order {
  final String name;
  final String id;
  final List<Flashing> flashings;

  // new optional customer fields:
  final String? customerName;
  final String? address;
  final String? phone;
  final String? email;

  Order({
    required this.name,
    required this.id,
    required this.flashings,
    this.customerName,
    this.address,
    this.phone,
    this.email,
  });

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
  Map<String, dynamic> toJson() => _$OrderToJson(this);
}
