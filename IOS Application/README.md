# Bonjourney — iOS / App Store submission kit

Everything needed to get Bonjourney onto the Apple App Store, using Codemagic to build
(since compiling an iOS app requires Apple's Xcode toolchain, which only runs on macOS —
this project is developed on Windows, so Codemagic's cloud Mac runners do the actual
building). Follow the steps below in order.

## What's already done in the codebase

- `ios/` — the Flutter iOS platform project (bundle id `com.bonjourney.app`, matching
  Android; app display name "Bonjourney"; deployment target iOS 13.0).
- `codemagic.yaml` (repo root — Codemagic auto-detects it there, so don't move it) — the
  `ios-app-store` workflow: installs deps, runs `flutter analyze` + `flutter test`, builds
  a signed IPA, and uploads it to TestFlight automatically on every push to `main`. Code
  signing is **manual** (a certificate + profile you upload to Codemagic, see step 5 below)
  — automatic signing failed with "No matching profiles found".
- AdMob is wired in for iOS with real ad unit ids (see table below) — same 6 formats as
  Android: banner, interstitial, rewarded, rewarded interstitial, native advanced, app open.
- App Tracking Transparency consent is requested at first launch (`app_tracking_transparency`
  package) — required by Apple for apps that use ad tracking (`GADApplicationIdentifier` /
  `SKAdNetworkItems` are set in `ios/Runner/Info.plist`).
- Microphone + speech-recognition usage descriptions are set (required for the speaking
  exercises to work on iOS at all — without these the app would crash when requesting
  permission, not just get rejected).
- `ITSAppUsesNonExemptEncryption` is set to `false` (the app only uses standard HTTPS, so
  this skips the manual export-compliance prompt on every upload).
- App icons were regenerated for iOS from `assets/branding/app_icon.png` (alpha channel
  removed — Apple rejects icons with transparency).

## What you still need to do — in order

### 1. Enroll in the Apple Developer Program

Go to https://developer.apple.com/programs/enroll — **$99/year**. You'll need an Apple ID.
Two account types:
- **Individual** — usually approved within a day or so.
- **Organization** — requires a D-U-N-S number (free, but can take 1-2 weeks to verify if
  your business doesn't already have one — check https://developer.apple.com/support/D-U-N-S/
  and start this early if you're going the organization route, since it's the longest
  pole in this entire process).

### 2. Register the bundle identifier

https://developer.apple.com/account → **Certificates, IDs & Profiles → Identifiers → +**
- Register an **App ID**: `com.bonjourney.app` (must match `ios/Runner.xcodeproj` exactly —
  already set).
- Capabilities: none needed beyond the default unless you add push notifications etc. later.

### 3. Create the app record in App Store Connect

https://appstoreconnect.apple.com → **Apps → + → New App**
- Platform: **iOS**
- Name: `Bonjourney` (check it's not already taken by another developer — App Store names
  are globally unique, unlike Play Store)
- Primary language: English (U.S.)
- Bundle ID: select `com.bonjourney.app` (from step 2)
- SKU: any unique internal string, e.g. `bonjourney-ios-001`
- User access: Full Access

Once created, note the **numeric Apple ID** shown under **App Information** (looks like
`1234567890`) — you'll need it for `codemagic.yaml`'s `APP_STORE_APPLE_ID`.

### 4. Generate an App Store Connect API key (for Codemagic)

App Store Connect → **Users and Access → Integrations → App Store Connect API → Generate
API Key**
- Role: **App Manager** (or Admin)
- Download the `.p8` file **immediately** — Apple only lets you download it once.
- Note the **Key ID** and **Issuer ID** shown on that page.

### 5. Connect Codemagic

1. Sign up / log in at https://codemagic.io, connect your GitHub account, and add the
   `Chaganbhai-Mawa/Frenchy` repo as an app.
2. **Team settings → Integrations → App Store Connect → Add key** — paste in the `.p8`
   contents, Key ID, and Issuer ID from step 4. Name the integration — if the name doesn't
   match `codemagic_app_store_connection`, either rename it to match or edit that name in
   `codemagic.yaml`'s `integrations.app_store_connect` field. (This key is still needed —
   it's what uploads the finished build to TestFlight — even though signing itself is
   manual, see next point.)
3. Codemagic should auto-detect `codemagic.yaml` at the repo root and list the
   `ios-app-store` workflow.
