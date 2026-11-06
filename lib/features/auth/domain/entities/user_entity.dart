import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final bool isEmailVerified;
  final String? activeShopId;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.isEmailVerified,
    this.activeShopId,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        role,
        isEmailVerified,
        activeShopId,
      ];
}
