import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/constants/app_constants.dart';
import '../core/services/ads_service.dart';
import '../core/services/key_value_store.dart';
import '../core/services/speech_service.dart';
import '../core/services/tts_service.dart';
import '../data/models/achievement.dart';
import '../data/models/app_settings.dart';
import '../data/models/cefr_level.dart';
import '../data/models/course.dart';
import '../data/models/lesson.dart';
import '../data/models/mistake.dart';
import '../data/models/srs_entry.dart';
import '../data/models/user_progress.dart';
import '../data/models/video_content.dart';
import '../data/models/vocab_item.dart';
import '../data/repositories/course_repository.dart';
import '../data/repositories/mistakes_repository.dart';
import '../data/repositories/progress_repository.dart';
import '../data/repositories/settings_repository.dart';
import '../data/repositories/srs_repository.dart';

// ---------------------------------------------------------------------------
// Bootstrap: main() loads these before runApp and supplies them as overrides
// so the first frame renders with real data (no flash of loading state).
// ---------------------------------------------------------------------------

final keyValueStoreProvider = Provider<KeyValueStore>(
  (ref) => throw UnimplementedError('Overridden in main()'),
);

final initialSettingsProvider = Provider<AppSettings>(
  (ref) => const AppSettings(),
);

final initialProgressProvider = Provider<UserProgress>(
  (ref) => const UserProgress(),
);

/// AdMob ad managers (banner/interstitial/rewarded/app-open). Created in
/// main() so SDK initialization and ad preloading start before the first
/// frame, without blocking it.
final adsServiceProvider = Provider<AdsService>(
  (ref) => throw UnimplementedError('Overridden in main()'),
);

/// Master switch for every ad surface. True in production; overridden to
/// false in widget tests so they never touch the (unmocked) ad SDK's
/// platform channels.
final adsEnabledProvider = Provider<bool>((ref) => true);

// ---------------------------------------------------------------------------
// Repositories
// ---------------------------------------------------------------------------

final courseRepositoryProvider = Provider<CourseRepository>(
  (ref) => LocalCourseRepository(),
);

final progressRepositoryProvider = Provider<ProgressRepository>(
  (ref) => LocalProgressRepository(ref.watch(keyValueStoreProvider)),
);

final srsRepositoryProvider = Provider<SrsRepository>(
  (ref) => LocalSrsRepository(ref.watch(keyValueStoreProvider)),
);

final mistakesRepositoryProvider = Provider<MistakesRepository>(
  (ref) => LocalMistakesRepository(ref.watch(keyValueStoreProvider)),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => LocalSettingsRepository(ref.watch(keyValueStoreProvider)),
);

// ---------------------------------------------------------------------------
// Services
// ---------------------------------------------------------------------------

final ttsProvider = Provider<TtsService>((ref) {
  final tts = TtsService();
  ref.onDispose(tts.dispose);
  return tts;
});

final speechProvider = Provider<SpeechService>((ref) => SpeechService());

// ---------------------------------------------------------------------------
// Settings
// ---------------------------------------------------------------------------

class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() => ref.read(initialSettingsProvider);

  Future<void> update(AppSettings Function(AppSettings) transform) async {
    state = transform(state);
    await ref.read(settingsRepositoryProvider).saveSettings(state);
  }

  Future<void> toggleFavoriteWord(String wordId) => update(
    (s) => s.copyWith(
      favoriteWords: s.favoriteWords.contains(wordId)
          ? (List.of(s.favoriteWords)..remove(wordId))
          : [...s.favoriteWords, wordId],
    ),
  );

  Future<void> toggleFavoriteLesson(String lessonId) => update(
    (s) => s.copyWith(
      favoriteLessons: s.favoriteLessons.contains(lessonId)
          ? (List.of(s.favoriteLessons)..remove(lessonId))
          : [...s.favoriteLessons, lessonId],
    ),
  );
}

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);

// ---------------------------------------------------------------------------
// Progress
// ---------------------------------------------------------------------------

class ProgressNotifier extends Notifier<UserProgress> {
  @override
  UserProgress build() => ref.read(initialProgressProvider);

  Future<void> _persist() =>
      ref.read(progressRepositoryProvider).saveProgress(state);

  /// XP needed in one day to complete the daily challenge.
  static const int dailyChallengeXpTarget = 100;

