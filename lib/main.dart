import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/providers.dart';
import 'core/services/ads_service.dart';
import 'core/services/key_value_store.dart';
import 'data/repositories/progress_repository.dart';
import 'data/repositories/settings_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load only the small critical state (settings + progress) before the
  // first frame; course content is lazy-loaded per level later.
  final store = await SharedPrefsStore.create();
  final settings = await LocalSettingsRepository(store).getSettings();
  final progress = await LocalProgressRepository(store).getProgress();

  // Fire-and-forget: ad SDK init + preloading runs in the background so it
  // never delays the first frame, but starts early enough that the app-open
  // ad is usually ready by the time the splash screen finishes.
  final ads = AdsService();
  unawaited(ads.initialize());

  runApp(
    ProviderScope(
      overrides: [
        keyValueStoreProvider.overrideWithValue(store),
        initialSettingsProvider.overrideWithValue(settings),
        initialProgressProvider.overrideWithValue(progress),
        adsServiceProvider.overrideWithValue(ads),
      ],
      child: const FrenchlyApp(),
    ),
  );
}
