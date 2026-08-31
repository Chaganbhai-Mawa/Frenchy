# Screenshots

Captured from a running Android emulator (`emulator-5554`) with the release APK installed,
using `adb`. Reproduce or add more any time:

```bash
# Install the latest release build
adb install -r build/app/outputs/flutter-apk/app-release.apk

# Launch fresh
adb shell am force-stop com.bonjourney.app
adb shell monkey -p com.bonjourney.app -c android.intent.category.LAUNCHER 1

# Capture (MSYS_NO_PATHCONV=1 is required in Git Bash on Windows, otherwise
# /sdcard/... gets mangled into a Windows path)
MSYS_NO_PATHCONV=1 adb shell screencap -p /sdcard/screen.png
MSYS_NO_PATHCONV=1 adb pull /sdcard/screen.png ./shot.png

# Tap coordinates are in the DEVICE's raw pixel space (this emulator: 1440x2560).
# The bottom nav bar sits at y≈2298: Home≈x143, Learn≈x431, Practice≈x719,
# Progress≈x1007, Profile≈x1295.
adb shell input tap <x> <y>
```

## Current set (`phone/`)

| File | Screen |
|---|---|
| `01_home.png` | Home dashboard — streak, daily challenge, continue-learning card |
| `02_learn.png` | Learn tab — CEFR level tabs (A1–C2) + unit list |
| `03_unit.png` | Unit detail — 3 lessons with progress |
| `04_lesson_dashboard.png` | Lesson dashboard — the 9-section checklist |
| `05_vocabulary_card.png` | Vocabulary flashcard with pronunciation + audio |
| `06_progress.png` | Progress tab — XP, streak, activity calendar |
| `07_practice.png` | Review Center — spaced repetition, mistakes, saved lessons |
| `08_about.png` | Profile / About screen — confirms the Bonjourney app name, version, and privacy summary |

All are 1440×2560 (9:16), well within Play Console's phone screenshot requirements
(min 320px, max 3840px per side, 16:9 or 9:16 aspect ratio, 2–8 images).

## Adding more (e.g. a quiz/exercise screen, dark mode, tablet)

- **Quiz/exercise screens**: from a vocabulary flashcard, tap the card to flip it, then
  tap "Got it!" repeatedly to advance through the deck — the lesson auto-advances into
  listening/speaking/practice/quiz screens with distinct UI (multiple choice, word
  arrangement, etc.) once vocabulary is complete.
- **Dark mode**: Settings → toggle dark theme, then repeat the capture flow above.
- **Tablet**: Play Console recommends at least one 7" and one 10" tablet screenshot if you
  want the listing to look native on tablets. Boot a tablet AVD and repeat the same flow.
