import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/app_exception.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';

final forgotPasswordControllerProvider =
    StateNotifierProvider.autoDispose<ForgotPasswordController, AsyncValue<bool>>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return ForgotPasswordController(repo);
});

class ForgotPasswordController extends StateNotifier<AsyncValue<bool>> {
  final AuthRepository _repository;

  ForgotPasswordController(this._repository) : super(const AsyncValue.data(false));

  Future<bool> sendResetCode(String email) async {
    state = const AsyncValue.loading();
    try {
      await _repository.forgotPassword(email: email);
      state = const AsyncValue.data(true);
      return true;
    } catch (e, st) {
      String msg = 'কোড পাঠাতে ব্যর্থ হয়েছে।';
      if (e is AppException) msg = e.message;
      state = AsyncValue.error(msg, st);
      return false;
    }
  }

  Future<bool> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repository.resetPassword(
        email: email,
        code: code,
        newPassword: newPassword,
      );
      state = const AsyncValue.data(true);
      return true;
    } catch (e, st) {
      String msg = 'পাসওয়ার্ড পরিবর্তন করতে ব্যর্থ হয়েছে।';
      if (e is AppException) msg = e.message;
      state = AsyncValue.error(msg, st);
      return false;
    }
  }
}
