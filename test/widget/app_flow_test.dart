import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frenchly/app/app.dart';
import 'package:frenchly/app/providers.dart';
import 'package:frenchly/core/services/key_value_store.dart';
import 'package:frenchly/data/models/app_settings.dart';
import 'package:frenchly/data/models/cefr_level.dart';
import 'package:frenchly/data/models/course.dart';
import 'package:frenchly/data/models/lesson.dart';
import 'package:frenchly/data/models/user_progress.dart';
import 'package:frenchly/data/repositories/course_repository.dart';

/// Serves pre-parsed course data synchronously. Asset I/O futures never
/// complete inside the fake-async test zone, so widget tests inject this
/// instead of the asset-backed repository.
class FakeCourseRepository implements CourseRepository {
  FakeCourseRepository(this.a1);

  final CourseLevel a1;

  @override
  Future<CourseLevel> loadLevel(CefrLevel level) async =>
      level == CefrLevel.a1 ? a1 : CourseLevel(level: level, units: const []);

  @override
  Future<Lesson?> findLesson(String lessonId) async {
    for (final unit in a1.units) {
      for (final lesson in unit.lessons) {
        if (lesson.id == lessonId) return lesson;
      }
    }
    return null;
  }
}

late FakeCourseRepository fakeCourse;

Widget buildApp({
  AppSettings settings = const AppSettings(),
  UserProgress progress = const UserProgress(),
}) {
  return ProviderScope(
    overrides: [
      keyValueStoreProvider.overrideWithValue(MemoryStore()),
      initialSettingsProvider.overrideWithValue(settings),
      initialProgressProvider.overrideWithValue(progress),
      courseRepositoryProvider.overrideWithValue(fakeCourse),
      // The ad SDK's platform channels aren't mocked in widget tests.
      adsEnabledProvider.overrideWithValue(false),
    ],
    child: const FrenchlyApp(),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Parse the real bundled content with plain file I/O (runs outside the
  // fake-async zone), so tests exercise genuine course data.
  setUpAll(() {
    final units = <CourseUnit>[];
    for (var i = 1; i <= 10; i++) {
      final file = File(
        'assets/content/a1/unit_${i.toString().padLeft(2, '0')}.json',
      );
      units.add(
        CourseUnit.fromJson(
          json.decode(file.readAsStringSync()) as Map<String, dynamic>,
        ),
      );
    }
    fakeCourse = FakeCourseRepository(
      CourseLevel(level: CefrLevel.a1, units: units),
    );
  });

  testWidgets('first launch shows splash then onboarding', (tester) async {
    await tester.pumpWidget(buildApp());
    expect(find.text('Bonjourney'), findsOneWidget);

    // Let the splash animation finish and navigate.
    await tester.pumpAndSettle(const Duration(seconds: 3));
    expect(find.textContaining('Learn French'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('returning user lands on home with greeting and navigation', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildApp(
        settings: const AppSettings(onboardingComplete: true, name: 'Mit'),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.text('Bonjour, Mit 👋'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Learn'), findsOneWidget);
    expect(find.text('Practice'), findsOneWidget);
    expect(find.text('Progress'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });

  testWidgets('learn tab lists the A1 units from bundled content', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildApp(settings: const AppSettings(onboardingComplete: true)),
    );
    await tester.pumpAndSettle(const Duration(seconds: 3));

    await tester.tap(find.text('Learn'));
    await tester.pumpAndSettle();

    expect(find.text('French Journey'), findsOneWidget);
    expect(find.textContaining('Greetings'), findsWidgets);
  });

  testWidgets('practice tab shows the review center', (tester) async {
    await tester.pumpWidget(
      buildApp(settings: const AppSettings(onboardingComplete: true)),
    );
    await tester.pumpAndSettle(const Duration(seconds: 3));

    await tester.tap(find.text('Practice'));
    await tester.pumpAndSettle();

    expect(find.text('Review Center'), findsOneWidget);
    expect(find.text('Due today'), findsOneWidget);
    expect(find.text('My mistakes'), findsOneWidget);
  });

  testWidgets('progress tab shows stats', (tester) async {
    await tester.pumpWidget(
      buildApp(
        settings: const AppSettings(onboardingComplete: true),
        progress: const UserProgress(xp: 320, activeDays: ['2026-08-09']),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 3));

    await tester.tap(find.text('Progress'));
    await tester.pumpAndSettle();

    expect(find.text('320'), findsOneWidget);
    expect(find.text('Total XP'), findsOneWidget);
    expect(find.text('Skills'), findsOneWidget);
  });
}