4. Edit `codemagic.yaml`, fill in:
   - `APP_STORE_APPLE_ID` — the numeric Apple ID from step 3.
   - The `publishing.email.recipients` address — currently a placeholder.
   Commit and push (or edit directly in Codemagic's UI env vars instead, if you'd rather
   not put the Apple ID in git — it's not secret, but your call).
5. **Code signing (manual)**: automatic signing (having Codemagic generate the
   certificate/profile itself via the API key) failed with "No matching profiles found" —
   see [`certificate-and-profile.md`](certificate-and-profile.md) in this folder for the
   full step-by-step to generate a Distribution certificate and App Store provisioning
   profile yourself (no Mac needed, just `openssl` and Apple's website) and upload them to
   Codemagic's Code signing identities section. `codemagic.yaml` is already updated to use
   whatever you upload there.

### 6. Fill out App Privacy in App Store Connect

App Store Connect → your app → **App Privacy → Get Started**. See
[`app-privacy-answers.md`](app-privacy-answers.md) in this folder for exactly what to
answer — this reflects AdMob's actual data collection on iOS, cross-check it against
Google's own published mapping (linked in that file) since Apple's exact categories change
over time.

### 7. Fill out the App Store listing

App Store Connect → your app → **App Store** tab (the "1.0 Prepare for Submission" page).
See [`listing.md`](listing.md) in this folder for name/subtitle/keywords/description text,
adapted from the Play Store listing to Apple's field limits.

You'll also need:
- **Privacy policy URL**: same one used for Play Store —
  `https://<your-netlify-site>/privacy.html` (see `../netlify-site/README.md` if not
  deployed yet — Section 5 already discloses AdMob's iOS data collection).
- **Support URL**: your Netlify site or a `mailto:` if you don't have a separate support
  page.
- **Age rating questionnaire**: same "everyone" answers as the Play Store's IARC
  questionnaire in `../store-listing/content-rating.md` — Apple's form asks similar
  questions in its own format (no violence, no mature content, does contain
  third-party/ad content).

### 8. Screenshots — done, in `screenshots/`

`screenshots/iphone-6.5-1242x2688/` and `screenshots/iphone-6.7-1284x2778/` each have the
same 8 screens as the Play Store set, generated (not distorted or cropped — see that
folder's README for how) from the real app UI at Apple's exact required pixel dimensions
for those two device classes. Upload whichever size(s) App Store Connect's screenshot
uploader asks for — both are ready.

If App Store Connect asks for a different size than these (Apple's requirements shift —
e.g. a newer "6.9" iPhone 16 Pro Max class at 1320×2868"), re-run the generation script in
`screenshots/README.md` with the new dimensions; it's a couple of minutes of work either
way.

**iPad**: Flutter's default project is universal (iPhone + iPad — `Info.plist` declares
both orientations for `~ipad`). If App Store Connect requires iPad screenshots because of
this, either generate a 13" iPad set the same way, or restrict the app to iPhone-only by
setting `TARGETED_DEVICE_FAMILY = 1` in the Xcode project to skip iPad screenshots
entirely — tell me which you'd rather do.

### 9. Trigger the first Codemagic build

Push to `main` (or **Start new build** in the Codemagic UI, workflow `ios-app-store`).
This runs `flutter analyze` + `flutter test`, builds the IPA, and — if
`submit_to_testflight: true` in `codemagic.yaml` (it is, by default) — uploads it straight
to TestFlight.

If the build fails on code signing, double check: the bundle id in App Store Connect (step
3) matches `com.bonjourney.app` exactly, and the App Store Connect API key (step 4/5) has
App Manager role or higher.

### 10. Test via TestFlight

App Store Connect → your app → **TestFlight** tab → add yourself as an internal tester →
install the TestFlight app on an iPhone → install Bonjourney through it. Sanity-check ads
show correctly, speaking exercises work (microphone permission prompt), and the ATT prompt
appears on first launch.

### 11. Submit for review

App Store Connect → **App Store** tab → select the TestFlight build → fill any remaining
required fields (App Store flags what's missing) → **Submit for Review**.

Apple's review typically takes **24-48 hours** for a first submission, sometimes longer.
Common first-submission rejection reasons to watch for: missing/incorrect screenshots for a
declared device family, App Privacy answers not matching actual SDK behavior, and the
"Guideline 2.1" catch-all if a reviewer can't get past onboarding — test the TestFlight
build yourself first.

## AdMob iOS ad unit IDs used in this build

| Format | Ad unit ID |
|---|---|
| App | `ca-app-pub-9960557555177349~4716311024` |
| Banner | `ca-app-pub-9960557555177349/4416550829` |
| Interstitial | `ca-app-pub-9960557555177349/8283643643` |
| Rewarded interstitial | `ca-app-pub-9960557555177349/9525784575` |
| Rewarded | `ca-app-pub-9960557555177349/1790387486` |
| Native advanced | `ca-app-pub-9960557555177349/6851142475` |
| App open | `ca-app-pub-9960557555177349/5370539844` |

## Updating the app later

1. Bump `pubspec.yaml`'s `version:` (the `+N` build number must increase for every App
   Store Connect upload, same rule as Android's versionCode — currently `1.0.0+2`).
2. Push to `main` — Codemagic rebuilds and re-uploads to TestFlight automatically.
3. In App Store Connect, add the new build to a new version and submit for review, with
   release notes describing what changed.

## Known open item

Same as the Play Store kit: **no GDPR/UK ad-consent flow (Google's User Messaging
Platform SDK)** is implemented yet on either platform. Add this before targeting EEA/UK
users at scale — see `../store-listing/admob-integration-checklist.md`.
