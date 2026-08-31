import 'dart:convert';

import '../../core/services/key_value_store.dart';
import '../models/mistake.dart';

/// The mistake notebook: wrong answers saved automatically for review.
abstract class MistakesRepository {
  Future<List<Mistake>> getAll();
  Future<void> add(Mistake mistake);
  Future<void> remove(String exerciseId);
  Future<void> reset();
}

class LocalMistakesRepository implements MistakesRepository {
  LocalMistakesRepository(this._store);

  static const String _key = 'mistakes_v1';
  static const int _maxEntries = 200;
  final KeyValueStore _store;

  @override
  Future<List<Mistake>> getAll() async {
    try {
      final raw = await _store.getString(_key);
      if (raw == null) return [];
      return (json.decode(raw) as List)
          .whereType<Map<String, dynamic>>()
          .map(Mistake.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> add(Mistake mistake) async {
    final all = await getAll();
    // Keep only the latest occurrence per exercise.
    all.removeWhere((m) => m.exerciseId == mistake.exerciseId);
    all.insert(0, mistake);
    if (all.length > _maxEntries) all.removeRange(_maxEntries, all.length);
    await _save(all);
  }

  @override
  Future<void> remove(String exerciseId) async {
    final all = await getAll();
    all.removeWhere((m) => m.exerciseId == exerciseId);
    await _save(all);
  }

  Future<void> _save(List<Mistake> all) =>
      _store.setString(_key, json.encode(all.map((m) => m.toJson()).toList()));

  @override
  Future<void> reset() => _store.remove(_key);
}
