# Release checklist

## Identity

- Application ID: `com.frenchly.frenchly` (change before publishing).
- Display name: set in ONE place per platform — `AppConstants.appName`
  (in-app), `android:label` in AndroidManifest.xml (launcher). "Frenchly"
  is a working title; rename by editing those two spots.
- Versioning: `pubspec.yaml` `version: x.y.z+build`.

## Before a Play Store build

1. `flutter analyze && flutter test` — must be clean/green.
2. Create a release keystore and `android/key.properties`; configure
   `signingConfigs` in `android/app/build.gradle.kts` (currently debug-signed).
3. `flutter build appbundle --release` (R8 shrinking is on by default for
   release builds).
4. Launcher icon: source artwork lives in `assets/branding/app_icon.png`.
   After changing it run `dart run flutter_launcher_icons` to regenerate the
   legacy mipmaps and the adaptive icon (background colour is
   `ic_launcher_background` in `res/values/colors.xml`).
5. Native splash: already matches the in-app splash — `splash_background`
   (#16295F) is used by `launch_background.xml` and by
   `android:windowSplashScreenBackground` for Android 12+.
6. Test offline: airplane mode → full lesson flow, review, mistakes,
   progress must all work; video sections must show their fallback.
7. Test on small phone (~5"), large phone, tablet; light + dark themes;
   large font accessibility setting.

## Privacy policy notes (app is client-side)

- All learning data stays on device (SharedPreferences).
- Microphone is used only during speaking exercises; audio/transcripts are
  not stored or transmitted by the app.
- Embedded YouTube videos use the privacy-enhanced domain
  (youtube-nocookie.com); YouTube's own terms/cookies apply during playback.
- No accounts, no analytics, no ads in v1.

## Known follow-ups

- Local reminder notifications (opt-in) — deliberately not shipped in v1 to
  avoid a fake toggle; add `flutter_local_notifications` + desugaring.
- More course content: add unit JSON files under `assets/content/<level>/`
  per `docs/authoring-brief-levels.md` and list them in
  `LocalCourseRepository._unitFiles` (missing files are skipped gracefully,
  so listing ahead of authoring is safe).
- Placement test (onboarding currently starts everyone at A1).
- Debug screen behind `kDebugMode` for QA shortcuts.
