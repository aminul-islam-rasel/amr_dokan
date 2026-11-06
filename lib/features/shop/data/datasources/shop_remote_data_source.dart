import 'package:dio/dio.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/shop_model.dart';
import '../models/shop_request.dart';

abstract class ShopRemoteDataSource {
  Future<ShopModel> createShop(ShopRequest request);
  Future<List<ShopModel>> getUserShops();
  Future<ShopModel> getShopDetails(String shopId);
}

class ShopRemoteDataSourceImpl implements ShopRemoteDataSource {
  final DioClient _dioClient;

  ShopRemoteDataSourceImpl(this._dioClient);

  @override
  Future<ShopModel> createShop(ShopRequest request) async {
    try {
      final response = await _dioClient.post(
        ApiEndpoints.shops,
        data: request.toJson(),
      );
      return ShopModel.fromJson(response.data);
    } on DioException catch (e) {
      throw e.error ?? e;
    }
  }

  @override
  Future<List<ShopModel>> getUserShops() async {
    try {
      final response = await _dioClient.get(ApiEndpoints.shops);
      final List data = response.data is List ? response.data : (response.data['shops'] ?? []);
      return data.map((json) => ShopModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw e.error ?? e;
    }
  }

  @override
  Future<ShopModel> getShopDetails(String shopId) async {
    try {
      final response = await _dioClient.get('${ApiEndpoints.shops}/$shopId');
      return ShopModel.fromJson(response.data);
    } on DioException catch (e) {
      throw e.error ?? e;
    }
  }
}
