import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Outcome of a speech attempt. We deliberately report *transcription
/// similarity*, not phonetic accuracy — the device API cannot measure true
/// pronunciation quality and we must not pretend it can.
class SpeechAttempt {
  const SpeechAttempt({
    required this.transcript,
    required this.similarity,
    this.error,
  });

  final String transcript;

  /// 0.0–1.0 similarity between expected phrase and what was recognized.
  final double similarity;
  final String? error;

  bool get succeeded => error == null;
}

enum SpeechStatus { idle, listening, unavailable, denied }

/// Wraps platform speech recognition (fr-FR) with full error handling:
/// permission denied, unavailable, no speech, timeout — never crashes.
class SpeechService {
  final SpeechToText _speech = SpeechToText();
  bool _initialized = false;
  bool _available = false;

  Future<bool> initialize() async {
    if (_initialized) return _available;
    try {
      _available = await _speech.initialize(
        onError: (SpeechRecognitionError error) {},
        finalTimeout: const Duration(seconds: 5),
      );
    } catch (_) {
      _available = false;
    }
    _initialized = true;
    return _available;
  }

  bool get isAvailable => _available;
  bool get isListening => _speech.isListening;

  /// Listens for one utterance and resolves with the final transcript.
  Future<SpeechAttempt> listenFor(
    String expected, {
    void Function(String partial)? onPartial,
  }) async {
    final ready = await initialize();
    if (!ready) {
      return const SpeechAttempt(
        transcript: '',
        similarity: 0,
        error:
            'Speech recognition is not available on this device. '
            'You can still practice by listening and repeating.',
      );
    }

    String finalTranscript = '';
    try {
      await _speech.listen(
        listenOptions: SpeechListenOptions(
          localeId: 'fr_FR',
          listenFor: const Duration(seconds: 8),
          pauseFor: const Duration(seconds: 3),
          partialResults: true,
        ),
        onResult: (SpeechRecognitionResult result) {
          finalTranscript = result.recognizedWords;
          onPartial?.call(result.recognizedWords);
        },
      );
      // Wait until the engine stops (final result or timeout).
      while (_speech.isListening) {
        await Future<void>.delayed(const Duration(milliseconds: 200));
      }
    } catch (_) {
      return const SpeechAttempt(
        transcript: '',
        similarity: 0,
        error: 'Something went wrong with the microphone. Please try again.',
      );
    }

    if (finalTranscript.trim().isEmpty) {
      return const SpeechAttempt(
        transcript: '',
        similarity: 0,
        error: "We didn't hear anything. Try speaking a little louder.",
      );
    }
    return SpeechAttempt(
      transcript: finalTranscript,
      similarity: similarityScore(expected, finalTranscript),
    );
  }

  Future<void> stop() async {
    try {
      await _speech.stop();
    } catch (_) {}
  }

  /// Word-level similarity between expected and recognized text (0–1),
  /// accent- and punctuation-insensitive.
  static double similarityScore(String expected, String actual) {
    final expWords = _normalize(expected).split(' ')
      ..removeWhere((w) => w.isEmpty);
    final actWords = _normalize(actual).split(' ')
      ..removeWhere((w) => w.isEmpty);
    if (expWords.isEmpty) return 0;
    if (actWords.isEmpty) return 0;

    var matched = 0;
    final remaining = List<String>.from(actWords);
    for (final word in expWords) {
      final idx = remaining.indexWhere(
        (w) => w == word || _editDistance(w, word) <= (word.length > 4 ? 1 : 0),
      );
      if (idx >= 0) {
        matched++;
        remaining.removeAt(idx);
      }
    }
    return matched / expWords.length;
  }

  static String _normalize(String text) => text
      .toLowerCase()
      .replaceAll(RegExp(r"[’']"), ' ')
      .replaceAll(RegExp(r'[^a-zà-ÿœæ\s-]'), '')
      .replaceAll('-', ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  static int _editDistance(String a, String b) {
    if (a == b) return 0;
    final m = a.length, n = b.length;
    if (m == 0) return n;
    if (n == 0) return m;
    var prev = List<int>.generate(n + 1, (i) => i);
    for (var i = 1; i <= m; i++) {
      final curr = List<int>.filled(n + 1, 0)..[0] = i;
      for (var j = 1; j <= n; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        curr[j] = [
          curr[j - 1] + 1,
          prev[j] + 1,
          prev[j - 1] + cost,
        ].reduce((x, y) => x < y ? x : y);
      }
      prev = curr;
    }
    return prev[n];
  }
}
