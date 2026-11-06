import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/app_exception.dart';
import '../../data/repositories/shop_repository_impl.dart';
import '../../domain/entities/shop_entity.dart';
import '../../domain/repositories/shop_repository.dart';

final shopSetupControllerProvider =
    StateNotifierProvider.autoDispose<ShopSetupController, AsyncValue<ShopEntity?>>((ref) {
  final repo = ref.watch(shopRepositoryProvider);
  return ShopSetupController(repo);
});

class ShopSetupController extends StateNotifier<AsyncValue<ShopEntity?>> {
  final ShopRepository _repository;

  ShopSetupController(this._repository) : super(const AsyncValue.data(null));

  Future<bool> createShop({
    required String name,
    required String ownerName,
    required String category,
    required String phone,
    required String address,
    required String currency,
  }) async {
    state = const AsyncValue.loading();
    try {
      final shop = await _repository.createShop(
        name: name,
        ownerName: ownerName,
        category: category,
        phone: phone,
        address: address,
        currency: currency,
      );
      state = AsyncValue.data(shop);
      return true;
    } catch (e, st) {
      String msg = 'দোকান তৈরি করতে সমস্যা হয়েছে। অনুগ্রহ করে আবার চেষ্টা করুন।';
      if (e is AppException) msg = e.message;
      state = AsyncValue.error(msg, st);
      return false;
    }
  }
}
