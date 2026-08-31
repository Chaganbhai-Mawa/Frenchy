# Authoring brief — A2 to C2 course levels

Read `docs/content-format.md` first (JSON schema + exercise contract) and
skim `assets/content/a1/unit_01.json` as the structural reference.

## Per-unit requirements (all levels)

- File: `assets/content/<level>/unit_NN.json`, id `<level>_uNN`
  (e.g. `a2_u01`), field `level` uppercase ("A2").
- 3 lessons per unit, ids `<level>_uNN_lMM`.
- Per lesson sections IN THIS ORDER:
  learn (2–3 blocks, 4–6 examples each) → vocabulary (30–38 items) →
  grammar (1–2 blocks, when the lesson introduces grammar) → listening (3–4) →
  speaking (3) → reading (1 passage + 2–3 questions) → writing (3) →
  practice (5–6 mixed) → quiz (5).
- Unit vocabulary total must land between 100 and 130 items. EVERY item
  carries full detail: id (kebab-case, globally unique across the course —
  prefix level-specific words like `a2-...` only if needed to disambiguate),
  french, english, partOfSpeech, gender+plural for nouns, pronunciation,
  example (natural French sentence), exampleEnglish, level, category.
- Exercise ids `<lessonId>_li01/sp01/rd01/wr01/pr01/qz01…`, globally unique.
- estimatedMinutes: A2 14–16, B1 16–18, B2/C1/C2 18–20.
- No video sections (curated separately).

## Level calibration

- **A2**: everyday topics, passé composé / imparfait / futur, connected
  sentences. English support everywhere. Reading 6–10 lines.
- **B1**: narration, opinions, conditional, subjunctive introduction,
  relative pronouns (qui/que/dont/où). French-first: explanations still in
  English but examples richer; reading 10–14 lines with idiomatic French.
- **B2**: debate, argumentation, formal vs informal register, business
  French, advanced subjunctive, concession (bien que, quoique), idioms.
  Reading 12–16 lines, near-native phrasing.
- **C1**: academic and professional French, nuance, editorials, presentations,
  literary tenses (passé simple recognition), sophisticated connectors
  (néanmoins, en dépit de, quoi qu'il en soit). Reading: editorial/essay
  extracts 14–18 lines.
- **C2**: mastery — rhetoric, irony and humor, argot/verlan and regional
  variation, literature, translation subtleties, cultural references.
  Reading: dense literary/press texts 14–20 lines.

Keep the `english` translation fields filled at every level (the app hides
them behind "Show translation" — learners choose). French must be flawless:
accents, agreement, elision, register consistency, French spacing before
? ! : ; and « » quotes where natural.

## Orchestration

Author in waves of **3–5 concurrent agents, one unit each**. Launching a
dozen at once reliably kills them all with mid-stream stalls. If a wave
dies, resume the same agents (their partial files continue) rather than
starting fresh ones, and repair any unparseable leftovers first — trim to
the last complete lesson, then drop trailing lessons that lack a `quiz`
section.

## Method (critical)

Author incrementally: many small Write/Edit calls (~60–100 lines each),
one section at a time; never one giant write. One short sentence max
between tool calls.

**`ConvertFrom-Json` alone is not proof the content is complete.** It only
checks JSON syntax — a stub like `{"id": "__L__"}` or a lesson missing
grammar/listening/quiz sections still "parses". Before reporting a unit
done:
1. `Get-Content -Raw <file> | ConvertFrom-Json | Out-Null` (syntax).
2. For every lesson, list its section `type`s and confirm all 9 are
   present with real content (grep `"type":` within that lesson's range
   and count them — don't just trust your own memory of what you wrote).
3. Confirm every lesson id starts with `<levelDir>_u` and every exercise
   id follows `<lessonId>_<xx><nn>` — a placeholder id fails this
   trivially.
4. Check for duplicate exercise ids across the course.
State the section-type list per lesson in your final report as evidence,
not just "validated".

**Vocab `gender` field must be exactly `"m"` or `"f"`** — never `"m/f"`,
`"m ou f"`, or anything else. For dual-form profession/role words (e.g.
"le soliste / la soliste"), list the masculine form first in `french` and
use `"gender": "m"`, matching the convention already used ~30 times across
the course. `"m/f"` passes `ConvertFrom-Json` but fails the app's model.
