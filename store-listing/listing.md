# Bonjourney — Play Store listing copy

Copy-paste these fields directly into Play Console → Grow → Store presence → Main store listing.

## App details

| Field | Value |
|---|---|
| App name | `Bonjourney` (30 char max — this is 10) |
| Default language | English (United States) — en-US |
| App or game | App |
| Category | Education |
| Tags (up to 5) | Language learning, Education, French, Vocabulary, Flashcards |
| Contact email | frenchly@fran.com |
| Contact website | *your Netlify URL, e.g.* `https://bonjourney-app.netlify.app` |
| Privacy policy URL | `https://bonjourney-app.netlify.app/privacy.html` |

## Short description (max 80 characters)

```
Learn French A1–C2 offline: 162 units, real conversations, free with ads
```
(74 characters)

## Full description (max 4000 characters)

```
Bonjourney takes you from your very first "Bonjour" to true C2 mastery — entirely offline, entirely free of fluff.

WHY BONJOURNEY

Most apps teach you words. Bonjourney teaches you French — the way it's actually spoken, written, and understood, from absolute beginner (A1) through expert fluency (C2), following the same CEFR framework used by language schools and official exams across Europe.

WHAT'S INSIDE

• 162 complete units across all 6 CEFR levels (A1, A2, B1, B2, C1, C2)
• 486 structured lessons, each a complete learning cycle: Learn → Vocabulary → Grammar → Listening → Speaking → Reading → Writing → Practice → Quiz
• Over 17,000 real, natural vocabulary items — every word includes pronunciation, gender, example sentences, and English translations
• Thousands of exercises: multiple choice, fill-in-the-blank, translation, word arrangement, matching, listening comprehension, dictation, and live speaking practice
• Built-in spaced repetition (Leitner system) so words you learn actually stick
• A mistake notebook and "weak words" review queue that adapts to how you're doing
• Daily streaks, XP, and achievements to keep you coming back
• Device-native text-to-speech and speech recognition for real pronunciation practice — no server round-trip required

TRULY OFFLINE

Every lesson, every word, every exercise is bundled with the app. No account, no sign-up, no internet connection required to learn. Your progress is stored privately on your device.

WHO IT'S FOR

Whether you're starting from zero before a trip to France, brushing up for a DELF/DALF exam, or pushing your French from advanced to truly native-level nuance (idioms, register, rhetoric, literature, translation craft), Bonjourney has a structured path for you.

FROM FIRST WORDS TO EXPERT NUANCE

A1–A2: greetings, everyday vocabulary, the present, passé composé, and enough grammar to hold a real conversation.
B1–B2: opinions, debate, the subjunctive, formal vs informal register, business French.
C1–C2: editorials, negotiation, literary criticism, rhetoric, translation subtlety, and the kind of idiomatic precision that takes most learners years to reach.

Start today. Say "Bonjour" — and keep going all the way to fluent.
```
(~2,150 characters — well under the 4000 limit; room to expand later.)

## Note on ads

AdMob is integrated as of versionCode 2 (banner, interstitial, rewarded, rewarded
interstitial, native advanced, app open). This means, in Play Console → App content:

- **Ads**: answer **"Yes, my app contains ads"**.
- **Data safety**: declare the Advertising ID as collected & shared with Google — see
  `data-safety.md`.
- `netlify-site/app-ads.txt` is live with the real publisher ID (`pub-9960557555177349`).

If you ever strip ads back out of a build, reverse all of the above before submitting —
a mismatch between your Play Console declarations and actual app behavior is a policy
violation ("Deceptive Behavior" / Data Safety inaccuracy) and can get the app suspended.

## Screenshots (already captured, in `screenshots/phone/`)

Upload in this order (Play Console requires 2–8 phone screenshots, 16:9 or 9:16, min 320px):
1. `01_home.png` — home dashboard with streak/XP
2. `02_learn.png` — CEFR level picker + unit list
3. `03_unit.png` — unit detail with 3 lessons
4. `04_lesson_dashboard.png` — lesson section checklist
5. `05_vocabulary_card.png` — flashcard with pronunciation
6. `06_progress.png` — stats + activity calendar
7. `07_practice.png` — spaced-repetition review center
8. `08_about.png` — profile / About screen confirming the Bonjourney branding

Optional: add 1–2 more once you're happy with a quiz/exercise screen (see `screenshots/README.md` for how these were captured, so you can add more later).

## Graphics (already generated, in `graphics/`)

- `icon-512.png` — 512×512 hi-res icon (required)
- `feature-graphic-1024x500.png` — 1024×500 feature graphic (required)

Both were generated from `assets/branding/app_icon.png`. Regenerate them any time your branding changes by re-running the PowerShell scripts documented in `graphics/README.md`.
