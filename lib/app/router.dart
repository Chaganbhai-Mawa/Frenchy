import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/achievements/achievements_screen.dart';
import '../features/home/home_screen.dart';
import '../features/learn/learn_screen.dart';
import '../features/learn/unit_detail_screen.dart';
import '../features/lessons/lesson_dashboard_screen.dart';
import '../features/lessons/lesson_player_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/practice/mistakes_screen.dart';
import '../features/practice/practice_screen.dart';
import '../features/practice/review_screen.dart';
import '../features/practice/saved_lessons_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/progress/progress_screen.dart';
import '../features/settings/debug_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/shell/main_shell.dart';
import '../features/splash/splash_screen.dart';
import '../features/vocabulary/vocabulary_screen.dart';
import 'providers.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => MainShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/learn',
                builder: (context, state) => const LearnScreen(),
                routes: [
                  GoRoute(
                    path: 'unit/:unitId',
                    builder: (context, state) => UnitDetailScreen(
                      unitId: state.pathParameters['unitId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/practice',
                builder: (context, state) => const PracticeScreen(),
                routes: [
                  GoRoute(
                    path: 'review',
                    builder: (context, state) => ReviewScreen(
                      weakOnly: state.uri.queryParameters['mode'] == 'weak',
                    ),
                  ),
                  GoRoute(
                    path: 'mistakes',
                    builder: (context, state) => const MistakesScreen(),
                  ),
                  GoRoute(
                    path: 'vocabulary',
                    builder: (context, state) => const VocabularyScreen(),
                  ),
                  GoRoute(
                    path: 'saved',
                    builder: (context, state) => const SavedLessonsScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/progress',
                builder: (context, state) => const ProgressScreen(),
                routes: [
                  GoRoute(
                    path: 'achievements',
                    builder: (context, state) => const AchievementsScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'settings',
                    builder: (context, state) => const SettingsScreen(),
                  ),
                  GoRoute(
                    path: 'debug',
                    builder: (context, state) => const DebugScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      // Lesson routes sit outside the shell: full-screen immersive flow.
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: '/lesson/:id',
        builder: (context, state) =>
            LessonDashboardScreen(lessonId: state.pathParameters['id']!),
        routes: [
          GoRoute(
            parentNavigatorKey: _rootNavigatorKey,
            path: 'play/:sectionIndex',
            builder: (context, state) => LessonPlayerScreen(
              lessonId: state.pathParameters['id']!,
              initialSectionIndex:
                  int.tryParse(state.pathParameters['sectionIndex']!) ?? 0,
            ),
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      final onboarded = ref.read(settingsProvider).onboardingComplete;
      final loc = state.matchedLocation;
      if (!onboarded && loc != '/' && loc != '/onboarding') {
        return '/onboarding';
      }
      return null;
    },
  );
});