  /// Adds XP and marks today active. Returns achievements newly unlocked by
  /// this update so callers can celebrate them. Automatically completes the
  /// daily challenge (earn [dailyChallengeXpTarget] XP today) with its bonus.
  Future<List<Achievement>> addXp(int amount, {DateTime? now}) async {
    final today = UserProgress.dayKey(now ?? DateTime.now());
    var xpToday = (state.xpByDay[today] ?? 0) + amount;
    var total = state.xp + amount;
    var challengeDay = state.dailyChallengeCompletedOn;
    if (challengeDay != today && xpToday >= dailyChallengeXpTarget) {
      // Challenge complete: award the bonus in the same update.
      xpToday += AppConstants.xpDailyChallenge;
      total += AppConstants.xpDailyChallenge;
      challengeDay = today;
    }
    state = state.copyWith(
      xp: total,
      activeDays: state.activeDays.contains(today)
          ? state.activeDays
          : [...state.activeDays, today],
      xpByDay: {...state.xpByDay, today: xpToday},
      dailyChallengeCompletedOn: challengeDay,
    );
    final unlocked = await _recordAchievements(now ?? DateTime.now());
    await _persist();
    return unlocked;
  }

  /// Records study time. Reaching the daily minutes goal awards
  /// [AppConstants.xpDailyGoal] once per day.
  Future<void> addMinutes(int minutes, {DateTime? now}) async {
    final today = UserProgress.dayKey(now ?? DateTime.now());
    final minutesToday = (state.minutesByDay[today] ?? 0) + minutes;
    state = state.copyWith(
      minutesByDay: {...state.minutesByDay, today: minutesToday},
      activeDays: state.activeDays.contains(today)
          ? state.activeDays
          : [...state.activeDays, today],
    );

    final goal = ref.read(settingsProvider).dailyGoalMinutes;
    if (state.dailyGoalCompletedOn != today && minutesToday >= goal) {
      state = state.copyWith(dailyGoalCompletedOn: today);
      await addXp(AppConstants.xpDailyGoal, now: now);
      return; // addXp persists.
    }
    await _persist();
  }

  Future<void> recordSkill(String skill, [int count = 1]) async {
    state = state.copyWith(
      skillCounts: {
        ...state.skillCounts,
        skill: (state.skillCounts[skill] ?? 0) + count,
      },
    );
    await _persist();
  }

  Future<void> markSectionDone(String lessonId, int sectionIndex) async {
    final current = state.sectionsDone(lessonId);
    if (current.contains(sectionIndex)) return;
    state = state.copyWith(
      sectionProgress: {
        ...state.sectionProgress,
        lessonId: {...current, sectionIndex},
      },
    );
    await _persist();
  }

  /// Marks a lesson complete with its quiz [score]. Keeps the best score.
  Future<List<Achievement>> completeLesson(
    String lessonId,
    int score, {
    DateTime? now,
  }) async {
    final previous = state.completedLessons[lessonId];
    state = state.copyWith(
      completedLessons: {
        ...state.completedLessons,
        lessonId: previous == null || score > previous ? score : previous,
      },
    );
    final unlocked = await _recordAchievements(now ?? DateTime.now());
    await _persist();
    return unlocked;
  }

  Future<void> saveVideoPosition(String videoId, int seconds) async {
    state = state.copyWith(
      videoPositions: {...state.videoPositions, videoId: seconds},
    );
    await _persist();
  }

  Future<void> completeDailyChallenge({DateTime? now}) async {
    state = state.copyWith(
      dailyChallengeCompletedOn: UserProgress.dayKey(now ?? DateTime.now()),
    );
    await _persist();
  }

  /// Sets the CEFR level and returns any achievements this unlocks
  /// (reaching A2, B1, C2…).
  Future<List<Achievement>> setLevel(CefrLevel level, {DateTime? now}) async {
    state = state.copyWith(level: level);
    final unlocked = await _recordAchievements(now ?? DateTime.now());
    await _persist();
    return unlocked;
  }

  /// Called after a lesson completes: when every lesson of the current
  /// level is done, the learner advances to the next level. Returns newly
  /// unlocked achievements (empty when no advancement happened).
  Future<List<Achievement>> maybeAdvanceLevel(
    List<String> allLessonIdsOfLevel,
  ) async {
    final next = state.level.next;
    if (next == null || allLessonIdsOfLevel.isEmpty) return const [];
    final allDone = allLessonIdsOfLevel.every(
      state.completedLessons.containsKey,
    );
    if (!allDone) return const [];
    return setLevel(next);
  }

