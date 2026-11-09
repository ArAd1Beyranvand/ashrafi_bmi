# CLAUDE.md — Charder U310 Report (Flutter)

Small app: **Import page → A4 Report page**. Do not over-engineer.

## Read first (every prompt)
1. `docs/PROJECT_OVERVIEW.md`
2. `docs/DATA_CONTRACT.md`
3. `docs/DESIGN_SPECIFICATION.md`
4. `docs/FLUTTER_ARCHITECTURE.md`
5. `docs/OPEN_QUESTIONS.md` (open questions + decisions)
6. `docs/IMPLEMENTATION_ROADMAP.md` (update its checkboxes at the end of every prompt)

**`docs/reference/prototype.html` is the source of truth** for colors, sizes, fonts, spacing,
point lists and formulas. If a doc and the prototype disagree, the prototype wins (fix the doc).
`docs/reference/sample_input.b64` is a real device export; the parser is built around it.
Never guess unknowns: add them to `docs/OPEN_QUESTIONS.md`.

## Fixed decisions
- Flutter stable, Dart 3, null-safety. Targets: Linux desktop (dev), Android, web.
- State: `flutter_bloc` (Cubits) + `equatable`. No other state libs.
- Packages allowed: flutter_bloc, equatable, file_picker, desktop_drop, google_fonts (Montserrat,
  plus Montserrat bundled in `assets/fonts/` as fallback), pdf, printing. Ask before adding anything else.
- Navigation: `MaterialApp` + two named routes (`/` import, `/report`). No go_router.
- English only. Canvas `#DFE4E7`; the A4 sheet is always white (no dark sheet).
- A4 sheet = fixed `794 x 1123` logical px, `SizedBox` → `FittedBox` → `InteractiveViewer`
  (minScale 1, maxScale 4).
- Silhouettes = `CustomClipper<Path>` from a mirrored half-outline through a closed Catmull-Rom
  spline; the same `Path` is used for painting and clipping.
- Liquid in the Standard figure = `CustomPainter` driven by one repeating `AnimationController`,
  inside a `RepaintBoundary`; honours `MediaQuery.disableAnimations`.
- Body Type Trend, analysis bars = `CustomPainter`.

## Folder map
```
lib/
  main.dart, app.dart
  core/theme/      report_colors.dart, report_text.dart, gradients.dart
  core/utils/      catmull_rom.dart
  data/models/     person.dart, measurement.dart, segmental.dart, report_data.dart
  data/parser/     report_parser.dart   (raw JSON | base64 JSON -> ReportData)
  features/import/ cubit/, view/
  features/report/ cubit/, view/report_page.dart, view/a4_sheet.dart, widgets/, painters/
test/              mirrors lib/
assets/sample/sample_report.json, assets/fonts/
docs/              specs; docs/reference/ = prototype + real sample
```

## Commands
```
flutter pub get
flutter config --enable-linux-desktop
flutter run -d linux          # verify visually here
flutter analyze               # must be 0 issues
flutter test                  # must all pass
```
Missing Linux deps: `sudo apt install clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev libstdc++-12-dev`.
Visual check: screenshot the Linux app and compare with `docs/reference/prototype.html`
rendered in a headless browser at 794 px width.

## Definition of done (every prompt)
- Feature matches the prototype (checked on Linux desktop, side-by-side where visual).
- `flutter analyze` → 0 issues; `flutter test` → all pass; new logic has unit tests
  (parser, spline, band mapping, bar position, derived values).
- `docs/IMPLEMENTATION_ROADMAP.md` updated; new unknowns added to `docs/OPEN_QUESTIONS.md`.
