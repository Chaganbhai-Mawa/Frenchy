import 'cefr_level.dart';
import 'user_progress.dart';

/// An achievement definition plus its unlock rule, evaluated locally
/// against [UserProgress].
class Achievement {
  const Achievement({
    required this.id,
    required this.emoji,
    required this.title,
    required this.description,
    required this.isUnlocked,
  });

  final String id;
  final String emoji;
  final String title;
  final String description;
  final bool Function(UserProgress progress, DateTime now) isUnlocked;
}

/// The full local achievement catalog.
abstract final class AchievementCatalog {
  static final List<Achievement> all = [
    Achievement(
      id: 'first_step',
      emoji: '🌱',
      title: 'First Step',
      description: 'Complete your first lesson.',
      isUnlocked: (p, _) => p.completedLessons.isNotEmpty,
    ),
    Achievement(
      id: 'week_warrior',
      emoji: '🔥',
      title: 'Week Warrior',
      description: 'Keep a 7-day streak.',
      isUnlocked: (p, now) => p.streak(now) >= 7,
    ),
    Achievement(
      id: 'month_master',
      emoji: '🌟',
      title: 'Month Master',
      description: 'Keep a 30-day streak.',
      isUnlocked: (p, now) => p.streak(now) >= 30,
    ),
    Achievement(
      id: 'word_collector',
      emoji: '📚',
      title: 'Word Collector',
      description: 'Practice 100 vocabulary words.',
      isUnlocked: (p, _) => (p.skillCounts['vocabulary'] ?? 0) >= 100,
    ),
    Achievement(
      id: 'good_listener',
      emoji: '🎧',
      title: 'Good Listener',
      description: 'Complete 50 listening exercises.',
      isUnlocked: (p, _) => (p.skillCounts['listening'] ?? 0) >= 50,
    ),
    Achievement(
      id: 'first_conversation',
      emoji: '🎤',
      title: 'First Conversation',
      description: 'Complete your first speaking exercise.',
      isUnlocked: (p, _) => (p.skillCounts['speaking'] ?? 0) >= 1,
    ),
    Achievement(
      id: 'bookworm',
      emoji: '📖',
      title: 'Bookworm',
      description: 'Complete 25 reading exercises.',
      isUnlocked: (p, _) => (p.skillCounts['reading'] ?? 0) >= 25,
    ),
    Achievement(
      id: 'quiz_champion',
      emoji: '🏆',
      title: 'Quiz Champion',
      description: 'Complete 20 quizzes.',
      isUnlocked: (p, _) => (p.skillCounts['quiz'] ?? 0) >= 20,
    ),
    Achievement(
      id: 'xp_1000',
      emoji: '⚡',
      title: 'Rising Star',
      description: 'Earn 1 000 XP.',
      isUnlocked: (p, _) => p.xp >= 1000,
    ),
    Achievement(
      id: 'french_explorer',
      emoji: '🇫🇷',
      title: 'French Explorer',
      description: 'Finish A1 and reach A2.',
      isUnlocked: (p, _) => p.level.index >= CefrLevel.a2.index,
    ),
    Achievement(
      id: 'intermediate_iron',
      emoji: '🥈',
      title: 'Solid Intermediate',
      description: 'Reach B1.',
      isUnlocked: (p, _) => p.level.index >= CefrLevel.b1.index,
    ),
    Achievement(
      id: 'french_expert',
      emoji: '🥇',
      title: 'French Expert',
      description: 'Reach C2 — mastery level.',
      isUnlocked: (p, _) => p.level.index >= CefrLevel.c2.index,
    ),
    Achievement(
      id: 'ten_lessons',
      emoji: '🎓',
      title: 'Dedicated Student',
      description: 'Complete 10 lessons.',
      isUnlocked: (p, _) => p.completedLessons.length >= 10,
    ),
  ];

  /// Achievements newly satisfied but not yet recorded in [progress].
  static List<Achievement> newlyUnlocked(UserProgress progress, DateTime now) =>
      all
          .where(
            (a) =>
                !progress.unlockedAchievements.containsKey(a.id) &&
                a.isUnlocked(progress, now),
          )
          .toList();
}
