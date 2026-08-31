import 'package:shared_preferences/shared_preferences.dart';

/// Thin persistence abstraction so repositories never depend on a concrete
/// storage backend (allows swapping SharedPreferences for a database or a
/// cloud-backed store later without touching feature code).
abstract class KeyValueStore {
  Future<String?> getString(String key);
  Future<void> setString(String key, String value);
  Future<void> remove(String key);
}

class SharedPrefsStore implements KeyValueStore {
  SharedPrefsStore(this._prefs);

  final SharedPreferences _prefs;

  static Future<SharedPrefsStore> create() async =>
      SharedPrefsStore(await SharedPreferences.getInstance());

  @override
  Future<String?> getString(String key) async => _prefs.getString(key);

  @override
  Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);

  @override
  Future<void> remove(String key) => _prefs.remove(key);
}

/// In-memory store for tests.
class MemoryStore implements KeyValueStore {
  final Map<String, String> _data = {};

  @override
  Future<String?> getString(String key) async => _data[key];

  @override
  Future<void> setString(String key, String value) async => _data[key] = value;

  @override
  Future<void> remove(String key) async => _data.remove(key);
}
