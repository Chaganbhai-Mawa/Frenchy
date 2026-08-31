import 'dart:convert';

import '../../core/services/key_value_store.dart';
import '../models/srs_entry.dart';

/// Stores the spaced-repetition schedule for all encountered words.
abstract class SrsRepository {
  Future<Map<String, SrsEntry>> getAll();
  Future<void> saveAll(Map<String, SrsEntry> entries);
  Future<void> reset();
}

class LocalSrsRepository implements SrsRepository {
  LocalSrsRepository(this._store);

  static const String _key = 'srs_entries_v1';
  final KeyValueStore _store;

  @override
  Future<Map<String, SrsEntry>> getAll() async {
    try {
      final raw = await _store.getString(_key);
      if (raw == null) return {};
      final list = json.decode(raw) as List;
      return {
        for (final item in list.whereType<Map<String, dynamic>>())
          (item['wordId'] as String): SrsEntry.fromJson(item),
      };
    } catch (_) {
      return {};
    }
  }

  @override
  Future<void> saveAll(Map<String, SrsEntry> entries) => _store.setString(
    _key,
    json.encode(entries.values.map((e) => e.toJson()).toList()),
  );

  @override
  Future<void> reset() => _store.remove(_key);
}
