import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/repositories/customer_repository.dart';
import '../datasources/customer_remote_data_source.dart';
import '../models/customer_request.dart';

final customerRemoteDataSourceProvider = Provider<CustomerRemoteDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return CustomerRemoteDataSourceImpl(dioClient);
});

final customerRepositoryProvider = Provider<CustomerRepository>((ref) {
  final remoteDataSource = ref.watch(customerRemoteDataSourceProvider);
  return CustomerRepositoryImpl(remoteDataSource);
});

class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerRemoteDataSource _remoteDataSource;

  CustomerRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<CustomerEntity>> getCustomers(String shopId, {String? search}) async {
    final models = await _remoteDataSource.getCustomers(shopId, search: search);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<CustomerEntity> createCustomer({
    required String shopId,
    required String name,
    required String phone,
    String? address,
  }) async {
    final model = await _remoteDataSource.createCustomer(
      shopId,
      CustomerRequest(name: name, phone: phone, address: address),
    );
    return model.toEntity();
  }

  @override
  Future<CustomerEntity> updateCustomer({
    required String shopId,
    required String customerId,
    required String name,
    required String phone,
    String? address,
  }) async {
    final model = await _remoteDataSource.updateCustomer(
      shopId,
      customerId,
      CustomerRequest(name: name, phone: phone, address: address),
    );
    return model.toEntity();
  }

  @override
  Future<void> collectDue({
    required String shopId,
    required String customerId,
    required double amount,
  }) async {
    await _remoteDataSource.collectDue(shopId, customerId, amount);
  }
}
