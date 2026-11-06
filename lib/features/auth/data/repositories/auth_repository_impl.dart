import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/storage/shared_prefs_service.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';
import '../models/user_model.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  return AuthRemoteDataSourceImpl(dioClient);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  final secureStorage = ref.watch(secureStorageServiceProvider);
  final sharedPrefs = ref.watch(sharedPrefsServiceProvider);
  return AuthRepositoryImpl(
    remoteDataSource: remoteDataSource,
    secureStorage: secureStorage,
    sharedPrefs: sharedPrefs,
  );
});

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final SecureStorageService _secureStorage;
  final SharedPrefsService _sharedPrefs;

  AuthRepositoryImpl({
    required this._remoteDataSource,
    required this._secureStorage,
    required this._sharedPrefs,
  });

  @override
  Future<UserEntity> login({
    required String emailOrPhone,
    required String password,
  }) async {
    final response = await _remoteDataSource.login(
      LoginRequest(emailOrPhone: emailOrPhone, password: password),
    );

    await _secureStorage.writeAccessToken(response.tokens.accessToken);
    await _secureStorage.writeRefreshToken(response.tokens.refreshToken);
    await _cacheUserData(response.user);

    return response.user.toEntity();
  }

  @override
  Future<UserEntity> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    final response = await _remoteDataSource.register(
      RegisterRequest(name: name, email: email, phone: phone, password: password),
    );

    await _secureStorage.writeAccessToken(response.tokens.accessToken);
    await _secureStorage.writeRefreshToken(response.tokens.refreshToken);
    await _cacheUserData(response.user);

    return response.user.toEntity();
  }

  @override
  Future<void> logout() async {
    await _remoteDataSource.logout();
    await _secureStorage.clearTokens();
    await _sharedPrefs.remove(AppConstants.prefKeyUserData);
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    await _remoteDataSource.forgotPassword(email);
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    await _remoteDataSource.resetPassword(email, code, newPassword);
  }

  @override
  Future<void> verifyEmail({
    required String email,
    required String code,
  }) async {
    await _remoteDataSource.verifyEmail(email, code);
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      final userModel = await _remoteDataSource.me();
      await _cacheUserData(userModel);
      return userModel.toEntity();
    } catch (_) {
      // Fallback to cached user if offline or error
      final cachedJson = _sharedPrefs.getString(AppConstants.prefKeyUserData);
      if (cachedJson != null) {
        try {
          final Map<String, dynamic> map = jsonDecode(cachedJson);
          return UserModel.fromJson(map).toEntity();
        } catch (_) {
          return null;
        }
      }
      return null;
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    return await _secureStorage.hasAccessToken();
  }

  Future<void> _cacheUserData(UserModel user) async {
    final jsonStr = jsonEncode(user.toJson());
    await _sharedPrefs.setString(AppConstants.prefKeyUserData, jsonStr);
    if (user.activeShopId != null) {
      await _sharedPrefs.setString(AppConstants.prefKeyActiveShopId, user.activeShopId!);
    }
  }
}
