import 'package:flutter_test/flutter_test.dart';
import 'package:frenchly/data/models/srs_entry.dart';

void main() {
  final now = DateTime(2026, 8, 9, 12);

  group('SrsEntry', () {
    test('new entry is due immediately', () {
      const entry = SrsEntry(wordId: 'bonjour');
      expect(entry.isDue(now), isTrue);
      expect(entry.isLearned, isFalse);
    });

    test('correct answer promotes the box and schedules later review', () {
      const entry = SrsEntry(wordId: 'bonjour');
      final reviewed = entry.review(correct: true, now: now);
      expect(reviewed.box, 1);
      expect(reviewed.timesCorrect, 1);
      expect(reviewed.nextReview, now.add(const Duration(days: 1)));
      expect(reviewed.isDue(now), isFalse);
    });

    test('incorrect answer demotes and brings the word back sooner', () {
      const entry = SrsEntry(wordId: 'bonjour', box: 3);
      final reviewed = entry.review(correct: false, now: now);
      expect(reviewed.box, 2);
      expect(reviewed.timesIncorrect, 1);
      expect(reviewed.nextReview, now.add(const Duration(days: 3)));
    });

    test('box never exceeds max or drops below zero', () {
      const top = SrsEntry(wordId: 'a', box: SrsEntry.maxBox);
      expect(top.review(correct: true, now: now).box, SrsEntry.maxBox);
      const bottom = SrsEntry(wordId: 'b', box: 0);
      expect(bottom.review(correct: false, now: now).box, 0);
    });

    test('word becomes learned after two promotions', () {
      var entry = const SrsEntry(wordId: 'merci');
      entry = entry.review(correct: true, now: now);
      expect(entry.isLearned, isFalse);
      entry = entry.review(correct: true, now: now);
      expect(entry.isLearned, isTrue);
    });

    test('weak when incorrect answers outweigh correct ones', () {
      const entry = SrsEntry(wordId: 'x', timesCorrect: 1, timesIncorrect: 2);
      expect(entry.isWeak, isTrue);
      const strong = SrsEntry(wordId: 'y', timesCorrect: 5, timesIncorrect: 1);
      expect(strong.isWeak, isFalse);
    });

    test('round-trips through JSON', () {
      final entry = const SrsEntry(
        wordId: 'pain',
        box: 2,
        timesSeen: 4,
      ).review(correct: true, now: now);
      final restored = SrsEntry.fromJson(entry.toJson());
      expect(restored.wordId, 'pain');
      expect(restored.box, 3);
      expect(restored.nextReview, entry.nextReview);
    });
  });
}
