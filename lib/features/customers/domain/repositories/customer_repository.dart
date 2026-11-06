import '../entities/customer_entity.dart';

abstract class CustomerRepository {
  Future<List<CustomerEntity>> getCustomers(String shopId, {String? search});

  Future<CustomerEntity> createCustomer({
    required String shopId,
    required String name,
    required String phone,
    String? address,
  });

  Future<CustomerEntity> updateCustomer({
    required String shopId,
    required String customerId,
    required String name,
    required String phone,
    String? address,
  });

  Future<void> collectDue({
    required String shopId,
    required String customerId,
    required double amount,
  });
}
