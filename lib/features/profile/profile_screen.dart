import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/constants/app_constants.dart';
import '../../app/providers.dart';
import '../../app/theme/app_dimensions.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/frenchly_logo.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    final progress = ref.watch(progressProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: AppSpacing.screen,
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    settings.name.isEmpty
                        ? '🇫🇷'
                        : settings.name.characters.first.toUpperCase(),
                    style: theme.textTheme.headlineLarge,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  settings.name.isEmpty ? 'French learner' : settings.name,
                  style: theme.textTheme.headlineSmall,
                ),
                Text(
                  '${progress.level.code} ${progress.level.label} · '
                  '${progress.xp} XP',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppCard(
            onTap: () => context.go('/profile/settings'),
            child: Row(
              children: [
                const Icon(Icons.settings_rounded),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text('Settings', style: theme.textTheme.titleMedium),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
          if (kDebugMode) ...[
            const SizedBox(height: AppSpacing.sm),
            AppCard(
              onTap: () => context.go('/profile/debug'),
              child: Row(
                children: [
                  const Icon(Icons.bug_report_rounded),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'Debug tools (dev build only)',
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const FrenchlyLogo(size: 36),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      'About ${AppConstants.appName}',
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${AppConstants.appName} ${AppConstants.version}\n'
                  '${AppConstants.tagline}\n\n'
                  'Everything you learn stays on your device: your progress, '
                  'streaks and vocabulary never leave your phone. Speech '
                  'recognition and text-to-speech use your device\'s own '
                  'services. Curated videos stream from the internet when '
                  'available and are always optional.',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
