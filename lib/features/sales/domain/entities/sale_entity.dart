import 'package:equatable/equatable.dart';
import 'cart_item_entity.dart';

class SaleEntity extends Equatable {
  final String id;
  final String invoiceNo;
  final String shopId;
  final String? customerName;
  final String? customerPhone;
  final List<CartItemEntity> items;
  final double subtotal;
  final double discount;
  final double total;
  final double paid;
  final double due;
  final DateTime timestamp;

  const SaleEntity({
    required this.id,
    required this.invoiceNo,
    required this.shopId,
    this.customerName,
    this.customerPhone,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.total,
    required this.paid,
    required this.due,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [
        id,
        invoiceNo,
        shopId,
        customerName,
        customerPhone,
        items,
        subtotal,
        discount,
        total,
        paid,
        due,
        timestamp,
      ];
}
