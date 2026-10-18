import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  final SharedPreferencesAsync preferences;
  LocalStorageService(this.preferences);
  Future<bool> loadTheme() async =>
      await preferences.getBool('is_dark_mode') ?? false;
  Future<void> saveTheme(bool dark) =>
      preferences.setBool('is_dark_mode', dark);
}
