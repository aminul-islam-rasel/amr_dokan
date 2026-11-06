import '../../domain/entities/user_entity.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final bool isEmailVerified;
  final String? activeShopId;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.isEmailVerified,
    this.activeShopId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name'] ?? json['full_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? json['phone_number'] ?? '',
      role: json['role'] ?? 'owner',
      isEmailVerified: json['is_email_verified'] ?? json['is_verified'] ?? false,
      activeShopId: json['active_shop_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'is_email_verified': isEmailVerified,
      'active_shop_id': activeShopId,
    };
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      name: name,
      email: email,
      phone: phone,
      role: role,
      isEmailVerified: isEmailVerified,
      activeShopId: activeShopId,
    );
  }
}
