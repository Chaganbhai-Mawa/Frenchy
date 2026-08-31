import 'dart:convert';

import '../../core/services/key_value_store.dart';
import '../models/app_settings.dart';

abstract class SettingsRepository {
  Future<AppSettings> getSettings();
  Future<void> saveSettings(AppSettings settings);
}

class LocalSettingsRepository implements SettingsRepository {
  LocalSettingsRepository(this._store);

  static const String _key = 'app_settings_v1';
  final KeyValueStore _store;

  @override
  Future<AppSettings> getSettings() async {
    try {
      final raw = await _store.getString(_key);
      if (raw == null) return const AppSettings();
      return AppSettings.fromJson(json.decode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const AppSettings();
    }
  }

  @override
  Future<void> saveSettings(AppSettings settings) =>
      _store.setString(_key, json.encode(settings.toJson()));
}
