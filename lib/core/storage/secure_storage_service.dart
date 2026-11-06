import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';
import '../errors/app_exception.dart';

final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
              iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
            );

  Future<void> writeAccessToken(String token) async {
    try {
      await _storage.write(key: AppConstants.secureKeyAccessToken, value: token);
    } catch (e) {
      throw StorageException(message: 'টোকেন সংরক্ষণ করতে ব্যর্থ হয়েছে: $e');
    }
  }

  Future<String?> readAccessToken() async {
    try {
      return await _storage.read(key: AppConstants.secureKeyAccessToken);
    } catch (e) {
      return null;
    }
  }

  Future<void> writeRefreshToken(String token) async {
    try {
      await _storage.write(key: AppConstants.secureKeyRefreshToken, value: token);
    } catch (e) {
      throw StorageException(message: 'রিফ্রেশ টোকেন সংরক্ষণ করতে ব্যর্থ হয়েছে: $e');
    }
  }

  Future<String?> readRefreshToken() async {
    try {
      return await _storage.read(key: AppConstants.secureKeyRefreshToken);
    } catch (e) {
      return null;
    }
  }

  Future<void> clearTokens() async {
    try {
      await _storage.delete(key: AppConstants.secureKeyAccessToken);
      await _storage.delete(key: AppConstants.secureKeyRefreshToken);
    } catch (e) {
      // Ignore clear failure
    }
  }

  Future<bool> hasAccessToken() async {
    final token = await readAccessToken();
    return token != null && token.isNotEmpty;
  }
}
