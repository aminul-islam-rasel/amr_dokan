import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/app_exception.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_controller.dart';

final loginControllerProvider =
    StateNotifierProvider.autoDispose<LoginController, AsyncValue<UserEntity?>>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  final authNotifier = ref.watch(authStateProvider.notifier);
  return LoginController(repo, authNotifier);
});

class LoginController extends StateNotifier<AsyncValue<UserEntity?>> {
  final AuthRepository _repository;
  final AuthController _authNotifier;

  LoginController(this._repository, this._authNotifier)
      : super(const AsyncValue.data(null));

  Future<bool> login({
    required String emailOrPhone,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.login(
        emailOrPhone: emailOrPhone,
        password: password,
      );
      _authNotifier.setUser(user);
      state = AsyncValue.data(user);
      return true;
    } catch (e, st) {
      String msg = 'লগইন ব্যর্থ হয়েছে। তথ্য পরীক্ষা করে আবার চেষ্টা করুন।';
      if (e is AppException) {
        msg = e.message;
      }
      state = AsyncValue.error(msg, st);
      return false;
    }
  }
}
