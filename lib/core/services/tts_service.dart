import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Wraps device text-to-speech configured for French. All lesson audio is
/// produced with TTS in v1; bundled recordings can replace it later behind
/// this same interface.
class TtsService {
  TtsService() {
    _init();
  }

  final FlutterTts _tts = FlutterTts();
  bool _available = false;
  bool _initialized = false;

  final ValueNotifier<bool> isSpeaking = ValueNotifier(false);

  Future<void> _init() async {
    try {
      final languages = await _tts.getLanguages;
      final hasFrench =
          languages is List &&
          languages.any((l) => l.toString().toLowerCase().startsWith('fr'));
      if (hasFrench) {
        await _tts.setLanguage('fr-FR');
        _available = true;
      }
      await _tts.setSpeechRate(0.45);
      await _tts.setPitch(1.0);
      _tts.setCompletionHandler(() => isSpeaking.value = false);
      _tts.setCancelHandler(() => isSpeaking.value = false);
      _tts.setErrorHandler((_) => isSpeaking.value = false);
    } catch (_) {
      _available = false;
    }
    _initialized = true;
  }

  /// Whether a French voice is available on this device.
  bool get isFrenchAvailable => _available;

  Future<void> setRate(double rate) async {
    try {
      await _tts.setSpeechRate(rate.clamp(0.2, 0.8));
    } catch (_) {
      // Ignore: rate is a nice-to-have.
    }
  }

  /// Speaks [text] in French. Silently no-ops when TTS is unavailable —
  /// callers surface availability through [isFrenchAvailable].
  Future<void> speak(String text, {double? rate}) async {
    if (!_initialized) await _init();
    if (!_available || text.trim().isEmpty) return;
    try {
      await _tts.stop();
      if (rate != null) await setRate(rate);
      isSpeaking.value = true;
      await _tts.speak(text);
    } catch (_) {
      isSpeaking.value = false;
    }
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (_) {}
    isSpeaking.value = false;
  }

  void dispose() {
    _tts.stop();
    isSpeaking.dispose();
  }
}
