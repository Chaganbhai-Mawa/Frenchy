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

  // AdsService.initialize() is NOT called here: iOS silently skips the App
  // Tracking Transparency prompt if it's requested before the app has a
  // visible/key window, which is exactly what happens if this runs before
  // runApp(). It's kicked off instead from FrenchlyApp's first post-frame
  // callback (see app/app.dart), once the window is actually up.
  final ads = AdsService();

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
