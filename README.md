# Frenchly 🇫🇷

*Learn French. One step at a time.*

An offline-first Flutter Android app that takes learners from absolute
beginner toward fluency along the CEFR path (A1 → C2). Version 1 ships a
complete, genuinely usable A1 course — no account, no backend, no internet
required for the core experience.

## What's inside

- **All six CEFR levels · 43 units · 125 lessons · ~3 760 vocabulary words**
  of real, linguistically correct French. The syllabus in `docs/syllabus-*.md`
  plans each level out to 30 units; units are added as JSON files and the
  loader discovers them automatically.
  - **A1** (12 units) — greetings, introductions, numbers, family, countries,
    food & drinks, daily routine, time & dates, shopping, everyday
    conversations, hobbies, getting around.
  - **A2** (8 units) — daily life, past tenses, childhood memories, future
    plans, travel, work, health, city life & housing.
  - **B1** (6 units) — storytelling, opinions & subjunctive, professional
    life, media & news, environment & society, culture & travel.
  - **B2** (5 units) — debate & argumentation, business French, politics,
    idioms, abstract ideas.
  - **C1** (4 units) — academic French, literature & style, professional
    nuance, press & editorials.
  - **C2** (4 units) — rhetoric & eloquence, street French & regions,
    literature & translation, mastery.
- **Complete lesson journeys** — every lesson flows through learn →
  vocabulary → grammar → listening → speaking → reading → writing →
  (video) → quiz, rendered from JSON content by a single section engine.
- **10 exercise types** — multiple choice, listen-and-choose,
  listen-and-type, dictation, arrange words, fill-blank, translation,
  matching pairs, reading comprehension, speaking with device speech
  recognition.
- **Curated video module** — verified YouTube lessons per unit, embedded
  in-app (privacy-enhanced domain) with graceful offline/unavailable
  fallbacks; always optional.
- **Spaced repetition** — Leitner scheduling with a Review Center (due
  today, weak words), plus an automatic mistake notebook.
- **Motivation loop** — XP with anti-farming rules, daily goal ring, daily
  challenge, streak calendar, 10 achievements, confetti celebrations.
- **French TTS + speech recognition** via device services (fr-FR), with
  honest scoring (transcription similarity, never fake "pronunciation"
  scores) and a no-microphone practice path.
- **Designed for everyone** — Material 3 with a custom French-blue design
  system, intentional dark mode, reduced-animation setting, translations
  toggle for French-first learning.

## Getting started

```bash
flutter pub get
flutter run          # debug: includes the dev-only Debug tools screen
flutter analyze && flutter test
```

## Project layout

See `docs/architecture.md`. Content authoring format: `docs/content-format.md`.
Release checklist: `docs/release.md`.

## Adding content

Drop new unit JSON files into `assets/content/<level>/` (schema in
`docs/content-format.md`) and they appear in the course automatically —
`LocalCourseRepository` discovers unit files from the asset manifest, so no
Dart changes are needed. Follow `docs/authoring-brief-levels.md` for level
calibration and `docs/syllabus-<level>.md` for the planned unit list.
