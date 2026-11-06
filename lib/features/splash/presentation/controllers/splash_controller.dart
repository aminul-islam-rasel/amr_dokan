import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/storage/shared_prefs_service.dart';

final splashControllerProvider =
    StateNotifierProvider<SplashController, AsyncValue<String>>((ref) {
  final secureStorage = ref.watch(secureStorageServiceProvider);
  final sharedPrefs = ref.watch(sharedPrefsServiceProvider);
  return SplashController(secureStorage, sharedPrefs);
});

class SplashController extends StateNotifier<AsyncValue<String>> {
  final SecureStorageService _secureStorage;
  final SharedPrefsService _sharedPrefs;

  SplashController(this._secureStorage, this._sharedPrefs)
      : super(const AsyncValue.loading());

  Future<void> initializeApp() async {
    state = const AsyncValue.loading();
    try {
      // Simulate min splash delay for brand animation smooth feeling
      await Future.delayed(const Duration(milliseconds: 1800));

      final isOnboardingCompleted =
          _sharedPrefs.getBool(AppConstants.prefKeyOnboardingCompleted) ?? false;

      if (!isOnboardingCompleted) {
        state = const AsyncValue.data('/onboarding');
        return;
      }

      final hasToken = await _secureStorage.hasAccessToken();
      if (hasToken) {
        state = const AsyncValue.data('/dashboard');
      } else {
        state = const AsyncValue.data('/login');
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
