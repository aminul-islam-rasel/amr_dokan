import 'package:dio/dio.dart';
import '../config/env_config.dart';
import '../network/api_endpoints.dart';
import '../storage/secure_storage_service.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorageService _storage;
  final Dio _refreshDio;

  AuthInterceptor(this._storage)
      : _refreshDio = Dio(
          BaseOptions(
            baseUrl: EnvConfig.baseUrl,
            connectTimeout: EnvConfig.connectTimeout,
            receiveTimeout: EnvConfig.receiveTimeout,
          ),
        );

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip token for auth endpoints that don't need it
    final isAuthPublicEndpoint = options.path.contains('/auth/login') ||
        options.path.contains('/auth/register') ||
        options.path.contains('/auth/forgot-password') ||
        options.path.contains('/auth/reset-password');

    if (!isAuthPublicEndpoint) {
      final token = await _storage.readAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    options.headers['Accept'] = 'application/json';
    options.headers['Content-Type'] = 'application/json';

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      final isRefreshEndpoint = err.requestOptions.path.contains(ApiEndpoints.refresh);
      final isLoginEndpoint = err.requestOptions.path.contains(ApiEndpoints.login);

      if (!isRefreshEndpoint && !isLoginEndpoint) {
        final refreshed = await _attemptRefreshToken();
        if (refreshed) {
          try {
            final newToken = await _storage.readAccessToken();
            final opts = err.requestOptions;
            opts.headers['Authorization'] = 'Bearer $newToken';

            final cloneReq = await _refreshDio.fetch(opts);
            return handler.resolve(cloneReq);
          } catch (e) {
            // Failed retry
          }
        } else {
          await _storage.clearTokens();
        }
      }
    }

    return handler.next(err);
  }

  Future<bool> _attemptRefreshToken() async {
    try {
      final refreshToken = await _storage.readRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) return false;

      final response = await _refreshDio.post(
        ApiEndpoints.refresh,
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200 && response.data != null) {
        final newAccessToken = response.data['access_token'];
        final newRefreshToken = response.data['refresh_token'];

        if (newAccessToken != null) {
          await _storage.writeAccessToken(newAccessToken);
        }
        if (newRefreshToken != null) {
          await _storage.writeRefreshToken(newRefreshToken);
        }
        return true;
      }
    } catch (e) {
      // Refresh token invalid or expired
    }
    return false;
  }
}
