import '../entities/product_entity.dart';

abstract class ProductRepository {
  Future<List<ProductEntity>> getProducts(String shopId, {String? search});

  Future<ProductEntity> createProduct({
    required String shopId,
    required String name,
    String? barcode,
    required double purchasePrice,
    required double sellingPrice,
    required double currentStock,
    required double minStock,
    required String unit,
    String? categoryId,
  });

  Future<ProductEntity> updateProduct({
    required String shopId,
    required String productId,
    required String name,
    String? barcode,
    required double purchasePrice,
    required double sellingPrice,
    required double currentStock,
    required double minStock,
    required String unit,
    String? categoryId,
  });

  Future<void> deleteProduct(String shopId, String productId);
}
