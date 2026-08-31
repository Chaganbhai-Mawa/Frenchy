import 'package:flutter_test/flutter_test.dart';
import 'package:frenchly/core/utils/answer_checker.dart';

void main() {
  group('AnswerChecker', () {
    test('exact match is correct', () {
      expect(
        AnswerChecker.check('Bonjour, monsieur.', 'Bonjour, monsieur.'),
        AnswerVerdict.correct,
      );
    });

    test('case and punctuation are ignored', () {
      expect(
        AnswerChecker.check('bonjour monsieur', 'Bonjour, monsieur.'),
        AnswerVerdict.correct,
      );
      expect(
        AnswerChecker.check('  Ça va ?  ', 'Ça va ?'),
        AnswerVerdict.correct,
      );
    });

    test('missing accents count as almost-correct', () {
      expect(
        AnswerChecker.check('Ca va tres bien', 'Ça va très bien'),
        AnswerVerdict.almostAccents,
      );
    });

    test('curly and straight apostrophes are equivalent', () {
      expect(
        AnswerChecker.check("s'il vous plaît", 's’il vous plaît'),
        AnswerVerdict.correct,
      );
    });

    test('wrong answer is incorrect', () {
      expect(
        AnswerChecker.check('Bonsoir', 'Bonjour'),
        AnswerVerdict.incorrect,
      );
      expect(AnswerChecker.check('', 'Bonjour'), AnswerVerdict.incorrect);
    });

    test('accepts alternative answers', () {
      expect(
        AnswerChecker.check('et toi', 'Et toi ?', alsoAccepted: ['et toi']),
        AnswerVerdict.correct,
      );
    });
  });
}
