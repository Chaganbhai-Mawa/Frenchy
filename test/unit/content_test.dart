import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:frenchly/data/models/course.dart';
import 'package:frenchly/data/models/exercise.dart';
import 'package:frenchly/data/models/lesson.dart';
import 'package:frenchly/data/models/video_content.dart';

/// Validates every bundled unit file against the content contract the
/// lesson engine relies on. Catches authoring regressions before runtime.
void main() {
  final unitFiles = <File>[];
  for (final dir in Directory('assets/content').listSync().whereType<Directory>()) {
    unitFiles.addAll(
      dir.listSync().whereType<File>().where(
        (f) => f.uri.pathSegments.last.startsWith('unit_'),
      ),
    );
  }
  unitFiles.sort((a, b) => a.path.compareTo(b.path));

  test('the A1 course ships its full unit set', () {
    expect(
      unitFiles.where((f) => f.path.contains('a1')).length,
      greaterThanOrEqualTo(10),
    );
  });

  for (final file in unitFiles) {
    final segments = file.uri.pathSegments;
    group('${segments[segments.length - 2]}/${segments.last}', () {
      late CourseUnit unit;

      setUpAll(() {
        unit = CourseUnit.fromJson(
          json.decode(file.readAsStringSync()) as Map<String, dynamic>,
        );
      });

      test('parses with lessons and required sections', () {
        expect(unit.lessons, isNotEmpty);
        final levelDir = segments[segments.length - 2];
        for (final lesson in unit.lessons) {
          expect(lesson.id, startsWith('${levelDir}_u'));
          expect(lesson.sections, isNotEmpty);
          final types = lesson.sections.map((s) => s.type).toSet();
          expect(types, contains(SectionType.vocabulary));
          expect(types, contains(SectionType.quiz));
          expect(types, contains(SectionType.listening));
          expect(types, contains(SectionType.reading));
        }
      });

      test('choice exercises always contain their answer as an option', () {
        for (final lesson in unit.lessons) {
          for (final section in lesson.sections) {
            final exercises = [
              ...section.exercises,
              for (final passage in section.passage) ...passage.questions,
            ];
            for (final exercise in exercises) {
              if (exercise.type == ExerciseType.multipleChoice ||
                  exercise.type == ExerciseType.listenChoose ||
                  exercise.type == ExerciseType.trueFalse) {
                expect(
                  exercise.options,
                  contains(exercise.answer),
                  reason: '${exercise.id} answer must be one of its options',
                );
              }
              if (exercise.type == ExerciseType.arrangeWords) {
                expect(
                  exercise.words,
                  isNotEmpty,
                  reason: '${exercise.id} needs a word bank',
                );
              }
              if (exercise.type == ExerciseType.match) {
                expect(
                  exercise.pairs.length,
                  greaterThanOrEqualTo(2),
                  reason: '${exercise.id} needs pairs',
                );
              }
            }
          }
        }
      });

      test('vocabulary entries are well-formed', () {
        for (final lesson in unit.lessons) {
          for (final item in lesson.allVocabulary) {
            expect(item.id, isNotEmpty);
            expect(item.french, isNotEmpty);
            expect(item.english, isNotEmpty);
            if (item.gender != null) {
              expect(['m', 'f'], contains(item.gender));
            }
          }
        }
      });
    });
  }

  test('exercise ids are unique across the whole course', () {
    final seen = <String>{};
    final duplicates = <String>[];
    for (final file in unitFiles) {
      final unit = CourseUnit.fromJson(
        json.decode(file.readAsStringSync()) as Map<String, dynamic>,
      );
      for (final lesson in unit.lessons) {
        for (final section in lesson.sections) {
          final exercises = [
            ...section.exercises,
            for (final passage in section.passage) ...passage.questions,
          ];
          for (final exercise in exercises) {
            if (exercise.id.isEmpty) continue;
            if (!seen.add(exercise.id)) duplicates.add(exercise.id);
          }
        }
      }
    }
    expect(duplicates, isEmpty);
  });

  test('video catalog parses and every video maps to a real unit', () {
    final raw = File('assets/content/videos.json').readAsStringSync();
    final videos = (json.decode(raw) as List)
        .whereType<Map<String, dynamic>>()
        .map(VideoContent.fromJson)
        .toList();
    expect(videos, isNotEmpty);
    final unitIds = {
      for (var i = 1; i <= 10; i++) 'a1_u${i.toString().padLeft(2, '0')}',
    };
    for (final video in videos) {
      expect(unitIds, contains(video.topic));
      expect(
        video.required,
        isFalse,
        reason: 'external videos must stay optional',
      );
      final info = VideoUrlParser.parse(video.url);
      expect(info.provider, VideoProvider.youtube);
      expect(info.videoId, isNotEmpty);
      for (final question in video.questions) {
        expect(question.options, contains(question.answer));
      }
    }
  });
}
