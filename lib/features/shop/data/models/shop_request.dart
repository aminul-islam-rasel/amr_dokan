class ShopRequest {
  final String name;
  final String ownerName;
  final String category;
  final String phone;
  final String address;
  final String currency;

  ShopRequest({
    required this.name,
    required this.ownerName,
    required this.category,
    required this.phone,
    required this.address,
    required this.currency,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'owner_name': ownerName,
      'category': category,
      'phone': phone,
      'address': address,
      'currency': currency,
    };
  }
}
