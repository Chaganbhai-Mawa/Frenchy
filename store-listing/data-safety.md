# Data Safety form — answers for Play Console

Play Console → App content → Data safety. This reflects the **current build**
(versionCode 2 and later — `release/bonjourney-1.0.0+2.aab`), which integrates **Google
AdMob** (banner, interstitial, rewarded, rewarded interstitial, native advanced, app open).
There is still no backend server, no account system, and no analytics/crash-reporting SDK —
verified by inspecting `pubspec.yaml` (added: `google_mobile_ads`,
`app_tracking_transparency`; everything else unchanged).

**Re-check this form whenever you change dependencies** — a stale Data Safety answer that
doesn't match app behavior is a policy violation, not just an inaccuracy.

## Step 1: Does your app collect or share any of the required user data types?

**Yes** — because of AdMob. Declare:

- **Device or other IDs** → **Advertising ID** — Collected: Yes. Shared: Yes, with Google
  (AdMob), for **Advertising or marketing** and **Fraud prevention, security, and
  compliance** purposes. Not required to be provided (ads still show, just less
  personalized, if the user declines tracking).
- Everything else Bonjourney itself handles is still **not collected**: no account, no
  backend, no analytics, no crash reporting beyond what AdMob's own SDK does internally
  under Google's data handling (see Google's Play Data Safety mapping for AdMob at
  https://support.google.com/admob/answer/6128543 — use their current published mapping
  as the source of truth for exact checkboxes, since Google updates this periodically).

Two nuances worth declaring honestly for the parts Bonjourney's own code touches directly:

### Microphone (speaking exercises)

- **What happens**: `RECORD_AUDIO` is requested only when the user opens a speaking
  exercise. Audio is processed by the **device's own** speech-recognition service
  (Android's `SpeechRecognizer` API, via the `speech_to_text` plugin) to produce a
  transcript for on-device comparison against the expected phrase.
- **Does Bonjourney collect it?** No — audio never reaches a Bonjourney server (there isn't
  one). Whether the *device's* recognizer processes audio on-device or sends it to the
  device manufacturer's/Google's cloud STT depends on the user's phone and OS settings,
  entirely outside the app's control.
- **Data Safety form answer**: Under "Audio" → "Voice or sound recordings" → mark **collected:
  No, but processed transiently on-device via the OS speech API**; if the form forces a
  binary choice, the safer accurate answer is **"Not collected"** since Bonjourney's own code
  never stores, transmits, or retains the recording — it discards it immediately after
  getting a transcript.

### Internet / device TTS

- `INTERNET` is used for: (a) loading curated lesson videos via YouTube embeds
  (`webview_flutter`), (b) `url_launcher` opening a video externally if the embed fails, and
  (c) the on-device TTS/speech engines, which on some devices route through Google's
  servers depending on the installed engine. Bonjourney does not add any tracking, analytics,
  or identifiers to these requests.

## Step 2: Security practices

- Data is encrypted in transit: **Yes** — AdMob's own network traffic is HTTPS. Bonjourney's
  own local storage (`SharedPreferences`) never leaves the device.
- Users can request data deletion: mark that a request is honored via **uninstalling the
  app** (deletes all local progress) and note AdMob's advertising ID isn't tied to a
  Bonjourney account — users manage/reset it via their device's ad-settings (Android:
  Settings → Privacy → Ads → Delete advertising ID; iOS: disable Tracking in Settings →
  Privacy & Security → Tracking).

## Step 3: Data types checklist (if the form still requires walking every category)

| Category | Collected? | Shared? | Notes |
|---|---|---|---|
| Location | No | No | AdMob may infer coarse/approximate location from IP for ad targeting — Google's data, not something Bonjourney requests or reads |
| Personal info (name, email, etc.) | No | No | No account/sign-up exists |
| Financial info | No | No | No purchases, no payment flow |
| Health/fitness | No | No | |
| Messages | No | No | |
| Photos/videos | No | No | |
| Audio files (voice) | No* | No | *processed transiently by OS speech API only, see above |
| Files/docs | No | No | |
| Calendar | No | No | |
| Contacts | No | No | |
| App activity (in-app actions, install/uninstall) | No | No | Progress stored locally only, never transmitted; AdMob separately logs ad interaction events (impressions/clicks) itself |
| Web browsing history | No | No | |
| App info/performance (crash logs, diagnostics) | No | No | No crash-reporting SDK integrated |
| Device/other IDs | **Yes** | **Yes, with Google** | Advertising ID, collected and shared by the AdMob SDK for advertising/marketing and fraud-prevention purposes |
