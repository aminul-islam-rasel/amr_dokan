class RegisterRequest {
  final String name;
  final String email;
  final String phone;
  final String password;

  RegisterRequest({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'full_name': name,
      'email': email,
      'phone': phone,
      'phone_number': phone,
      'password': password,
    };
  }
}
