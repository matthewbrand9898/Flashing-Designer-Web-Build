// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Order _$OrderFromJson(Map<String, dynamic> json) => Order(
      name: json['name'] as String,
      id: json['id'] as String,
      flashings: (json['flashings'] as List<dynamic>)
          .map((e) => Flashing.fromJson(e as Map<String, dynamic>))
          .toList(),
      customerName: json['customerName'] as String?,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
    );

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
      'name': instance.name,
      'id': instance.id,
      'flashings': instance.flashings.map((e) => e.toJson()).toList(),
      'customerName': instance.customerName,
      'address': instance.address,
      'phone': instance.phone,
      'email': instance.email,
    };
