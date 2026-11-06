import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/product_model.dart';
import '../models/product_request.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts(String shopId, {String? search});
  Future<ProductModel> createProduct(String shopId, ProductRequest request);
  Future<ProductModel> updateProduct(String shopId, String productId, ProductRequest request);
  Future<void> deleteProduct(String shopId, String productId);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final DioClient _dioClient;

  ProductRemoteDataSourceImpl(this._dioClient);

  @override
  Future<List<ProductModel>> getProducts(String shopId, {String? search}) async {
    try {
      final query = search != null && search.isNotEmpty ? {'search': search} : null;
      final response = await _dioClient.get(
        '/shops/$shopId/products',
        queryParameters: query,
      );
      final List data = response.data is List ? response.data : (response.data['products'] ?? []);
      return data.map((json) => ProductModel.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        // Fallback mock products for MVP testing
        return [
          ProductModel(
            id: '1',
            name: 'সয়াবিন তেল ১ লিটার',
            barcode: '89401234567',
            purchasePrice: 155,
            sellingPrice: 165,
            currentStock: 24,
            minStock: 5,
            unit: 'ltr',
          ),
          ProductModel(
            id: '2',
            name: 'মিনিকেট চাল ১ কেজি',
            barcode: '89401234568',
            purchasePrice: 68,
            sellingPrice: 75,
            currentStock: 3, // Low stock alert test
            minStock: 10,
            unit: 'kg',
          ),
          ProductModel(
            id: '3',
            name: 'চিনি ১ কেজি',
            barcode: '89401234569',
            purchasePrice: 130,
            sellingPrice: 140,
            currentStock: 0, // Out of stock test
            minStock: 5,
            unit: 'kg',
          ),
        ];
      }
      throw e.error ?? e;
    }
  }

  @override
  Future<ProductModel> createProduct(String shopId, ProductRequest request) async {
    try {
      final response = await _dioClient.post(
        '/shops/$shopId/products',
        data: request.toJson(),
      );
      return ProductModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return ProductModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: request.name,
          barcode: request.barcode,
          purchasePrice: request.purchasePrice,
          sellingPrice: request.sellingPrice,
          currentStock: request.currentStock,
          minStock: request.minStock,
          unit: request.unit,
        );
      }
      throw e.error ?? e;
    }
  }

  @override
  Future<ProductModel> updateProduct(String shopId, String productId, ProductRequest request) async {
    try {
      final response = await _dioClient.put(
        '/shops/$shopId/products/$productId',
        data: request.toJson(),
      );
      return ProductModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return ProductModel(
          id: productId,
          name: request.name,
          barcode: request.barcode,
          purchasePrice: request.purchasePrice,
          sellingPrice: request.sellingPrice,
          currentStock: request.currentStock,
          minStock: request.minStock,
          unit: request.unit,
        );
      }
      throw e.error ?? e;
    }
  }

  @override
  Future<void> deleteProduct(String shopId, String productId) async {
    try {
      await _dioClient.delete('/shops/$shopId/products/$productId');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return; // Success mock
      }
      throw e.error ?? e;
    }
  }
}
