import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/cefr_level.dart';
import '../models/course.dart';
import '../models/lesson.dart';

/// Read access to course content. The local implementation loads bundled
/// JSON assets lazily (per level) so startup stays fast; a future cloud
/// implementation can serve downloadable course packs behind this interface.
abstract class CourseRepository {
  Future<CourseLevel> loadLevel(CefrLevel level);
  Future<Lesson?> findLesson(String lessonId);
}

class LocalCourseRepository implements CourseRepository {
  LocalCourseRepository({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;
  final Map<CefrLevel, CourseLevel> _cache = {};

  /// Unit files for a level, discovered from the asset manifest so new
  /// content packs need no code change: drop `unit_NN.json` into
  /// `assets/content/<level>/` and it appears in the course.
  Future<List<String>> _unitPathsFor(CefrLevel level) async {
    final prefix = 'assets/content/${level.code.toLowerCase()}/';
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(_bundle);
      final paths =
          manifest
              .listAssets()
              .where((p) => p.startsWith(prefix) && p.endsWith('.json'))
              .toList()
            ..sort();
      return paths;
    } catch (_) {
      // Manifest unavailable (e.g. some test harnesses): fall back to the
      // conventional numbering.
      return [
        for (var i = 1; i <= 40; i++)
          '$prefix'
              'unit_${i.toString().padLeft(2, '0')}.json',
      ];
    }
  }

  @override
  Future<CourseLevel> loadLevel(CefrLevel level) async {
    final cached = _cache[level];
    if (cached != null) return cached;

    final files = await _unitPathsFor(level);
    final units = <CourseUnit>[];
    for (final path in files) {
      try {
        final raw = await _bundle.loadString(path);
        units.add(
          CourseUnit.fromJson(json.decode(raw) as Map<String, dynamic>),
        );
      } catch (_) {
        // A malformed or missing unit must never take the app down; the
        // remaining units still load.
      }
    }
    units.sort((a, b) => a.unit.compareTo(b.unit));
    final result = CourseLevel(level: level, units: units);
    _cache[level] = result;
    return result;
  }

  @override
  Future<Lesson?> findLesson(String lessonId) async {
    // Lesson ids embed their level prefix (e.g. a1_u03_l02).
    final prefix = lessonId.split('_').first;
    final level = CefrLevel.fromCode(prefix);
    final courseLevel = await loadLevel(level);
    for (final unit in courseLevel.units) {
      for (final lesson in unit.lessons) {
        if (lesson.id == lessonId) return lesson;
      }
    }
    return null;
  }
}
