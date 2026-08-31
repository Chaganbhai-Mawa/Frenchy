# AdMob integration — done (historical record)

AdMob is wired into the app as of `versionCode 2` (`release/bonjourney-1.0.0+2.aab`),
across all 6 formats: banner, interstitial, rewarded, rewarded interstitial, native
advanced, and app open — on both Android and iOS. This file used to be a to-do checklist;
it's kept as a record of what was done and where things live.

## AdMob account

- **App**: Bonjourney
- **Android App ID**: `ca-app-pub-9960557555177349~9792648934`
- **iOS App ID**: `ca-app-pub-9960557555177349~4716311024`
- **Publisher ID** (used in `netlify-site/app-ads.txt`): `pub-9960557555177349`

## Where each format is wired in the code

| Format | Where it shows |
|---|---|
| Banner | Persistent bar above the bottom nav, every tab (`lib/core/widgets/banner_ad_card.dart`) |
| Interstitial | After lesson completion; when opening a unit from Learn (`lib/features/lessons/lesson_player_screen.dart`, `lib/features/learn/learn_screen.dart`) |
| Rewarded interstitial | Tapping a locked lesson offers this to unlock it (`lib/features/learn/unit_detail_screen.dart`) |
| Rewarded | "Unlock next lesson" card on Home (`lib/features/home/home_screen.dart`) |
| Native advanced | Every 4th lesson card in a unit's lesson list (`lib/core/widgets/native_ad_card.dart`) |
| App open | Cold start (`lib/features/splash/splash_screen.dart`) and foreground resume (`lib/app/app.dart`) |

All ad unit ids live in `lib/core/services/ads_service.dart` (`AdUnitIds`). Debug/profile
builds always use Google's public test ids (`kReleaseMode` switch) — only release builds
serve the real ones above.

## What this changed elsewhere in this kit

- `netlify-site/app-ads.txt` — live with the real publisher ID.
- `netlify-site/privacy.html` — Section 5 (Advertising) now discloses AdMob's data
  collection.
- `store-listing/data-safety.md` — declares Advertising ID as collected & shared with
  Google.
- `store-listing/content-rating.md` — ads section answered.
- `store-listing/listing.md` — short description and ads note updated.

## Still open

- **iOS**: App Tracking Transparency consent is requested at startup
  (`app_tracking_transparency` package), but there's no GDPR/UK consent flow (Google's User
  Messaging Platform SDK) on either platform yet — required before serving ads to EEA/UK
  users. Add this before a wide release.
- If you ever want to verify real ad delivery, use a real device with a build signed for
  release and check the AdMob console's delivery reports 24-48h after publishing — test ad
  ids never report real impressions.
