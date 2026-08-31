# Frenchly Architecture

## Overview

Frenchly is an offline-first Flutter app for learning French (A1 → C2).
Version 1 has **no backend**: all content is bundled, all state is local.

```
Presentation  → lib/features/* (screens + widgets, no business logic)
State         → Riverpod providers (lib/app/providers.dart)
Domain        → lib/data/models/* + lib/features/lessons/lesson_engine.dart
Data          → lib/data/repositories/* (interface + Local* implementation)
Services      → lib/core/services/* (storage, TTS, speech recognition)
Content       → assets/content/* (JSON course packs, see content-format.md)
```

## Key decisions

- **Interface-first repositories.** `CourseRepository`, `ProgressRepository`,
  `SrsRepository`, `MistakesRepository`, `SettingsRepository` are abstract;
  the `Local*` implementations persist via a `KeyValueStore` abstraction
  (SharedPreferences today). A cloud sync backend later means adding
  `Cloud*` implementations — feature code never changes.
- **Bootstrap before first frame.** `main()` loads settings + progress
  (small JSON blobs) before `runApp` and injects them as provider overrides.
  The first frame renders with real data; course content loads lazily per
  CEFR level.
- **Section-driven lesson engine.** A lesson is an ordered list of sections
  (learn, vocabulary, grammar, reading, listening, speaking, writing, video,
  practice, quiz, review) defined entirely in JSON. One renderer
  (`LessonPlayerScreen._buildSection`) maps section types to views; content
  authors control ordering without UI changes.
- **One unified `Exercise` model** powers every interactive question type
  (10 types) so the quiz engine, listening, writing, reading questions,
  video questions and review flows all reuse `ExercisePlayer`.
- **Videos are optional by design.** Curated YouTube videos (verified via
  oEmbed at authoring time) live in `assets/content/videos.json`, keyed by
  unit. They are appended to lessons as non-required "Watch" sections and
  never block completion — external availability must not gate learning.
- **Spaced repetition** is a Leitner system (`SrsEntry`, boxes 0–5 with
  intervals 0/1/3/7/14/30 days). Wrong answers demote; learners self-assess
  on flashcards.
- **XP anti-farming.** Section XP is granted only on first completion;
  repeating a completed lesson earns a reduced reward. The daily challenge
  (earn 100 XP today, +100 bonus) auto-completes inside `addXp` so it works
  offline and deterministically.
- **Streaks are date-string based** (`yyyy-MM-dd` list) making the logic
  timezone-stable and trivially testable. Missing today doesn't kill the
  streak until the day fully passes (grace: streak counts if yesterday was
  active).

## Error handling

Nothing user-facing may crash: repositories catch corrupt-data errors and
return defaults; malformed unit files are skipped; TTS/speech services
no-op gracefully with friendly messages; unknown routes/ids render designed
empty states; WebView failures fall back to "open externally".

## Testing

- `test/unit/` — SRS scheduling, streaks, XP/daily challenge, answer
  checking (accents/punctuation), video URL parsing, persistence, and a
  content contract test validating all bundled JSON.
- `test/widget/` — launch→onboarding flow, home, and each tab (with a
  synchronous fake `CourseRepository`, since asset I/O futures don't
  complete in the fake-async test zone).
