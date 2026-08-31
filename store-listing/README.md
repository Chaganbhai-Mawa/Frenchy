# Bonjourney — Google Play Store submission kit

Everything needed to submit Bonjourney to the Play Store lives in this folder. Follow the
steps below in order — each links to the relevant file for the details.

## What's in this folder

```
store-listing/
├── README.md                        ← you are here — step-by-step submission guide
├── listing.md                       ← title/descriptions/category, ready to copy-paste
├── data-safety.md                   ← Data Safety form answers + reasoning (AdMob is live — see notes)
├── content-rating.md                ← Content rating questionnaire guidance
├── admob-integration-checklist.md   ← AdMob is wired in as of versionCode 2 — kept as a historical record
├── graphics/
│   ├── icon-512.png                 ← 512×512 hi-res icon (required)
│   ├── feature-graphic-1024x500.png ← 1024×500 feature graphic (required)
│   └── README.md                    ← how these were generated / regenerate them
└── screenshots/
    ├── phone/*.png                  ← 8 real screenshots captured from the running app
    └── README.md                    ← how to capture more
```

The actual upload file lives in [`../release/`](../release/) (not duplicated here) —
currently `release/bonjourney-1.0.0+2.aab`. See [`../release/release-notes.md`](../release/release-notes.md)
for what's in it.

## Step-by-step: first submission

### 1. Create your Play Console account (if you haven't)

Go to https://play.google.com/console/signup — one-time **$25 USD registration fee**,
requires a Google account and government ID verification (can take a day or two for new
developer accounts). Do this first since verification can be the long pole.

### 2. Create the app

Play Console → **Create app**:
- App name: `Bonjourney`
- Default language: English (US)
- App or game: **App**
- Free or paid: **Free** (unless you plan to charge — nothing in this kit assumes payments)
- Confirm the declarations (US export laws, Play policies, etc.)

### 3. Set up your store listing

Play Console → **Grow → Store presence → Main store listing**. Copy every field from
[`listing.md`](listing.md) — app name, short description, full description, category, tags,
contact email (`frenchly@fran.com`), and your Netlify site URL once it's live (Step 7 below).

Upload graphics:
- App icon: `graphics/icon-512.png`
- Feature graphic: `graphics/feature-graphic-1024x500.png`
- Phone screenshots: all 8 files in `screenshots/phone/`, in numeric order

### 4. Fill out App content

Play Console → **App content**. Six sections, each required before you can publish:

1. **Privacy policy** — paste your Netlify privacy URL (Step 7): `https://<your-site>.netlify.app/privacy.html`
2. **Ads** — answer **"Yes, my app contains ads"** (AdMob is integrated — see
   [`admob-integration-checklist.md`](admob-integration-checklist.md))
3. **App access** — "All functionality is available without special access" (no login wall)
4. **Content ratings** — complete the IARC questionnaire per [`content-rating.md`](content-rating.md)
5. **Target audience & content** — target age 13+ recommended for a language-learning app
   (Play requires extra "Designed for Families" steps if you target under-13; not needed here
   unless you specifically want that program)
6. **Data safety** — complete per [`data-safety.md`](data-safety.md)

### 5. Set up pricing & countries

Play Console → **Grow → Store presence → Pricing & countries** (or similar, naming varies by
console version) — select **Free**, then select which countries to distribute to (default:
all countries is fine for a French-learning app).

### 6. Upload the AAB

**Before you upload: read [`signing.md`](signing.md) (kept out of git — local file only,
it has the keystore password).** `release/bonjourney-1.0.0+2.aab` is signed with a real
release keystore (not the debug key), and `signing.md` documents where the keystore lives,
its password, and — critically — how to back it up so you never lose the ability to
publish updates to this app.

Play Console → **Release → Production** (or start with **Testing → Internal testing** first —
recommended for your very first release so you can install via a private link and sanity-check
before going public):

1. Create a new release.
2. Upload `release/bonjourney-1.0.0+2.aab`.
3. Play Console will auto-detect the package (`com.bonjourney.app`), version code (2),
   version name (1.0.0), and generate signed APKs for every device configuration via Play
   App Signing (opt in when prompted — Google manages your signing key, which is the
   recommended default).
4. Write release notes, e.g.: *"Bonjourney 1.0 — the complete French course, A1 to C2. 162
   units, 486 lessons, fully offline."*
5. Review the release (Play Console flags any missing required fields) and roll out.

### 7. Deploy the companion website to Netlify

The [`../netlify-site/`](../netlify-site/) folder has `index.html`, `privacy.html`, and
`app-ads.txt`, ready to deploy. See [`../netlify-site/README.md`](../netlify-site/README.md) for
the 2-minute deploy steps. **Do this before Step 4** if possible — Play Console needs a live
privacy policy URL before you can submit.

### 8. Review timeline

- New developer accounts: first app review can take **up to 7 days** (Google manually
  reviews first-time publishers more closely).
- Subsequent updates: usually a few hours to ~2 days.
- Watch Play Console's **Policy status** section — if anything is rejected, it tells you
  exactly which policy and what to fix.

## Updating the app later

1. Bump the version in `pubspec.yaml` — current is `1.0.0+2`; e.g. `version: 1.0.1+3` (the
   `+3` is the `versionCode`, which **must increase** on every Play Store upload — Google
   rejects a re-used one; `1.0.1` is the human-readable `versionName`, bump it however you
   like).
2. `flutter build appbundle --release`
3. Play Console → Production → **Create new release** → upload the new AAB → add release
   notes → roll out. No need to redo the store listing/content sections unless something
   about them changed (e.g. new permissions require re-declaring Data Safety).

## Known open item

`store-listing/listing.md` flags a **pending vocab-id naming cleanup** (18 content files
have leftover unit-prefixed ids like `c2u29-...` instead of the course's plain-kebab-case
convention) — cosmetic only, doesn't affect app function or store submission, tracked
separately in the main project's task list.
