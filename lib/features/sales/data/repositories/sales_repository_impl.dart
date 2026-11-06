import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/entities/sale_entity.dart';
import '../../domain/repositories/sales_repository.dart';
import '../datasources/sales_remote_data_source.dart';
import '../models/sale_request.dart';

final salesRemoteDataSourceProvider = Provider<SalesRemoteDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return SalesRemoteDataSourceImpl(dioClient);
});

final salesRepositoryProvider = Provider<SalesRepository>((ref) {
  final remoteDataSource = ref.watch(salesRemoteDataSourceProvider);
  return SalesRepositoryImpl(remoteDataSource);
});

class SalesRepositoryImpl implements SalesRepository {
  final SalesRemoteDataSource _remoteDataSource;

  SalesRepositoryImpl(this._remoteDataSource);

  @override
  Future<SaleEntity> checkout({
    required String shopId,
    required List<CartItemEntity> items,
    required double discount,
    required double paid,
    String? customerName,
    String? customerPhone,
  }) async {
    final model = await _remoteDataSource.checkout(
      shopId,
      SaleRequest(
        items: items,
        discount: discount,
        paid: paid,
        customerName: customerName,
        customerPhone: customerPhone,
      ),
    );
    return model.toEntity();
  }

  @override
  Future<List<SaleEntity>> getSalesHistory(String shopId) async {
    final models = await _remoteDataSource.getSalesHistory(shopId);
    return models.map((m) => m.toEntity()).toList();
  }
}
