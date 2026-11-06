import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/shared_prefs_service.dart';
import '../../domain/entities/shop_entity.dart';
import '../../domain/repositories/shop_repository.dart';
import '../datasources/shop_remote_data_source.dart';
import '../models/shop_request.dart';

final shopRemoteDataSourceProvider = Provider<ShopRemoteDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return ShopRemoteDataSourceImpl(dioClient);
});

final shopRepositoryProvider = Provider<ShopRepository>((ref) {
  final remoteDataSource = ref.watch(shopRemoteDataSourceProvider);
  final sharedPrefs = ref.watch(sharedPrefsServiceProvider);
  return ShopRepositoryImpl(
    remoteDataSource: remoteDataSource,
    sharedPrefs: sharedPrefs,
  );
});

class ShopRepositoryImpl implements ShopRepository {
  final ShopRemoteDataSource _remoteDataSource;
  final SharedPrefsService _sharedPrefs;

  ShopRepositoryImpl({
    required this._remoteDataSource,
    required this._sharedPrefs,
  });

  @override
  Future<ShopEntity> createShop({
    required String name,
    required String ownerName,
    required String category,
    required String phone,
    required String address,
    required String currency,
  }) async {
    final model = await _remoteDataSource.createShop(
      ShopRequest(
        name: name,
        ownerName: ownerName,
        category: category,
        phone: phone,
        address: address,
        currency: currency,
      ),
    );

    await _sharedPrefs.setString(AppConstants.prefKeyActiveShopId, model.id);
    return model.toEntity();
  }

  @override
  Future<List<ShopEntity>> getUserShops() async {
    final models = await _remoteDataSource.getUserShops();
    if (models.isNotEmpty) {
      await _sharedPrefs.setString(AppConstants.prefKeyActiveShopId, models.first.id);
    }
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<ShopEntity?> getShopDetails(String shopId) async {
    try {
      final model = await _remoteDataSource.getShopDetails(shopId);
      return model.toEntity();
    } catch (_) {
      return null;
    }
  }
}
