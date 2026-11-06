import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/sale_request.dart';
import '../models/sale_response_model.dart';

abstract class SalesRemoteDataSource {
  Future<SaleResponseModel> checkout(String shopId, SaleRequest request);
  Future<List<SaleResponseModel>> getSalesHistory(String shopId);
}

class SalesRemoteDataSourceImpl implements SalesRemoteDataSource {
  final DioClient _dioClient;

  SalesRemoteDataSourceImpl(this._dioClient);

  @override
  Future<SaleResponseModel> checkout(String shopId, SaleRequest request) async {
    try {
      final response = await _dioClient.post(
        '/shops/$shopId/sales',
        data: request.toJson(),
      );
      return SaleResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        // Fallback mock sale response for MVP testing
        double subtotal = 0;
        for (var item in request.items) {
          subtotal += (item.product.sellingPrice * item.quantity) - item.discount;
        }
        final total = subtotal - request.discount;
        final due = total > request.paid ? total - request.paid : 0.0;

        return SaleResponseModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          invoiceNo: 'INV-${DateTime.now().second}${DateTime.now().millisecond}',
          shopId: shopId,
          customerName: request.customerName,
          customerPhone: request.customerPhone,
          items: request.items,
          subtotal: subtotal,
          discount: request.discount,
          total: total,
          paid: request.paid,
          due: due,
          timestamp: DateTime.now(),
        );
      }
      throw e.error ?? e;
    }
  }

  @override
  Future<List<SaleResponseModel>> getSalesHistory(String shopId) async {
    try {
      final response = await _dioClient.get('/shops/$shopId/sales');
      final List data = response.data is List ? response.data : (response.data['sales'] ?? []);
      return data.map((json) => SaleResponseModel.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return [];
      }
      throw e.error ?? e;
    }
  }
}
