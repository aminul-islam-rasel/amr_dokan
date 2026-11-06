import '../../domain/entities/cart_item_entity.dart';

class SaleRequest {
  final List<CartItemEntity> items;
  final double discount;
  final double paid;
  final String? customerName;
  final String? customerPhone;

  SaleRequest({
    required this.items,
    required this.discount,
    required this.paid,
    this.customerName,
    this.customerPhone,
  });

  Map<String, dynamic> toJson() {
    return {
      'items': items
          .map((item) => {
                'product_id': item.product.id,
                'quantity': item.quantity,
                'discount': item.discount,
              })
          .toList(),
      'discount': discount,
      'paid': paid,
      'customer_name': customerName,
      'customer_phone': customerPhone,
    };
  }
}
