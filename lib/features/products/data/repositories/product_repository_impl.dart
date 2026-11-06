import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_data_source.dart';
import '../models/product_request.dart';

final productRemoteDataSourceProvider = Provider<ProductRemoteDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ProductRemoteDataSourceImpl(dioClient);
});

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final remoteDataSource = ref.watch(productRemoteDataSourceProvider);
  return ProductRepositoryImpl(remoteDataSource);
});

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource _remoteDataSource;

  ProductRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<ProductEntity>> getProducts(String shopId, {String? search}) async {
    final models = await _remoteDataSource.getProducts(shopId, search: search);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
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
  }) async {
    final model = await _remoteDataSource.createProduct(
      shopId,
      ProductRequest(
        name: name,
        barcode: barcode,
        purchasePrice: purchasePrice,
        sellingPrice: sellingPrice,
        currentStock: currentStock,
        minStock: minStock,
        unit: unit,
        categoryId: categoryId,
      ),
    );
    return model.toEntity();
  }

  @override
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
  }) async {
    final model = await _remoteDataSource.updateProduct(
      shopId,
      productId,
      ProductRequest(
        name: name,
        barcode: barcode,
        purchasePrice: purchasePrice,
        sellingPrice: sellingPrice,
        currentStock: currentStock,
        minStock: minStock,
        unit: unit,
        categoryId: categoryId,
      ),
    );
    return model.toEntity();
  }

  @override
  Future<void> deleteProduct(String shopId, String productId) async {
    await _remoteDataSource.deleteProduct(shopId, productId);
  }
}
