import '../entities/shop_entity.dart';

abstract class ShopRepository {
  Future<ShopEntity> createShop({
    required String name,
    required String ownerName,
    required String category,
    required String phone,
    required String address,
    required String currency,
  });

  Future<List<ShopEntity>> getUserShops();

  Future<ShopEntity?> getShopDetails(String shopId);
}
