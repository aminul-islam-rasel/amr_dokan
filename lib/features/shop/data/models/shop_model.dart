import '../../domain/entities/shop_entity.dart';

class ShopModel {
  final String id;
  final String name;
  final String ownerName;
  final String category;
  final String phone;
  final String address;
  final String currency;
  final String? logoUrl;

  ShopModel({
    required this.id,
    required this.name,
    required this.ownerName,
    required this.category,
    required this.phone,
    required this.address,
    required this.currency,
    this.logoUrl,
  });

  factory ShopModel.fromJson(Map<String, dynamic> json) {
    return ShopModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name'] ?? json['shop_name'] ?? '',
      ownerName: json['owner_name'] ?? json['owner'] ?? '',
      category: json['category'] ?? json['business_category'] ?? 'grocery',
      phone: json['phone'] ?? json['phone_number'] ?? '',
      address: json['address'] ?? '',
      currency: json['currency'] ?? 'BDT',
      logoUrl: json['logo_url'] ?? json['logo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'owner_name': ownerName,
      'category': category,
      'phone': phone,
      'address': address,
      'currency': currency,
      'logo_url': logoUrl,
    };
  }

  ShopEntity toEntity() {
    return ShopEntity(
      id: id,
      name: name,
      ownerName: ownerName,
      category: category,
      phone: phone,
      address: address,
      currency: currency,
      logoUrl: logoUrl,
    );
  }
}
