/// Application-wide constants.
///
/// The app name is a development placeholder — reference it from here only,
/// never hard-code it in widgets, so the product can be renamed later.
abstract final class AppConstants {
  static const String appName = 'Bonjourney';
  static const String tagline = 'Your personal French guide';
  static const String version = '1.0.0';

  // XP rewards — the single source of truth for the XP table
  // (see lesson_engine.dart `sectionXp` and docs/architecture.md).
  static const int xpLesson = 100;
  static const int xpLearnSection = 10;
  static const int xpVocabulary = 10;
  static const int xpListening = 20;
  static const int xpSpeaking = 30;
  static const int xpReading = 20;
  static const int xpWriting = 30;
  static const int xpVideo = 15;
  static const int xpPractice = 20;
  static const int xpQuiz = 25;
  static const int xpReview = 10;
  static const int xpDailyGoal = 50;
  static const int xpDailyChallenge = 100;
  static const int xpReviewWord = 5;
  static const int xpMistakeCleared = 10;

  /// Repeating a completed lesson earns a reduced reward to prevent farming.
  static const int xpLessonRepeat = 20;

  static const int defaultDailyGoalMinutes = 10;
  static const List<int> dailyGoalOptions = [5, 10, 15, 20, 30];
}
