import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/storage/shared_prefs_service.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/repositories/customer_repository.dart';
import '../../data/repositories/customer_repository_impl.dart';

final customersSearchProvider = StateProvider<String>((ref) => '');

final customersProvider = FutureProvider.autoDispose<List<CustomerEntity>>((ref) async {
  final repo = ref.watch(customerRepositoryProvider);
  final sharedPrefs = ref.watch(sharedPrefsServiceProvider);
  final shopId = sharedPrefs.getString(AppConstants.prefKeyActiveShopId) ?? 'default_shop';
  final search = ref.watch(customersSearchProvider);

  return await repo.getCustomers(shopId, search: search.isEmpty ? null : search);
});

final customerFormControllerProvider =
    StateNotifierProvider.autoDispose<CustomerFormController, AsyncValue<bool>>((ref) {
  final repo = ref.watch(customerRepositoryProvider);
  final sharedPrefs = ref.watch(sharedPrefsServiceProvider);
  return CustomerFormController(repo, sharedPrefs);
});

class CustomerFormController extends StateNotifier<AsyncValue<bool>> {
  final CustomerRepository _repository;
  final SharedPrefsService _sharedPrefs;

  CustomerFormController(this._repository, this._sharedPrefs)
      : super(const AsyncValue.data(false));

  Future<bool> saveCustomer({
    String? customerId,
    required String name,
    required String phone,
    String? address,
  }) async {
    state = const AsyncValue.loading();
    try {
      final shopId = _sharedPrefs.getString(AppConstants.prefKeyActiveShopId) ?? 'default_shop';

      if (customerId == null) {
        await _repository.createCustomer(
          shopId: shopId,
          name: name,
          phone: phone,
          address: address,
        );
      } else {
        await _repository.updateCustomer(
          shopId: shopId,
          customerId: customerId,
          name: name,
          phone: phone,
          address: address,
        );
      }
      state = const AsyncValue.data(true);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> collectDue({
    required String customerId,
    required double amount,
  }) async {
    state = const AsyncValue.loading();
    try {
      final shopId = _sharedPrefs.getString(AppConstants.prefKeyActiveShopId) ?? 'default_shop';
      await _repository.collectDue(
        shopId: shopId,
        customerId: customerId,
        amount: amount,
      );
      state = const AsyncValue.data(true);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}
