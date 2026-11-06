import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/repositories/auth_repository_impl.dart';

final authStateProvider = StateNotifierProvider<AuthController, AsyncValue<UserEntity?>>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthController(repo);
});

class AuthController extends StateNotifier<AsyncValue<UserEntity?>> {
  final AuthRepository _repository;

  AuthController(this._repository) : super(const AsyncValue.loading()) {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    try {
      final isAuth = await _repository.isAuthenticated();
      if (isAuth) {
        final user = await _repository.getCurrentUser();
        state = AsyncValue.data(user);
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void setUser(UserEntity user) {
    state = AsyncValue.data(user);
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    try {
      await _repository.logout();
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
