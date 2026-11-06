import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/storage/shared_prefs_service.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/entities/sale_entity.dart';
import '../../domain/repositories/sales_repository.dart';
import '../../data/repositories/sales_repository_impl.dart';

final posCartProvider = StateNotifierProvider<POSCartController, CartState>((ref) {
  final repo = ref.watch(salesRepositoryProvider);
  final sharedPrefs = ref.watch(sharedPrefsServiceProvider);
  return POSCartController(repo, sharedPrefs);
});

class CartState {
  final List<CartItemEntity> items;
  final double globalDiscount;
  final bool isLoading;
  final SaleEntity? lastCompletedSale;

  CartState({
    required this.items,
    this.globalDiscount = 0.0,
    this.isLoading = false,
    this.lastCompletedSale,
  });

  double get subtotal => items.fold(0, (sum, item) => sum + (item.product.sellingPrice * item.quantity));
  double get total => subtotal - globalDiscount;

  CartState copyWith({
    List<CartItemEntity>? items,
    double? globalDiscount,
    bool? isLoading,
    SaleEntity? lastCompletedSale,
  }) {
    return CartState(
      items: items ?? this.items,
      globalDiscount: globalDiscount ?? this.globalDiscount,
      isLoading: isLoading ?? this.isLoading,
      lastCompletedSale: lastCompletedSale ?? this.lastCompletedSale,
    );
  }
}

class POSCartController extends StateNotifier<CartState> {
  final SalesRepository _repository;
  final SharedPrefsService _sharedPrefs;

  POSCartController(this._repository, this._sharedPrefs) : super(CartState(items: []));

  void addToCart(ProductEntity product) {
    final existingIndex = state.items.indexWhere((item) => item.product.id == product.id);
    List<CartItemEntity> updatedItems = List.from(state.items);

    if (existingIndex >= 0) {
      final existing = updatedItems[existingIndex];
      updatedItems[existingIndex] = existing.copyWith(quantity: existing.quantity + 1);
    } else {
      updatedItems.add(CartItemEntity(product: product, quantity: 1.0));
    }

    state = state.copyWith(items: updatedItems);
  }

  void updateQuantity(String productId, double quantity) {
    if (quantity <= 0) {
      removeFromCart(productId);
      return;
    }
    List<CartItemEntity> updatedItems = state.items.map((item) {
      if (item.product.id == productId) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();

    state = state.copyWith(items: updatedItems);
  }

  void removeFromCart(String productId) {
    List<CartItemEntity> updatedItems =
        state.items.where((item) => item.product.id != productId).toList();
    state = state.copyWith(items: updatedItems);
  }

  void setGlobalDiscount(double discount) {
    state = state.copyWith(globalDiscount: discount);
  }

  void clearCart() {
    state = CartState(items: []);
  }

  Future<SaleEntity?> checkout({
    required double paid,
    String? customerName,
    String? customerPhone,
  }) async {
    if (state.items.isEmpty) return null;

    state = state.copyWith(isLoading: true);
    try {
      final shopId = _sharedPrefs.getString(AppConstants.prefKeyActiveShopId) ?? 'default_shop';
      final sale = await _repository.checkout(
        shopId: shopId,
        items: state.items,
        discount: state.globalDiscount,
        paid: paid,
        customerName: customerName,
        customerPhone: customerPhone,
      );

      state = CartState(items: [], lastCompletedSale: sale);
      return sale;
    } catch (_) {
      state = state.copyWith(isLoading: false);
      return null;
    }
  }
}
