// Stockage en mémoire comme fallback pour SharedPreferences
class MemoryStorage {
  static final Map<String, dynamic> _storage = {};

  static void setString(String key, String value) {
    _storage[key] = value;
  }

  static String? getString(String key) {
    return _storage[key] as String?;
  }

  static void setBool(String key, bool value) {
    _storage[key] = value;
  }

  static bool? getBool(String key) {
    return _storage[key] as bool?;
  }

  static void remove(String key) {
    _storage.remove(key);
  }

  static void clear() {
    _storage.clear();
  }
}
