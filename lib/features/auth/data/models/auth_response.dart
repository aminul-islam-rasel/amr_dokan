import 'auth_tokens_model.dart';
import 'user_model.dart';

class AuthResponse {
  final UserModel user;
  final AuthTokensModel tokens;

  AuthResponse({
    required this.user,
    required this.tokens,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: UserModel.fromJson(json['user'] ?? json),
      tokens: AuthTokensModel.fromJson(json['tokens'] ?? json),
    );
  }
}
