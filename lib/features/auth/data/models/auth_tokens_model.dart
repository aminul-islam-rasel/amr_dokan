class AuthTokensModel {
  final String accessToken;
  final String refreshToken;
  final String tokenType;

  AuthTokensModel({
    required this.accessToken,
    required this.refreshToken,
    this.tokenType = 'Bearer',
  });

  factory AuthTokensModel.fromJson(Map<String, dynamic> json) {
    return AuthTokensModel(
      accessToken: json['access_token'] ?? '',
      refreshToken: json['refresh_token'] ?? '',
      tokenType: json['token_type'] ?? 'Bearer',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'token_type': tokenType,
    };
  }
}
