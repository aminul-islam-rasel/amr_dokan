import '../../domain/entities/sale_entity.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../../products/data/models/product_model.dart';

class SaleResponseModel {
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

  SaleResponseModel({
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

  factory SaleResponseModel.fromJson(Map<String, dynamic> json) {
    var rawItems = json['items'] as List? ?? [];
    List<CartItemEntity> parsedItems = rawItems.map((itemJson) {
      final product = ProductModel.fromJson(itemJson['product'] ?? itemJson);
      final qty = (itemJson['quantity'] ?? 1.0).toDouble();
      final disc = (itemJson['discount'] ?? 0.0).toDouble();
      return CartItemEntity(product: product.toEntity(), quantity: qty, discount: disc);
    }).toList();

    return SaleResponseModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      invoiceNo: json['invoice_no'] ?? 'INV-1001',
      shopId: json['shop_id']?.toString() ?? '',
      customerName: json['customer_name'],
      customerPhone: json['customer_phone'],
      items: parsedItems,
      subtotal: (json['subtotal'] ?? 0.0).toDouble(),
      discount: (json['discount'] ?? 0.0).toDouble(),
      total: (json['total'] ?? 0.0).toDouble(),
      paid: (json['paid'] ?? 0.0).toDouble(),
      due: (json['due'] ?? 0.0).toDouble(),
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : (json['created_at'] != null ? DateTime.parse(json['created_at']) : DateTime.now()),
    );
  }

  SaleEntity toEntity() {
    return SaleEntity(
      id: id,
      invoiceNo: invoiceNo,
      shopId: shopId,
      customerName: customerName,
      customerPhone: customerPhone,
      items: items,
      subtotal: subtotal,
      discount: discount,
      total: total,
      paid: paid,
      due: due,
      timestamp: timestamp,
    );
  }
}