  Future<List<Achievement>> _recordAchievements(DateTime now) async {
    final newly = AchievementCatalog.newlyUnlocked(state, now);
    if (newly.isEmpty) return const [];
    state = state.copyWith(
      unlockedAchievements: {
        ...state.unlockedAchievements,
        for (final a in newly) a.id: UserProgress.dayKey(now),
      },
    );
    return newly;
  }

  /// Unlocks a locked lesson ahead of its normal sequence — the reward for
  /// watching a rewarded or rewarded-interstitial ad.
  Future<void> unlockLessonWithAd(String lessonId) async {
    if (state.adUnlockedLessons.contains(lessonId)) return;
    state = state.copyWith(
      adUnlockedLessons: [...state.adUnlockedLessons, lessonId],
    );
    await _persist();
  }

  Future<void> resetAll() async {
    await ref.read(progressRepositoryProvider).reset();
    await ref.read(srsRepositoryProvider).reset();
    await ref.read(mistakesRepositoryProvider).reset();
    state = const UserProgress();
    ref.invalidate(srsProvider);
    ref.invalidate(mistakesProvider);
  }
}

final progressProvider = NotifierProvider<ProgressNotifier, UserProgress>(
  ProgressNotifier.new,
);

// ---------------------------------------------------------------------------
// Spaced repetition
// ---------------------------------------------------------------------------

class SrsNotifier extends AsyncNotifier<Map<String, SrsEntry>> {
  @override
  Future<Map<String, SrsEntry>> build() =>
      ref.read(srsRepositoryProvider).getAll();

  Future<void> reviewWord(String wordId, {required bool correct}) async {
    final entries = Map<String, SrsEntry>.from(state.valueOrNull ?? {});
    final now = DateTime.now();
    final entry = entries[wordId] ?? SrsEntry(wordId: wordId);
    entries[wordId] = entry.review(correct: correct, now: now);
    state = AsyncData(entries);
    await ref.read(srsRepositoryProvider).saveAll(entries);
  }
}

final srsProvider = AsyncNotifierProvider<SrsNotifier, Map<String, SrsEntry>>(
  SrsNotifier.new,
);

// ---------------------------------------------------------------------------
// Mistakes
// ---------------------------------------------------------------------------

class MistakesNotifier extends AsyncNotifier<List<Mistake>> {
  @override
  Future<List<Mistake>> build() =>
      ref.read(mistakesRepositoryProvider).getAll();

  Future<void> add(Mistake mistake) async {
    await ref.read(mistakesRepositoryProvider).add(mistake);
    state = AsyncData(await ref.read(mistakesRepositoryProvider).getAll());
  }

  Future<void> resolve(String exerciseId) async {
    await ref.read(mistakesRepositoryProvider).remove(exerciseId);
    state = AsyncData(await ref.read(mistakesRepositoryProvider).getAll());
  }
}

final mistakesProvider = AsyncNotifierProvider<MistakesNotifier, List<Mistake>>(
  MistakesNotifier.new,
);

// ---------------------------------------------------------------------------
// Course content
// ---------------------------------------------------------------------------

final courseLevelProvider = FutureProvider.family<CourseLevel, CefrLevel>(
  (ref, level) => ref.watch(courseRepositoryProvider).loadLevel(level),
);

final lessonProvider = FutureProvider.family<Lesson?, String>(
  (ref, id) => ref.watch(courseRepositoryProvider).findLesson(id),
);

/// Every vocabulary item across ALL levels, indexed by id.
///
/// Deliberately not limited to the learner's current level: words met at A1
/// keep their spaced-repetition schedule after advancing to A2, so the
/// review centre and vocabulary browser must still be able to resolve them.
/// Only read by the vocabulary/review screens, and levels are cached by the
/// repository, so this never runs at startup.
final vocabularyIndexProvider = FutureProvider<Map<String, VocabItem>>((
  ref,
) async {
  final index = <String, VocabItem>{};
  for (final level in CefrLevel.values) {
    final course = await ref.watch(courseLevelProvider(level).future);
    for (final unit in course.units) {
      for (final lesson in unit.lessons) {
        for (final item in lesson.allVocabulary) {
          index.putIfAbsent(item.id, () => item);
        }
      }
    }
  }
  return index;
});

/// Curated standalone video catalog (assets/content/videos.json).
final videoCatalogProvider = FutureProvider<List<VideoContent>>((ref) async {
  try {
    final raw = await rootBundle.loadString('assets/content/videos.json');
    return (json.decode(raw) as List)
        .whereType<Map<String, dynamic>>()
        .map(VideoContent.fromJson)
        .toList();
  } catch (_) {
    return const [];
  }
});
