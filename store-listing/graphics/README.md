# Regenerating store graphics

Both files here were generated from `assets/branding/app_icon.png` (1024×1024) using
Windows' built-in `System.Drawing`, no external tools required. Re-run these any time
the branding changes.

## icon-512.png (Play Store hi-res icon, required, 512×512 PNG, 32-bit with alpha)

```powershell
Add-Type -AssemblyName System.Drawing
$src = [System.Drawing.Image]::FromFile('assets\branding\app_icon.png')
$icon512 = New-Object System.Drawing.Bitmap 512,512
$g = [System.Drawing.Graphics]::FromImage($icon512)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$g.DrawImage($src, 0, 0, 512, 512)
$g.Dispose()
$icon512.Save('store-listing\graphics\icon-512.png', [System.Drawing.Imaging.ImageFormat]::Png)
$icon512.Dispose(); $src.Dispose()
```

## feature-graphic-1024x500.png (Play Store feature graphic, required, exactly 1024×500 JPG or 24-bit PNG, no alpha)

See the full script in this session's history, or recreate similarly: gradient navy→blue
background (`#16295F` → `#226EEB`, matching the in-app splash/theme colors), the app icon
on a rounded white card at the left, "Bonjourney" in bold white 58pt Segoe UI, and a two-line
tagline below it in a warm off-white. Keep all text left of x≈950 so nothing clips at the
1024px edge, and keep the icon+wordmark within the center-safe zone since Play may crop
edges on some surfaces.

**Play Store requirement note:** the feature graphic must not contain transparency — flatten
to a solid background (already done above) before uploading.

## If you change the mascot/icon later

1. Replace `assets/branding/app_icon.png` (keep it square, ideally ≥1024×1024).
2. Re-run `flutter pub run flutter_launcher_icons` to regenerate the in-app Android icons.
3. Re-run both scripts above to regenerate the Play Store graphics.
4. Re-capture screenshots (see `../screenshots/README.md`) if the icon appears in-app.
