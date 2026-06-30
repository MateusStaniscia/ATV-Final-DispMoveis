abstract class SharedPreferencesService {
  Future<String?> getString(String key);
  Future<bool> setString(String key, String value);
  Future<bool> remove(String key);
  Future<bool> getBool(String key);
  Future<bool> setBool(String key, bool value);
}
