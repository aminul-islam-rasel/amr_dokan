import 'package:equatable/equatable.dart';

class ShopEntity extends Equatable {
  final String id;
  final String name;
  final String ownerName;
  final String category;
  final String phone;
  final String address;
  final String currency;
  final String? logoUrl;

  const ShopEntity({
    required this.id,
    required this.name,
    required this.ownerName,
    required this.category,
    required this.phone,
    required this.address,
    required this.currency,
    this.logoUrl,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        ownerName,
        category,
        phone,
        address,
        currency,
        logoUrl,
      ];
}
