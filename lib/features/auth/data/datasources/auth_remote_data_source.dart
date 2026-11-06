import 'package:dio/dio.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/auth_response.dart';
import '../models/login_request.dart';
import '../models/register_request.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponse> login(LoginRequest request);
  Future<AuthResponse> register(RegisterRequest request);
  Future<void> logout();
  Future<void> forgotPassword(String email);
  Future<void> resetPassword(String email, String code, String newPassword);
  Future<void> verifyEmail(String email, String code);
  Future<UserModel> me();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _dioClient;

  AuthRemoteDataSourceImpl(this._dioClient);

  @override
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _dioClient.post(
        ApiEndpoints.login,
        data: request.toJson(),
      );
      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw e.error ?? e;
    }
  }

  @override
  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final response = await _dioClient.post(
        ApiEndpoints.register,
        data: request.toJson(),
      );
      return AuthResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw e.error ?? e;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _dioClient.post(ApiEndpoints.logout);
    } catch (_) {
      // Ignore network errors on logout
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      await _dioClient.post(
        ApiEndpoints.forgotPassword,
        data: {'email': email},
      );
    } on DioException catch (e) {
      throw e.error ?? e;
    }
  }

  @override
  Future<void> resetPassword(String email, String code, String newPassword) async {
    try {
      await _dioClient.post(
        ApiEndpoints.resetPassword,
        data: {
          'email': email,
          'code': code,
          'new_password': newPassword,
        },
      );
    } on DioException catch (e) {
      throw e.error ?? e;
    }
  }

  @override
  Future<void> verifyEmail(String email, String code) async {
    try {
      await _dioClient.post(
        ApiEndpoints.verifyEmail,
        data: {
          'email': email,
          'code': code,
        },
      );
    } on DioException catch (e) {
      throw e.error ?? e;
    }
  }

  @override
  Future<UserModel> me() async {
    try {
      final response = await _dioClient.get(ApiEndpoints.me);
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw e.error ?? e;
    }
  }
}
