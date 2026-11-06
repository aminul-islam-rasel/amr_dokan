import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/app_exception.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_controller.dart';

final registerControllerProvider =
    StateNotifierProvider.autoDispose<RegisterController, AsyncValue<UserEntity?>>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  final authNotifier = ref.watch(authStateProvider.notifier);
  return RegisterController(repo, authNotifier);
});

class RegisterController extends StateNotifier<AsyncValue<UserEntity?>> {
  final AuthRepository _repository;
  final AuthController _authNotifier;

  RegisterController(this._repository, this._authNotifier)
      : super(const AsyncValue.data(null));

  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      final user = await _repository.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
      );
      _authNotifier.setUser(user);
      state = AsyncValue.data(user);
      return true;
    } catch (e, st) {
      String msg = 'রেজিস্ট্রেশন করতে সমস্যা হয়েছে। অনুগ্রহ করে আবার চেষ্টা করুন।';
      if (e is AppException) {
        msg = e.message;
      }
      state = AsyncValue.error(msg, st);
      return false;
    }
  }
}
