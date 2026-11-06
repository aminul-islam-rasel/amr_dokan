import '../../domain/entities/customer_entity.dart';

class CustomerModel {
  final String id;
  final String name;
  final String phone;
  final String? address;
  final double totalDue;
  final double totalPurchase;

  CustomerModel({
    required this.id,
    required this.name,
    required this.phone,
    this.address,
    required this.totalDue,
    required this.totalPurchase,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name'] ?? json['customer_name'] ?? '',
      phone: json['phone'] ?? json['phone_number'] ?? '',
      address: json['address'],
      totalDue: (json['total_due'] ?? json['due'] ?? 0.0).toDouble(),
      totalPurchase: (json['total_purchase'] ?? json['purchase'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'address': address,
      'total_due': totalDue,
      'total_purchase': totalPurchase,
    };
  }

  CustomerEntity toEntity() {
    return CustomerEntity(
      id: id,
      name: name,
      phone: phone,
      address: address,
      totalDue: totalDue,
      totalPurchase: totalPurchase,
    );
  }
}
