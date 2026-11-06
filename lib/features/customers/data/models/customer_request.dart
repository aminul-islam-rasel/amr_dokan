class CustomerRequest {
  final String name;
  final String phone;
  final String? address;

  CustomerRequest({
    required this.name,
    required this.phone,
    this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'address': address,
    };
  }
}
