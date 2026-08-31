import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/providers.dart';
import '../../app/theme/app_dimensions.dart';

/// Developer-only tools. Reachable from Profile in debug builds ONLY —
/// the entry point is guarded by [kDebugMode] and this screen additionally
/// refuses to render in release builds.
class DebugScreen extends ConsumerWidget {
  const DebugScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!kDebugMode) {
      return const Scaffold(body: SizedBox.shrink());
    }
    final progress = ref.watch(progressProvider);
    final tts = ref.read(ttsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Debug tools')),
      body: ListView(
        padding: AppSpacing.screen,
        children: [
          Text(
            'XP: ${progress.xp} · lessons: ${progress.completedLessons.length}'
            ' · streak days: ${progress.activeDays.length}',
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton(
            onPressed: () => ref.read(progressProvider.notifier).addXp(100),
            child: const Text('Add 100 XP'),
          ),
          const SizedBox(height: AppSpacing.sm),
          FilledButton(
            onPressed: () => ref
                .read(progressProvider.notifier)
                .completeLesson('a1_u01_l01', 95),
            child: const Text('Complete lesson a1_u01_l01 (95%)'),
          ),
          const SizedBox(height: AppSpacing.sm),
          FilledButton(
            onPressed: () =>
                tts.speak('Bonjour ! Ceci est un test de la synthèse vocale.'),
            child: const Text('Test French TTS'),
          ),
          const SizedBox(height: AppSpacing.sm),
          FilledButton(
            onPressed: () async {
              final available = await ref.read(speechProvider).initialize();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Speech recognition available: $available'),
                  ),
                );
              }
            },
            child: const Text('Test speech recognition availability'),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton(
            onPressed: () => ref.read(progressProvider.notifier).resetAll(),
            child: const Text('Reset all progress'),
          ),
        ],
      ),
    );
  }
}
