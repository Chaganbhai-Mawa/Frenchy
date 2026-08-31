/// Deterministic, client-side answer evaluation for typed exercises.
///
/// Rules (in order):
/// 1. Exact match after trimming + lowercasing + punctuation removal → correct.
/// 2. Match ignoring accents → "almost" (counts as correct with a gentle
///    reminder about accents).
/// 3. Otherwise incorrect.
enum AnswerVerdict { correct, almostAccents, incorrect }

abstract final class AnswerChecker {
  static AnswerVerdict check(
    String userInput,
    String expected, {
    List<String> alsoAccepted = const [],
  }) {
    final user = normalize(userInput);
    if (user.isEmpty) return AnswerVerdict.incorrect;

    for (final candidate in [expected, ...alsoAccepted]) {
      if (user == normalize(candidate)) return AnswerVerdict.correct;
    }
    for (final candidate in [expected, ...alsoAccepted]) {
      if (stripAccents(user) == stripAccents(normalize(candidate))) {
        return AnswerVerdict.almostAccents;
      }
    }
    return AnswerVerdict.incorrect;
  }

  /// Lowercase, unify apostrophes, drop punctuation, collapse whitespace.
  static String normalize(String text) => text
      .toLowerCase()
      .replaceAll('’', "'")
      .replaceAll(RegExp(r'[.,!?;:«»"()\[\]]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  static const Map<String, String> _accentMap = {
    'à': 'a',
    'â': 'a',
    'ä': 'a',
    'é': 'e',
    'è': 'e',
    'ê': 'e',
    'ë': 'e',
    'î': 'i',
    'ï': 'i',
    'ô': 'o',
    'ö': 'o',
    'ù': 'u',
    'û': 'u',
    'ü': 'u',
    'ç': 'c',
    'œ': 'oe',
    'æ': 'ae',
  };

  static String stripAccents(String text) {
    final buffer = StringBuffer();
    for (final rune in text.runes) {
      final char = String.fromCharCode(rune);
      buffer.write(_accentMap[char] ?? char);
    }
    return buffer.toString();
  }
}
