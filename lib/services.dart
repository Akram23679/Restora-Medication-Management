import 'package:shared_preferences/shared_preferences.dart';

// ── Storage Service ───────────────────────────────────────────────────────────
class StorageService {
  static final instance = StorageService._();
  StorageService._();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  String? getString(String key) => _prefs?.getString(key);
  bool? getBool(String key) => _prefs?.getBool(key);

  Future<void> setString(String key, String value) async =>
      await _prefs?.setString(key, value);

  Future<void> setBool(String key, bool value) async =>
      await _prefs?.setBool(key, value);

  Future<void> remove(String key) async => await _prefs?.remove(key);

  Future<void> clearAll() async => await _prefs?.clear();
}