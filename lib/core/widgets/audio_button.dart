import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';

/// Speaker button that plays French text via TTS. Shows a subtle pulse
/// while speaking. Falls back to a friendly message when no French voice
/// is installed.
class AudioButton extends ConsumerWidget {
  const AudioButton({
    super.key,
    required this.text,
    this.size = 28,
    this.slow = false,
  });

  final String text;
  final double size;

  /// Play at reduced rate ("turtle" replay).
  final bool slow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tts = ref.watch(ttsProvider);
    final settings = ref.watch(settingsProvider);

    return ValueListenableBuilder<bool>(
      valueListenable: tts.isSpeaking,
      builder: (context, speaking, _) => IconButton(
        iconSize: size,
        style: IconButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
        icon: Icon(slow ? Icons.slow_motion_video : Icons.volume_up_rounded),
        tooltip: slow ? 'Play slowly' : 'Play audio',
        onPressed: () {
          if (!settings.soundEnabled) return;
          if (!tts.isFrenchAvailable) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'No French voice is installed on this device. '
                  'You can add one in your system text-to-speech settings.',
                ),
              ),
            );
            return;
          }
          tts.speak(text, rate: slow ? 0.3 : settings.speechRate);
        },
      ),
    );
  }
}
