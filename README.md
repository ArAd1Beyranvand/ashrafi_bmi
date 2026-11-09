# Charder U310 Report

Flutter app: import a Charder U310 export, see it as the one-page A4 report, export it as PDF/PNG.
Targets: Linux desktop (dev), Android, web. Design source of truth: `docs/reference/prototype.html`.

## Run

```bash
# Linux build dependencies (Debian/Ubuntu)
sudo apt install clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev libstdc++-12-dev

flutter pub get
flutter config --enable-linux-desktop
flutter run -d linux            # add --profile to check performance
flutter run -d chrome           # web
```

```bash
flutter analyze   # 0 issues
flutter test      # includes golden tests (update with --update-goldens)
```

## Input format

`.json`, `.txt` or `.b64` file whose content is the device JSON, raw or base64-encoded.
Format and field meanings: [`docs/DATA_CONTRACT.md`](docs/DATA_CONTRACT.md); a real export is in
`docs/reference/sample_input.b64`. "Load sample" on the import page uses `assets/sample/sample_report.json`.
The person name is taken from the file name prefix before the first `_`.

## Export

Report page → **Export**: *Save as PDF* (one A4 page, image full-bleed), *Save as PNG*,
*Print / Share…* (system dialog). The sheet is captured at pixelRatio 3 with the wave paused,
without the on-screen border and shadow.

## Docs

`docs/` holds the specs, open questions (`OPEN_QUESTIONS.md`) and the roadmap.
