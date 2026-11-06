import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main.dart');
});

final sharedPrefsServiceProvider = Provider<SharedPrefsService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return SharedPrefsService(prefs);
});

class SharedPrefsService {
  final SharedPreferences _prefs;

  SharedPrefsService(this._prefs);

  String? getString(String key) => _prefs.getString(key);

  Future<bool> setString(String key, String value) => _prefs.setString(key, value);

  bool? getBool(String key) => _prefs.getBool(key);

  Future<bool> setBool(String key, bool value) => _prefs.setBool(key, value);

  int? getInt(String key) => _prefs.getInt(key);

  Future<bool> setInt(String key, int value) => _prefs.setInt(key, value);

  double? getDouble(String key) => _prefs.getDouble(key);

  Future<bool> setDouble(String key, double value) => _prefs.setDouble(key, value);

  Future<bool> remove(String key) => _prefs.remove(key);

  Future<bool> clear() => _prefs.clear();
}
