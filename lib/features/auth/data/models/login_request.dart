class LoginRequest {
  final String emailOrPhone;
  final String password;

  LoginRequest({
    required this.emailOrPhone,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    final trimmed = emailOrPhone.trim();
    final isEmail = trimmed.contains('@');
    return {
      'username': trimmed,
      'email_or_phone': trimmed,
      'email': isEmail ? trimmed : trimmed,
      'phone': !isEmail ? trimmed : null,
      'password': password,
    };
  }
}
