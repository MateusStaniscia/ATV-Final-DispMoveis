import 'package:shared_preferences/shared_preferences.dart';
import 'shared_preferences_service.dart';

class SharedPreferencesServiceImpl implements SharedPreferencesService {
  final SharedPreferences _prefs;

  const SharedPreferencesServiceImpl(this._prefs);

  @override
  Future<String?> getString(String key) async {
    return _prefs.getString(key);
  }

  @override
  Future<bool> setString(String key, String value) async {
    return _prefs.setString(key, value);
  }

  @override
  Future<bool> remove(String key) async {
    return _prefs.remove(key);
  }

  @override
  Future<bool> getBool(String key) async {
    return _prefs.getBool(key) ?? false;
  }

  @override
  Future<bool> setBool(String key, bool value) async {
    return _prefs.setBool(key, value);
  }
}
