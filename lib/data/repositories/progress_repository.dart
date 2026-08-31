import 'dart:convert';

import '../../core/services/key_value_store.dart';
import '../models/user_progress.dart';

/// Persistence for learner progress. Interface-first so a cloud
/// implementation can be added without touching feature code.
abstract class ProgressRepository {
  Future<UserProgress> getProgress();
  Future<void> saveProgress(UserProgress progress);
  Future<void> reset();
}

class LocalProgressRepository implements ProgressRepository {
  LocalProgressRepository(this._store);

  static const String _key = 'user_progress_v1';
  final KeyValueStore _store;

  @override
  Future<UserProgress> getProgress() async {
    try {
      final raw = await _store.getString(_key);
      if (raw == null) return const UserProgress();
      return UserProgress.fromJson(json.decode(raw) as Map<String, dynamic>);
    } catch (_) {
      // Corrupt data must not brick the app; start fresh.
      return const UserProgress();
    }
  }

  @override
  Future<void> saveProgress(UserProgress progress) =>
      _store.setString(_key, json.encode(progress.toJson()));

  @override
  Future<void> reset() => _store.remove(_key);
}
