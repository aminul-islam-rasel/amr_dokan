import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/storage/shared_prefs_service.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../../data/repositories/product_repository_impl.dart';

final productsSearchProvider = StateProvider<String>((ref) => '');

final productsProvider = FutureProvider.autoDispose<List<ProductEntity>>((ref) async {
  final repo = ref.watch(productRepositoryProvider);
  final sharedPrefs = ref.watch(sharedPrefsServiceProvider);
  final shopId = sharedPrefs.getString(AppConstants.prefKeyActiveShopId) ?? 'default_shop';
  final search = ref.watch(productsSearchProvider);

  return await repo.getProducts(shopId, search: search.isEmpty ? null : search);
});

final productFormControllerProvider =
    StateNotifierProvider.autoDispose<ProductFormController, AsyncValue<bool>>((ref) {
  final repo = ref.watch(productRepositoryProvider);
  final sharedPrefs = ref.watch(sharedPrefsServiceProvider);
  return ProductFormController(repo, sharedPrefs);
});

class ProductFormController extends StateNotifier<AsyncValue<bool>> {
  final ProductRepository _repository;
  final SharedPrefsService _sharedPrefs;

  ProductFormController(this._repository, this._sharedPrefs)
      : super(const AsyncValue.data(false));

  Future<bool> saveProduct({
    String? productId,
    required String name,
    String? barcode,
    required double purchasePrice,
    required double sellingPrice,
    required double currentStock,
    required double minStock,
    required String unit,
  }) async {
    state = const AsyncValue.loading();
    try {
      final shopId = _sharedPrefs.getString(AppConstants.prefKeyActiveShopId) ?? 'default_shop';

      if (productId == null) {
        await _repository.createProduct(
          shopId: shopId,
          name: name,
          barcode: barcode,
          purchasePrice: purchasePrice,
          sellingPrice: sellingPrice,
          currentStock: currentStock,
          minStock: minStock,
          unit: unit,
        );
      } else {
        await _repository.updateProduct(
          shopId: shopId,
          productId: productId,
          name: name,
          barcode: barcode,
          purchasePrice: purchasePrice,
          sellingPrice: sellingPrice,
          currentStock: currentStock,
          minStock: minStock,
          unit: unit,
        );
      }
      state = const AsyncValue.data(true);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> deleteProduct(String productId) async {
    state = const AsyncValue.loading();
    try {
      final shopId = _sharedPrefs.getString(AppConstants.prefKeyActiveShopId) ?? 'default_shop';
      await _repository.deleteProduct(shopId, productId);
      state = const AsyncValue.data(true);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }
}
