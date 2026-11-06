import '../entities/sale_entity.dart';
import '../entities/cart_item_entity.dart';

abstract class SalesRepository {
  Future<SaleEntity> checkout({
    required String shopId,
    required List<CartItemEntity> items,
    required double discount,
    required double paid,
    String? customerName,
    String? customerPhone,
  });

  Future<List<SaleEntity>> getSalesHistory(String shopId);
}
