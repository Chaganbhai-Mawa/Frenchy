import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'constants/app_constants.dart';
import 'providers.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class FrenchlyApp extends ConsumerStatefulWidget {
  const FrenchlyApp({super.key});

  @override
  ConsumerState<FrenchlyApp> createState() => _FrenchlyAppState();
}

class _FrenchlyAppState extends ConsumerState<FrenchlyApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // "Maximum" app-open frequency: show again every time the app returns
    // to the foreground, not just on cold start (handled by SplashScreen).
    if (state == AppLifecycleState.resumed && ref.read(adsEnabledProvider)) {
      ref.read(adsServiceProvider).appOpen.showAdIfAvailable();
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(settingsProvider.select((s) => s.themeMode));

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
