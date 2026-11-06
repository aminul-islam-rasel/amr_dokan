import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/app_exception.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';

final verifyEmailControllerProvider =
    StateNotifierProvider.autoDispose<VerifyEmailController, AsyncValue<bool>>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return VerifyEmailController(repo);
});

class VerifyEmailController extends StateNotifier<AsyncValue<bool>> {
  final AuthRepository _repository;

  VerifyEmailController(this._repository) : super(const AsyncValue.data(false));

  Future<bool> verifyEmail({
    required String email,
    required String code,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _repository.verifyEmail(email: email, code: code);
      state = const AsyncValue.data(true);
      return true;
    } catch (e, st) {
      String msg = 'ইমেইল ভেরিফিকেশন ব্যর্থ হয়েছে। সঠিক ওটিপি দিন।';
      if (e is AppException) msg = e.message;
      state = AsyncValue.error(msg, st);
      return false;
    }
  }

  Future<bool> resendCode(String email) async {
    try {
      await _repository.forgotPassword(email: email);
      return true;
    } catch (_) {
      return false;
    }
  }
}
