# iOS screenshots

Derived from the real Android screenshots in `../../store-listing/screenshots/phone/`
(captured from a running emulator with the actual app — see that folder's README) rather
than recaptured from scratch, since there's no Mac/iOS Simulator available in this
environment. Since Flutter renders the same widget tree on both platforms, the UI is
pixel-identical in content — only the platform status bar differs, which App Review
doesn't scrutinize as long as the app's own UI is accurately represented.

## How these were generated

Each source image (1440×2560, 16:9) doesn't share an aspect ratio with Apple's required
sizes (~19.5:9), so a plain resize would either stretch/distort the UI or crop off content
(a first attempt at center-cropping clipped text and the bottom nav bar on both edges —
don't do that). Instead, each image is:

1. Scaled to fit the **target width** exactly (preserves aspect ratio, no distortion).
2. Centered vertically on a canvas of the exact target size, with the small remaining
   top/bottom gap filled using a background color **sampled from the screenshot itself**
   (pixel near the corner) — so the padding blends in rather than showing as visible bars.

```python
from PIL import Image
im = Image.open(src).convert('RGB')
scale = target_w / im.width
im2 = im.resize((target_w, round(im.height * scale)), Image.LANCZOS)
bg = im.getpixel((3, 3))
canvas = Image.new('RGB', (target_w, target_h), bg)
canvas.paste(im2, (0, (target_h - im2.height) // 2))
```

## Folders

| Folder | Size | Apple device class |
|---|---|---|
| `iphone-6.5-1242x2688/` | 1242×2688 | 6.5" (iPhone 11 Pro Max / XS Max class) |
| `iphone-6.7-1284x2778/` | 1284×2778 | 6.7" (iPhone 12/13/14 Pro Max class) |
| `ipad-12.9-2048x2732/` | 2048×2732 | 12.9" iPad Pro |
| `ipad-13-2064x2752/` | 2064×2752 | 13" iPad Pro |

Same 8 screens as the Play Store set in every folder (`01_home.png` … `08_about.png`).

### iPad note: pillarboxed, not a real tablet layout

The app has no tablet-specific/adaptive layout (Flutter's default project is universal,
but every screen uses the same single-column mobile UI regardless of screen size). The
iPad screenshots are the phone UI scaled up and **pillarboxed** (padded left/right, not
top/bottom — the opposite of the iPhone sizes, since an iPad canvas is proportionally much
wider relative to height than a phone) rather than stretched to fill the whole frame,
which would distort the UI. This is standard and Apple-accepted for apps without a
distinct iPad layout — the alternative (restricting the app to iPhone-only via
`TARGETED_DEVICE_FAMILY = 1` in Xcode) removes the need for iPad screenshots entirely if
you'd rather do that instead.

```python
# iPad variant of the script above: fit to HEIGHT then pad left/right
# (iPhone fits to WIDTH then pads top/bottom — the two required device
# classes have opposite width/height relationships to the phone source).
scale = target_h / im.height
im2 = im.resize((round(im.width * scale), target_h), Image.LANCZOS)
canvas = Image.new('RGB', (target_w, target_h), bg)
canvas.paste(im2, ((target_w - im2.width) // 2, 0))
```

## If App Store Connect asks for a different/larger size

Apple's required sizes change over time (e.g. newer 6.9" iPhone 16 Pro Max class at
1320×2868 wasn't requested when these were made). Re-run the script above with the new
target dimensions — it works for any size derived from the same 16:9 source screenshots.

## Regenerating after a UI change

If the app's screens change, first recapture the Android source set (see
`../../store-listing/screenshots/README.md`), then re-run the script above against the
new source files.
