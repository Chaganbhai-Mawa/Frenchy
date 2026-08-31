# Frenchly Content Format

Course content lives in `assets/content/<level>/unit_NN.json`. One file per unit.
The lesson engine renders whatever sections a lesson supplies, in the order supplied.
`assets/content/a1/unit_01.json` is the reference example — follow it exactly.

## Unit file

```json
{
  "id": "a1_u03",
  "level": "A1",
  "unit": 3,
  "title": "Numbers",
  "subtitle": "Count from zero to one hundred",
  "icon": "🔢",
  "lessons": [ ...Lesson ]
}
```

## Lesson

```json
{
  "id": "a1_u03_l01",
  "level": "A1",
  "unit": 3,
  "title": "Un, deux, trois",
  "description": "One sentence about the lesson.",
  "estimatedMinutes": 12,
  "sections": [ ...Section ]
}
```

Recommended section order: `learn`, `vocabulary`, (`grammar`), `listening`,
`speaking`, `reading`, `writing`, (`video`), `quiz`. Sections render in the
order given. `grammar` and `video` are optional per lesson.

## Sections

### learn / grammar (teaching blocks)

```json
{
  "type": "learn",
  "title": "Learn",
  "blocks": [
    {
      "heading": "Short heading",
      "body": "2–4 sentences of clear English explanation.",
      "examples": [
        { "french": "Bonjour !", "english": "Hello!", "note": "optional register note" }
      ],
      "tip": "Optional cultural or usage tip."
    }
  ]
}
```

### vocabulary

```json
{
  "type": "vocabulary",
  "title": "Vocabulary",
  "items": [
    {
      "id": "kebab-case-unique",
      "french": "pain",
      "english": "bread",
      "partOfSpeech": "noun",        // noun | verb | adjective | adverb | pronoun | expression | interjection | conjunction | number
      "gender": "m",                  // only for nouns: "m" or "f"
      "pronunciation": "pahn",        // simple English phonetic hint
      "example": "Je voudrais du pain.",
      "exampleEnglish": "I would like some bread.",
      "level": "A1",
      "category": "food"
    }
  ]
}
```

6–10 items per lesson. `id` must be globally unique — reuse the same id ONLY
for the same word (e.g. "bonjour" may repeat across lessons).

### reading

```json
{
  "type": "reading",
  "title": "Reading",
  "passages": [
    {
      "title": "French title",
      "french": "Short dialogue or paragraph.\nUse \\n between lines.",
      "english": "Faithful translation.",
      "questions": [ ...Exercise (multipleChoice / trueFalse) ]
    }
  ]
}
```

### listening / speaking / writing / practice / quiz

```json
{ "type": "listening", "title": "Listening", "items": [ ...Exercise ] }
```

### video (always optional)

```json
{
  "type": "video",
  "title": "Watch & Listen",
  "required": false,
  "items": [
    {
      "title": "...", "description": "...",
      "url": "https://www.youtube.com/watch?v=...",
      "provider": "youtube", "durationSeconds": 240,
      "level": "A1", "topic": "food", "required": false,
      "vocabulary": [ ...VocabItem ],
      "questions": [ ...Exercise ]
    }
  ]
}
```

## Exercise types

| type | required fields | notes |
|---|---|---|
| `listenChoose` | `french` (audio via TTS), `options`, `answer` | answer must equal one option |
| `listenType` | `french`, `answer`, `acceptedAnswers` | acceptedAnswers: accent-free/no-punctuation variants |
| `dictation` | `french`, `answer`, `acceptedAnswers` | harder listenType |
| `arrangeWords` | `words` (scrambled!), `answer`, `english` | answer = words joined by single spaces, in correct order, no trailing punctuation |
| `multipleChoice` | `prompt`, `options` (4), `answer` | |
| `trueFalse` | `prompt`, `options`: ["True","False"], `answer` | |
| `fillBlank` | `prompt` containing `___`, `answer` | one word answers preferred |
| `translate` | `prompt`, `english`, `answer`, `acceptedAnswers` | EN→FR |
| `match` | `pairs`: 4 × {french, english} | no `answer` field |
| `speak` | `french`, `english`, `prompt`, `tip` | tip = concrete pronunciation advice |

Every exercise needs a globally unique `id`: `<lessonId>_<xx><nn>`
(e.g. `a1_u03_l01_li01`, `..._sp02`, `..._rd01`, `..._wr03`, `..._qz05`).

## Quality rules

- French must be linguistically correct: accents, gender, elision (l', d', j'),
  spacing before ! ? : ; (French typography uses a space: `Ça va ?`).
- Natural, useful sentences — no machine-generated nonsense, no lorem ipsum.
- English explanations written for absolute beginners.
- Friendly tone; never punitive.
- Distractor options must be plausible but clearly wrong.
- Every lesson: learn ≥1 block (3–6 examples each), vocabulary 12–16 items,
  listening ≥3, speaking 3, reading 1 passage + 2 questions, writing 3,
  practice 5–6 mixed exercises (optional section, type "practice"),
  quiz 5.
- Every vocabulary item should carry full detail where applicable:
  gender, plural, pronunciation, example + exampleEnglish.
