# Bonjourney — App Store listing copy

Copy-paste into App Store Connect → your app → **App Store** tab → **1.0 Prepare for
Submission**. Adapted from `../store-listing/listing.md` (Play Store) to Apple's field
limits, which are stricter and different in shape (e.g. a separate 30-char Subtitle field,
and Keywords instead of tags).

## App details

| Field | Value |
|---|---|
| Name (30 char max) | `Bonjourney` (10 chars) |
| Subtitle (30 char max) | `Learn French, A1 to C2` (23 chars) |
| Primary category | Education |
| Secondary category | Reference (optional) |
| Support URL | your Netlify site, e.g. `https://bonjourney-app.netlify.app` |
| Marketing URL (optional) | same, or leave blank |
| Privacy policy URL | `https://bonjourney-app.netlify.app/privacy.html` |
| Copyright | `© 2026 Bonjourney` |

## Promotional text (170 char max — editable anytime without a new review)

```
The complete French course, A1 to C2 — 162 units, 486 lessons, fully offline. Free with ads, or unlock lessons early by watching a short video.
```
(148 characters)

## Keywords (100 char max, comma-separated, no spaces after commas to save characters)

```
french,language,learn french,vocabulary,grammar,speaking,listening,CEFR,DELF,DALF,flashcards
```
(94 characters)

## Description (4000 char max)

Same copy as the Play Store full description in `../store-listing/listing.md` works
as-is for Apple — it has no ads-related claims that need adjusting for iOS. Copy it
directly from that file's "Full description" section.

## What's different from Google Play for iOS

- Apple has no separate "short description" field — the **Subtitle** (30 chars) and
  **Promotional text** (170 chars) above serve that role instead.
- Apple's age rating questionnaire is answered in-app (App Store Connect → App Information
  → Age Rating) rather than an external IARC flow — same "everyone" answers apply (no
  violence/mature content; does include third-party ads).
- Screenshots are required per declared device family with exact pixel dimensions — see
  the main [`README.md`](README.md) Step 8, don't reuse the Play Store screenshots as-is.
