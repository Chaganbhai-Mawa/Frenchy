# Speaking module

## What we measure — and what we don't

Device speech recognition (`speech_to_text`, locale `fr_FR`) returns a
**transcription**. We compare it word-by-word to the expected phrase
(accent- and punctuation-insensitive, edit distance ≤1 for words > 4 chars)
and report a **"% recognized"** similarity score.

We deliberately do **not** claim phonetic accuracy: the platform API cannot
measure pronunciation quality, and the UI copy says "recognized", never
"pronunciation score". Threshold: ≥60% similarity counts the exercise as
passed; ≥90% earns the enthusiastic message.

## Error handling

`SpeechService.listenFor` resolves with a `SpeechAttempt` that either has a
transcript+similarity or a friendly `error` string. Handled cases:

- recognition unavailable / initialization failure
- permission denied (surfaces as unavailable; Android runtime prompt is
  triggered by the plugin on first listen — only inside speaking exercises,
  never at app launch)
- no speech detected
- engine timeout (8 s listen, 3 s pause, 5 s final timeout)

Every speaking exercise offers **"Practice without mic"**: learners listen
and repeat, then continue with full credit. Speech hardware must never block
course progression.

## Privacy

Transcripts are used only to compute the similarity score for the current
attempt and are discarded; no audio or transcript is stored.
