import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/constants/app_constants.dart';
import '../../app/providers.dart';
import '../../app/theme/app_dimensions.dart';
import '../../core/widgets/app_card.dart';

class _OnboardingPage {
  const _OnboardingPage(this.emoji, this.title, this.body);

  final String emoji;
  final String title;
  final String body;
}

const _pages = [
  _OnboardingPage(
    '🇫🇷',
    'Learn French\nfrom zero to fluent',
    'Learn vocabulary, grammar, speaking and real conversations — step by step.',
  ),
  _OnboardingPage(
    '🎧',
    'Train your ear',
    'Listen to real French and understand naturally, from your very first lesson.',
  ),
  _OnboardingPage(
    '🎤',
    'Speak with confidence',
    'Practice pronunciation with your microphone and improve your speaking.',
  ),
  _OnboardingPage(
    '📚',
    'Your complete journey',
    'A1 → A2 → B1 → B2 → C1 → C2\nA structured path from beginner to mastery.',
  ),
];

/// First-launch experience: intro pages → name → level → daily goal → home.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  int _page = 0;
  int _goal = AppConstants.defaultDailyGoalMinutes;
  int _levelIndex = 0;

  // Intro pages + name/level page + goal page.
  int get _pageCount => _pages.length + 2;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < _pageCount - 1) {
      _pageController.nextPage(
        duration: AppAnimations.slow,
        curve: AppAnimations.curve,
      );
    } else {
      _finish();
    }
  }

  Future<void> _finish() async {
    await ref
        .read(settingsProvider.notifier)
        .update(
          (s) => s.copyWith(
            name: _nameController.text.trim(),
            dailyGoalMinutes: _goal,
            onboardingComplete: true,
          ),
        );
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: _page < _pages.length
                    ? TextButton(
                        onPressed: () => _pageController.animateToPage(
                          _pages.length,
                          duration: AppAnimations.slow,
                          curve: AppAnimations.curve,
                        ),
                        child: const Text('Skip'),
                      )
                    : const SizedBox(height: 48),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  for (final page in _pages) _IntroPage(page: page),
                  _LevelPage(
                    nameController: _nameController,
                    selectedIndex: _levelIndex,
                    onSelected: (i) => setState(() => _levelIndex = i),
                  ),
                  _GoalPage(
                    goal: _goal,
                    onChanged: (g) => setState(() => _goal = g),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pageCount,
                      (i) => AnimatedContainer(
                        duration: AppAnimations.normal,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: i == _page ? 22 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i == _page
                              ? theme.colorScheme.primary
                              : theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _next,
                      child: Text(
                        _page == _pageCount - 1 ? "Let's go !" : 'Continue',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IntroPage extends StatelessWidget {
  const _IntroPage({required this.page});

  final _OnboardingPage page;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(page.emoji, style: const TextStyle(fontSize: 72)),
          const SizedBox(height: AppSpacing.xl),
          Text(
            page.title,
            style: theme.textTheme.displayMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            page.body,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _LevelPage extends StatelessWidget {
  const _LevelPage({
    required this.nameController,
    required this.selectedIndex,
    required this.onSelected,
  });

  final TextEditingController nameController;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const _levels = [
    ('🌱', 'Complete beginner', "I don't know any French yet."),
    ('🙂', 'I know a few words', 'Bonjour, merci… and not much more.'),
    ('📗', 'Basic French', 'I can form simple sentences.'),
    ('📘', 'Intermediate', 'I can hold simple conversations.'),
    ('📙', 'Advanced', 'I understand most French.'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      children: [
        Text("What's your name?", style: theme.textTheme.headlineMedium),
        const SizedBox(height: AppSpacing.sm),
        TextField(
          controller: nameController,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: 'Your name (optional)'),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          "What's your French level?",
          style: theme.textTheme.headlineMedium,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Everyone starts with A1 in this version — knowing your level helps '
          'us pace your lessons.',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: AppSpacing.md),
        for (final (emoji, title, subtitle) in _levels)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _SelectableCard(
              emoji: emoji,
              title: title,
              subtitle: subtitle,
            ),
          ),
      ],
    );
  }
}

class _SelectableCard extends StatefulWidget {
  const _SelectableCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
  });

  final String emoji;
  final String title;
  final String subtitle;

  static String? selectedTitle = 'Complete beginner';

  @override
  State<_SelectableCard> createState() => _SelectableCardState();
}

class _SelectableCardState extends State<_SelectableCard> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = _SelectableCard.selectedTitle == widget.title;
    return AppCard(
      color: selected ? theme.colorScheme.primaryContainer : null,
      onTap: () => setState(() => _SelectableCard.selectedTitle = widget.title),
      child: Row(
        children: [
          Text(widget.emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.title, style: theme.textTheme.titleMedium),
                Text(widget.subtitle, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          if (selected)
            Icon(Icons.check_circle, color: theme.colorScheme.primary),
        ],
      ),
    );
  }
}

class _GoalPage extends StatelessWidget {
  const _GoalPage({required this.goal, required this.onChanged});

  final int goal;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '🎯',
            style: const TextStyle(fontSize: 56),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Set your daily goal',
            style: theme.textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'A few minutes every day beats one long session a week.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          for (final minutes in AppConstants.dailyGoalOptions)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: AppCard(
                color: goal == minutes
                    ? theme.colorScheme.primaryContainer
                    : null,
                onTap: () => onChanged(minutes),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '$minutes minutes / day',
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    Text(
                      minutes <= 5
                          ? 'Casual'
                          : minutes <= 15
                          ? 'Regular'
                          : 'Serious',
                      style: theme.textTheme.bodySmall,
                    ),
                    if (goal == minutes) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Icon(
                        Icons.check_circle,
                        color: theme.colorScheme.primary,
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
