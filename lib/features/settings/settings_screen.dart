import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/constants/app_constants.dart';
import '../../app/providers.dart';
import '../../app/theme/app_dimensions.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        children: [
          const _SectionHeader('Learning'),
          ListTile(
            leading: const Icon(Icons.flag_rounded),
            title: const Text('Daily goal'),
            subtitle: Text('${settings.dailyGoalMinutes} minutes per day'),
            trailing: DropdownButton<int>(
              value: settings.dailyGoalMinutes,
              underline: const SizedBox.shrink(),
              items: [
                for (final minutes in AppConstants.dailyGoalOptions)
                  DropdownMenuItem(value: minutes, child: Text('$minutes min')),
              ],
              onChanged: (minutes) {
                if (minutes != null) {
                  notifier.update((s) => s.copyWith(dailyGoalMinutes: minutes));
                }
              },
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.translate_rounded),
            title: const Text('Show translations'),
            subtitle: const Text('Turn off for a French-first experience'),
            value: settings.showTranslations,
            onChanged: (value) =>
                notifier.update((s) => s.copyWith(showTranslations: value)),
          ),
          const _SectionHeader('Audio'),
          SwitchListTile(
            secondary: const Icon(Icons.volume_up_rounded),
            title: const Text('Sound'),
            subtitle: const Text('French audio via text-to-speech'),
            value: settings.soundEnabled,
            onChanged: (value) =>
                notifier.update((s) => s.copyWith(soundEnabled: value)),
          ),
          ListTile(
            leading: const Icon(Icons.speed_rounded),
            title: const Text('Voice speed'),
            subtitle: Slider(
              value: settings.speechRate,
              min: 0.3,
              max: 0.7,
              divisions: 4,
              label: settings.speechRate <= 0.35
                  ? 'Slow'
                  : settings.speechRate >= 0.6
                  ? 'Natural'
                  : 'Learner',
              onChanged: (value) =>
                  notifier.update((s) => s.copyWith(speechRate: value)),
            ),
          ),
          const _SectionHeader('Appearance'),
          ListTile(
            leading: const Icon(Icons.dark_mode_rounded),
            title: const Text('Theme'),
            trailing: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                  value: ThemeMode.light,
                  icon: Icon(Icons.light_mode_rounded, size: 18),
                ),
                ButtonSegment(
                  value: ThemeMode.system,
                  icon: Icon(Icons.brightness_auto_rounded, size: 18),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  icon: Icon(Icons.dark_mode_rounded, size: 18),
                ),
              ],
              selected: {settings.themeMode},
              onSelectionChanged: (selection) => notifier.update(
                (s) => s.copyWith(themeMode: selection.first),
              ),
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.animation_rounded),
            title: const Text('Reduce animations'),
            subtitle: const Text('Fewer motion effects'),
            value: settings.reducedAnimations,
            onChanged: (value) =>
                notifier.update((s) => s.copyWith(reducedAnimations: value)),
          ),
          const _SectionHeader('Profile'),
          ListTile(
            leading: const Icon(Icons.person_rounded),
            title: const Text('Name'),
            subtitle: Text(settings.name.isEmpty ? 'Not set' : settings.name),
            trailing: const Icon(Icons.edit_rounded, size: 18),
            onTap: () => _editName(context, ref),
          ),
          const _SectionHeader('Data'),
          ListTile(
            leading: Icon(
              Icons.restart_alt_rounded,
              color: theme.colorScheme.error,
            ),
            title: Text(
              'Reset all progress',
              style: TextStyle(color: theme.colorScheme.error),
            ),
            subtitle: const Text(
              'Deletes XP, streaks, completed lessons and vocabulary history',
            ),
            onTap: () => _confirmReset(context, ref),
          ),
          const SizedBox(height: AppSpacing.md),
          Center(
            child: Text(
              '${AppConstants.appName} ${AppConstants.version} · '
              'All data stays on your device',
              style: theme.textTheme.labelSmall,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  Future<void> _editName(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController(
      text: ref.read(settingsProvider).name,
    );
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Your name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (name != null) {
      await ref
          .read(settingsProvider.notifier)
          .update((s) => s.copyWith(name: name));
    }
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset all progress ?'),
        content: const Text(
          'This deletes your XP, streak, completed lessons, mistakes and '
          'vocabulary history from this device. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep my progress'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reset everything'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(progressProvider.notifier).resetAll();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Progress reset. Fresh start — bonne chance !'),
          ),
        );
      }
    }
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall,
      ),
    );
  }
}
