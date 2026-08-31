# Bonjourney — Release Notes

**Version:** 1.0.0 (versionCode 2)
**Build:** `bonjourney-1.0.0+2.aab`
**Date:** 2026-08-31

## What's new in this build

- **Ads integration (AdMob):**
  - Banner ad shown persistently across Home, Learn, Practice, Progress, and Profile tabs.
  - Interstitial ads shown after completing a lesson and when opening a unit from the Learn tab.
  - Rewarded interstitial ad offered when tapping a locked lesson, to unlock it immediately.
  - Rewarded ad available from the Home tab ("Unlock next lesson") to unlock the next locked lesson early.
  - Native advanced ad shown inline every 4th lesson in a unit's lesson list.
  - App open ad shown on cold start and whenever the app returns from the background.
- **New: sequential lesson unlocking.** Lessons within a unit now unlock in order (finish lesson *N* to unlock *N+1*); watching a rewarded ad unlocks a locked lesson immediately instead.

## Before uploading to Google Play

- **versionCode:** this build uses versionCode **2** (bumped from 1, which Play Console had already rejected as a duplicate). If this upload is also rejected as a duplicate, bump the `+2` in `pubspec.yaml`'s `version:` line again and rebuild.
- **Consent (GDPR/UK):** this build does not yet implement Google's User Messaging Platform (UMP) SDK for EEA/UK ad consent. Google requires this for publishers serving ads to EEA/UK users — add it before this build reaches production.
- **Ad unit IDs:** release builds use the real AdMob ad unit IDs below; debug/profile builds always use Google's test IDs.

| Format | Ad unit ID |
|---|---|
| App | `ca-app-pub-9960557555177349~9792648934` |
| Banner | `ca-app-pub-9960557555177349/8479567263` |
| Interstitial | `ca-app-pub-9960557555177349/7166485591` |
| Rewarded interstitial | `ca-app-pub-9960557555177349/9596268469` |
| Rewarded | `ca-app-pub-9960557555177349/6921626368` |
| Native advanced | `ca-app-pub-9960557555177349/5688435742` |
| App open | `ca-app-pub-9960557555177349/5840856282` |

## Build details

- Built with: `flutter build appbundle --release`
- Signed with the release keystore configured in `android/key.properties`
- Verified before build: `flutter analyze` (clean), `flutter test` (532/532 passing)
