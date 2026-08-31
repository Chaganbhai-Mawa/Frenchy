# Audio

## Current approach: device TTS

All lesson audio is produced on-device with `flutter_tts` configured for
`fr-FR` (see `TtsService`). This keeps the app fully offline and the APK
small. Learner-facing controls: play, slow replay ("turtle"), voice speed
setting (0.3–0.7 rate), global sound toggle.

If no French voice is installed, `TtsService.isFrenchAvailable` is false and
`AudioButton` shows a friendly hint pointing to system TTS settings — the
app never crashes or silently pretends audio played.

## Adding recorded audio later

`TtsService` is the single audio entry point (widgets use `AudioButton`,
never raw plugin calls). To introduce human recordings:

1. Bundle files under `assets/audio/<level>/` using stable names, e.g.
   `a1_greetings_001.mp3`.
2. Add an `audio` field to vocabulary/exercise JSON entries.
3. Extend the audio service to prefer a bundled file and fall back to TTS.

No widget code needs to change.
