import 'package:equatable/equatable.dart';

class CustomerEntity extends Equatable {
  final String id;
  final String name;
  final String phone;
  final String? address;
  final double totalDue;
  final double totalPurchase;

  const CustomerEntity({
    required this.id,
    required this.name,
    required this.phone,
    this.address,
    required this.totalDue,
    required this.totalPurchase,
  });

  @override
  List<Object?> get props => [id, name, phone, address, totalDue, totalPurchase];
}
