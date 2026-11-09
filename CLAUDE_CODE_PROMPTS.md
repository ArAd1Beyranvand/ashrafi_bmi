# Charder U310 Report — Flutter Implementation Prompts

Small project: **Import page → A4 Report page**. Data comes from a JSON file (raw or base64‑encoded).
Visual source of truth: `docs/reference/prototype.html` (the approved A4 HTML).

## How to use

1. Create the Flutter project folder and copy the approved HTML to `docs/reference/prototype.html`.
   If you have a real data file, copy it to `docs/reference/sample_input.b64` (or `.json`).
2. Paste **Prompt 0** in a fresh Claude Code session. It writes `CLAUDE.md` + the docs.
3. Run prompts 1 → 7 in order. Run `/clear` between prompts; every prompt re-reads `CLAUDE.md` and the docs.
4. Prompts 4 and 6 may run in parallel (separate sessions/worktrees) after Prompt 3. Everything else is sequential.

| # | Task | Model | Effort | Needs | Parallel? |
|---|------|-------|--------|-------|-----------|
| 0 | Master context + docs | Opus | High | — | No |
| 1 | Setup + data layer | Sonnet | Medium | 0 | No |
| 2 | Import page + BLoC | Sonnet | Medium | 1 | No |
| 3 | A4 canvas + static sections | Sonnet | Medium | 2 | No |
| 4 | Analysis bars + visceral bar | Sonnet | Low | 3 | With 6 |
| 5 | Body figures: clippers + wave | Opus | High | 3 | No (after 4/6) |
| 6 | Body Type Trend chart | Sonnet | Medium | 3 | With 4 |
| 7 | Export (PDF/PNG) + final QA | Sonnet → Opus for QA | Medium | 1–6 | No |

Why: Opus only where judgement is needed (writing the architecture, porting spline/wave math and pixel-matching figures). Everything else is well-specified UI work where Sonnet is faster and cheaper. Haiku is not recommended here: the visual fidelity work needs stronger reasoning.

---

## Prompt 0 — Master context (Opus, High)

```
You are a senior Flutter engineer. We are building a SMALL Flutter app that renders a Charder U310
body-composition report. Do not over-engineer.

PRODUCT
- Screen 1 "Import": the user picks a data file (file picker button) or drags & drops it onto a
  drop zone (desktop). Accepted: .json, .txt, .b64. Content is JSON, either raw or base64-encoded.
- Screen 2 "Report": an exact Flutter reproduction of docs/reference/prototype.html — a fixed
  A4 sheet (794 x 1123 logical px) scaled to fit the screen, pinch/zoom/pan enabled, plus a toolbar
  with "Back", measurement selector, and "Export".
- English only. Light canvas around a white paper sheet (the sheet itself is always white).

SOURCE OF TRUTH
- docs/reference/prototype.html is the approved design. Read its CSS and JS for exact colors,
  sizes, fonts, spacing, point lists and formulas. Fidelity to it is a hard requirement.
- If docs/reference/sample_input.* exists, it is a real input file: inspect it and design the
  parser around it. If it does not exist, use the schema in DATA_CONTRACT.md below.

TECH DECISIONS (fixed)
- Flutter stable, Dart 3, null-safety. Targets: Linux desktop (primary for dev), Android, web.
- State: flutter_bloc (Cubit is fine) + equatable. No other state libs.
- Packages: flutter_bloc, equatable, file_picker, desktop_drop, google_fonts (Montserrat; also bundle
  Montserrat as an asset fallback), pdf + printing (export, Prompt 7). Nothing else without asking.
- Navigation: plain Navigator 2 not needed; use MaterialApp + two routes (go_router is NOT needed).
- Structure (feature-first):
  lib/
    main.dart, app.dart
    core/theme/ (report_colors.dart, report_text.dart, gradients.dart)
    core/utils/ (catmull_rom.dart)
    data/models/ (person.dart, measurement.dart, segmental.dart, report_data.dart)
    data/parser/ (report_parser.dart)  -> raw JSON or base64 JSON -> ReportData
    features/import/ (cubit/, view/)
    features/report/ (cubit/, view/report_page.dart, view/a4_sheet.dart, widgets/..., painters/...)
  test/ mirrors lib/.
- Custom drawing:
  * Body silhouettes = CustomClipper<Path> built from a mirrored half-outline through a CLOSED
    Catmull-Rom spline (exact point lists in DESIGN_SPECIFICATION.md). Same Path is reused for
    painting and clipping.
  * The Standard figure contains ANIMATED LIQUID: a CustomPainter clipped by the body clipper, driven
    by one AnimationController (repeat), wave
      y(x,t) = top + A·sin(0.05x + 1.5t + φ) + 0.4A·sin(0.13x − 2.2t + 1.6φ)
    two layers (A=4,φ=0 and A=3,φ=2), top = 406 − water%/100·400 in a 200x410 figure space.
    Respect MediaQuery.disableAnimations (A=0, t=0). Use RepaintBoundary; repaint only the painter.
  * Body Type Trend and analysis bars = CustomPainter.

RUNNING / VERIFYING
- When you need to run or visually check the app, run it on LINUX DESKTOP:
    flutter config --enable-linux-desktop
    flutter run -d linux
  If Linux build deps are missing, install them (clang cmake ninja-build pkg-config libgtk-3-dev
  liblzma-dev libstdc++-12-dev) or tell me the exact command.
- For visual comparison you may take screenshots of the running Linux app, and you may render
  docs/reference/prototype.html with a headless browser if available, to compare side by side.
- Always finish with: flutter analyze (0 issues) and flutter test (all pass).

YOUR TASK NOW (no app code yet)
1. Read docs/reference/prototype.html completely.
2. Create these files:
   - CLAUDE.md: short project rules (above decisions, commands, folder map, "read docs first",
     "prototype.html is source of truth", "run on Linux to verify", definition of done).
   - docs/PROJECT_OVERVIEW.md: purpose, 2 screens, user flow, out of scope (accounts, backend,
     multiple people, persistence, dark sheet).
   - docs/DATA_CONTRACT.md: the input format (see schema below), base64 detection rules, validation
     rules and error messages, derived values (current = last measurement, previous = the one before,
     first = index 0; history list for the Change table, max 7 columns).
   - docs/DESIGN_SPECIFICATION.md: every section of the A4 sheet with exact px sizes, colors,
     gradients, fonts, row heights, and the point lists + formulas copied from prototype.html
     (STAND and FLEX half-outlines, mirror rule x' = 200 − x, Catmull-Rom control points
     c1 = p1 + (p2 − p0)/6, c2 = p2 − (p3 − p1)/6, wave formula, body-type band mapping,
     analysis tick arrays and band ends, standard weight = 22·h², stdSMM = 0.45·stdW,
     stdBFM = 0.18·stdW). Also the Import page spec (below).
   - docs/FLUTTER_ARCHITECTURE.md: folders, cubits and their states, widget tree of the A4 sheet,
     which parts are CustomPainter / CustomClipper, scaling strategy (fixed 794x1123 SizedBox
     inside FittedBox inside InteractiveViewer, minScale 1, maxScale 4).
   - docs/IMPLEMENTATION_ROADMAP.md: prompts 1–7 with status checkboxes. Update it at the end of
     every later prompt.
3. Mark anything unknown as "OPEN QUESTION" instead of guessing.

INPUT SCHEMA (use unless the real sample says otherwise):
{
  "version": 1,
  "device": {"brand": "charder", "model": "U310"},
  "person": {"name": "CHARDER EGYPT", "id": "A00BF", "gender": "Male", "age": 29, "heightCm": 179},
  "measurements": [
    {"timestamp": "2024-01-01T18:34:29",
     "weight": 72.6, "bmi": 22.6, "visceralFat": 7, "bodyFatPercent": 21.2, "bodyFatMass": 15.4,
     "smm": 31.7, "leanMass": 53.9, "bodyWaterPercent": 57.7, "bodyAge": 36, "bmr": 1605,
     "boneMass": 3.3,
     "segmental": {
       "muscle": {"trunk": 25.3, "rightArm": 3.1, "leftArm": 3.1, "rightLeg": 8.8, "leftLeg": 8.8},
       "fat":    {"trunk": 8.9,  "rightArm": 0.6, "leftArm": 0.6, "rightLeg": 2.0, "leftLeg": 2.0}}}
  ]
}
Measurements are sorted by timestamp ascending by the parser.

IMPORT PAGE SPEC
- Same canvas color as the report (#DFE4E7). Centered card (max 520 px): small "charder" logo text,
  title "Open a report file", drop zone (dashed border, 180 px, icon + "Drag & drop a file here"
  + "or" + button "Choose file"), hint "JSON or base64-encoded JSON (.json, .txt, .b64)".
- States: idle, dragging (zone highlighted teal #2F8E94), loading (spinner), error (red message
  under the zone with the parser's specific reason, e.g. "This file is not valid base64 or JSON",
  "Missing field: measurements[0].weight"). On success navigate to Report.
- Also a "Load sample" text button that loads assets/sample/sample_report.json (for demo/testing).

Report back: list of files created and the open questions.
```

---

## Prompt 1 — Project setup + data layer (Sonnet, Medium)

```
Read CLAUDE.md, docs/DATA_CONTRACT.md and docs/FLUTTER_ARCHITECTURE.md first.

Goal: project foundation and a fully tested parser. No UI beyond a placeholder.

Do:
1. If no Flutter project exists, create it (flutter create --platforms=linux,android,web .).
   Add packages: flutter_bloc, equatable, file_picker, desktop_drop, google_fonts. (pdf/printing
   come in Prompt 7.)
2. Bundle Montserrat (400,500,600,700,800) in assets/fonts and register it in pubspec; configure
   google_fonts to not fetch at runtime (GoogleFonts.config.allowRuntimeFetching = false).
3. Models (immutable, Equatable, fromJson): Person, SegmentalValues (trunk, rightArm, leftArm,
   rightLeg, leftLeg), Measurement, ReportData {person, device, measurements (ascending)} with
   getters current, previous (or current if only one), first, history (last 7).
4. ReportParser.parse(Uint8List bytes) -> ReportData, throwing ReportParseException(message):
   - decode UTF-8 (strip BOM), trim;
   - if it starts with '{' -> JSON; else strip optional "data:...;base64," prefix and all whitespace,
     base64-decode (also accept URL-safe alphabet and missing padding), UTF-8, then JSON;
   - validate required fields with precise messages (field path); numbers may be int or double;
   - at least one measurement.
   If docs/reference/sample_input.* exists, make sure it parses (adapt mapping, update
   DATA_CONTRACT.md if the real schema differs).
5. assets/sample/sample_report.json: the CHARDER EGYPT sample (1 measurement) from the schema,
   plus assets/sample/sample_history.b64 = base64 of a 5-measurement file using these values
   (date, weight, bmi, fat%, smm, water, visceral, bodyAge, bmr, bone):
   2026-05-02 81.4 24.6 22.6 33.6 56.8 9 39 1702 3.3
   2026-06-14 80.1 24.2 21.8 33.9 57.3 8 38 1708 3.3
   2026-07-26 79.3 23.9 21.0 34.2 57.9 8 38 1714 3.4
   2026-09-12 78.6 23.7 20.2 34.6 58.4 7 37 1720 3.4
   2026-10-31 77.95 23.5 19.5 34.9 58.9 7 37 1725 3.4
   person: majid, id 09133317383, Male, 36, 182 cm; fat mass = w·fat/100, lean = w − fatMass;
   segmental scaled from muscle {28.3,3.7,3.5,9.8,10.0} and fat {8.8,0.6,0.6,2.0,2.0}.
6. Tests: raw JSON, base64, base64 with data-URL prefix and newlines, URL-safe base64, invalid
   base64, invalid JSON, missing field message, sorting, previous/first getters, both asset files.

Do NOT build pages yet. Do not add packages beyond the list.
Acceptance: flutter analyze clean, flutter test green, `flutter run -d linux` shows the placeholder.
Update docs/IMPLEMENTATION_ROADMAP.md and report what changed.
```

---

## Prompt 2 — Import page + navigation (Sonnet, Medium)

```
Read CLAUDE.md, docs/DESIGN_SPECIFICATION.md (Import page) and docs/FLUTTER_ARCHITECTURE.md.
Prereq: Prompt 1 done.

Goal: working Import screen and navigation to an empty Report screen.

Do:
1. ImportCubit with states: ImportIdle, ImportDragging, ImportLoading, ImportError(message),
   ImportSuccess(ReportData). Methods: pickFile(), dropFiles(List<XFile>), loadSample(),
   setDragging(bool). Reading bytes must work on Linux, Android and web (use bytes, not paths, on
   web; file_picker withData: true).
2. ImportPage exactly per spec (drop zone with DropTarget from desktop_drop; on mobile/web the
   zone is a tap target that opens the picker). Keyboard: the "Choose file" button is focusable.
3. On success push ReportPage(data). ReportPage for now: AppBar-less toolbar with Back button and
   the person name; body placeholder. Provide ReportCubit(data) holding selectedIndex
   (default = last measurement) with select(int).
4. Widget tests: idle render, error message shown for invalid bytes, sample load navigates to
   ReportPage. Cubit tests for each transition.

Constraints: no report drawing yet; keep the parser untouched except bug fixes (with tests).
Verify on Linux: drag a file from the file manager onto the window.
Acceptance: analyze clean, tests green, drag & drop + picker + sample work on `flutter run -d linux`.
Update the roadmap and report.
```

---

## Prompt 3 — A4 canvas + static sections (Sonnet, Medium)

```
Read CLAUDE.md, docs/DESIGN_SPECIFICATION.md, docs/reference/prototype.html.
Prereq: Prompt 2 done.

Goal: the A4 sheet layout with every NON-custom-painted section pixel-matched to prototype.html.
Leave placeholders (same size boxes) for: analysis bars, segmental figures, Standard figure,
Body Type Trend chart.

Do:
1. core/theme: ReportColors (all hex values from the prototype CSS), the header gradient
   (#1C4785 0%, #245F8D 40%, #2F8E94 75%, #45AD9B 100%, left→right), ReportText styles
   (Montserrat, sizes/weights from CSS), tabular figures (FontFeature.tabularFigures()).
2. A4Sheet: SizedBox(794x1123), white, border 2 px #5C656B, padding 22/26/20, two columns
   470 px + 9 px gap + rest. Report page body: canvas #DFE4E7 → InteractiveViewer(minScale 1,
   maxScale 4, constrained false) → FittedBox(contain) → A4Sheet, centered, with margin 8.
   Must show the whole sheet on a phone and allow pinch-zoom/pan.
3. Sections (exact sizes/colors from CSS): logo row (red "charder®" #8D2525 33px, "U310"),
   identity strip (6 cols, per-column gradient slices, grey value row #ECECEC), section title bars,
   Body Composition Analysis table (283 px label cells + value cells, 21.6 px rows, #E3E3E3,
   italic grey descriptions), I-Shape panel right half (− ○ + matrix with #B8C6E6/#A9D5C8/#F3D7B3
   cells, black dot in the status column, legend), Visceral Fat bar (teal #A8D3D4 1–10, beige #F4D4A9
   10–50, labels 1/10/50, value "7 lv"), Body Age/Bone Mass/BMR trio, Compared To First And Last
   table (rows Result / Compare To First / Compare To Last / Max Results / Min Results), Body
   Composition Change table (Weight/SMM/PBF rows, dashed column separators, last 7 measurements,
   grey Test Date row).
4. Toolbar above the sheet: Back, measurement dropdown (dates of all measurements, changing it
   updates every section via ReportCubit), Export button (disabled until Prompt 7).
5. Status logic (Low/Normal/High) as pure functions in report/domain/status.dart with tests:
   weight 61.28–82.81 style ranges are derived from height (std weight 22·h², normal 85–115 %),
   SMM normal 90–110 % of 0.45·stdW, BFM normal 80–160 % of 0.18·stdW, PBF normal 10–25.
   (These drive the I-Shape dots and later the bars.)

Verify by running on Linux and comparing a screenshot with prototype.html at the same zoom.
Acceptance: layout matches the prototype within ~2 px per section; switching measurement updates
values; golden test of the A4Sheet (fonts loaded from assets) committed under test/goldens.
Update the roadmap and report differences you could not resolve.
```

---

## Prompt 4 — Analysis bars + visceral bar (Sonnet, Low) — may run parallel with 6

```
Read CLAUDE.md and the "analysis bars" part of docs/DESIGN_SPECIFICATION.md and the arow()/pos()
functions in docs/reference/prototype.html. Prereq: Prompt 3. Only touch
features/report/widgets/analysis_row.dart, painters/analysis_bar_painter.dart and their tests,
plus replacing the placeholders in the Muscle/Fat and Obesity sections.

Implement AnalysisRow(name, unit, subtitle, ticks[11], bands[(endTickIndex, color)], value,
label, showHeader) as in the prototype:
- label column 118 px (name 17 px weight 500, unit superscript, tiny grey subtitle);
- band strip 7 px high at y=8, colors blue #7D98CF, green #8FC6A2, beige #F4D9A7, red #C3202A;
  BMI last band is the striped dark red (repeating 18 px #C3202A / 4 px #8F1218);
- 11 tick labels (6.3 px) with 9 px tick marks; optional header Under/Normal/Over at 13/33/70 %;
- black value bar (#262C30, 5.5 px) at y=28 whose length = piecewise-linear position of value in
  the tick array; value label 8.5 px bold right after the bar; row separators 1.6 px #4C565C.
Rows: Weight (% of std), SMM (% of std), BFM (% of std), PBF (%), BMI (raw) with the tick arrays
and band ends from the prototype.
Tests: unit tests for the position function (edges, between ticks, clamp), golden for one row.
Acceptance: matches prototype screenshot; analyze/test green. Update roadmap, report.
```

---

## Prompt 5 — Body figures: CustomClipper + animated liquid (Opus, High)

```
Read CLAUDE.md, docs/DESIGN_SPECIFICATION.md (figures section) and in docs/reference/prototype.html
the functions spline(), mirror(), STAND, FLEX, standard(), segfig(), tick().
Prereq: Prompts 3, 4 and 6 merged (avoid conflicts in report_page/a4_sheet).

Goal: the three body figures, faithful to the prototype curves, with the liquid wave.

1. core/utils/catmull_rom.dart: Path closedCatmullRom(List<Offset> pts) using
   c1 = p1 + (p2 − p0)/6, c2 = p2 − (p3 − p1)/6 (cubicTo), wrapping indices; and
   List<Offset> mirrorHalf(List<Offset> half) = half + reversed(half[1..n−2]) with x' = 200 − x.
   Copy STAND and FLEX half-point lists EXACTLY from the prototype (200 x 410 design space).
2. BodyClipper extends CustomClipper<Path> (pose: standing | flex): builds the path once, scales
   it from 200x410 to the widget size (Matrix4 / Path.transform), shouldReclip only on pose/size.
3. StandardFigure (I-Shape panel, height 236): ClipPath(BodyClipper) containing:
   - base fill: vertical gradient #163F73 → #1F5D83 (45 %) → #3A9C9A, in figure space;
   - LiquidPainter (CustomPainter, repaint: Listenable animation): two wave layers per the formula
     in CLAUDE.md (step 5 px in x, 0..200), level from current bodyWaterPercent;
     layer 1 = gradient #5CC0AA at 22 %→45 % opacity, layer 2 = #7FD0BB at 15 % opacity.
   - AnimationController(duration ~ 4.2 s, repeat), t = controller.value·2π·k so motion is
     seamless; dispose correctly; if MediaQuery.disableAnimationsOf(context) → static (A = 0).
   - Wrap in RepaintBoundary so only the liquid repaints (check with the performance overlay that
     the rest of the sheet does not repaint).
   - When the selected measurement changes, animate the water level to the new value (600 ms,
     easeInOut) instead of jumping.
4. SegmentalFigure(kind muscle|fat), size per prototype (viewBox −115..315 x 0..410, height 166):
   flex pose filled with radial gradient #F7D9A6→#F1C98D plus a blurred glow (MaskFilter.blur,
   sigma ~3, 55 % opacity); standing pose for fat #DAE4F2→#C9D7EC. Dots (r 4.2, #2D353A), curved
   leader lines (cubic, 1.3 px #3D464C) to labels (name 11 px grey, value "8.8kg" 17 px w600),
   High/Normal/Low legend squares top-left. Below: the 5-column status strip (Right Leg, Right Arm,
   Trunk, Left Arm, Left Leg) with the vertical band gradient and marker line (muscle at 13 px,
   fat at 7 px from the top).
5. Tests: path is closed and symmetric (mirror check), clipper bounds equal the expected box,
   LiquidPainter shouldRepaint logic, golden with animations disabled.
Run on Linux; compare figures with prototype.html side by side and tune ONLY if a curve is
visibly wrong (do not change the point lists without telling me why).
Acceptance: smooth 60 fps wave on Linux, figures match the prototype silhouettes, analyze/test
green. Update roadmap, report.
```

---

## Prompt 6 — Body Type Trend chart (Sonnet, Medium) — may run parallel with 4

```
Read CLAUDE.md, docs/DESIGN_SPECIFICATION.md and typeChart() in docs/reference/prototype.html.
Prereq: Prompt 3. Only touch painters/body_type_painter.dart, widgets/body_type_trend.dart, tests,
and replace the chart placeholder.

BodyTypePainter in a 270x290 design space (scale to the panel width):
- grid square at (26,24) size 228, ONE diagonal linear gradient bottom-left → top-right:
  #1C4B86 → #2B7591 (50 %) → #4BAE9E;
- inner border 2 px inset, #BFE3DC 70 %; 2 inner lines each way #D6EFE9 80 %, 1.4 px;
- 9 white bold 8.5 px labels, multi-line where the prototype uses '|';
- black arrow axes (1.4 px, open chevron heads) from the bottom-left corner (offset 6) up and right;
- "BMI" rotated −90° at the left, "Body Fat (%)" 12 px below;
- marker: white circle r 4.5 (85 %) with a #2B7591 dot r 1.8, drawn 11 px above the computed point.
  Position: x by body-fat bands (0,10,25,40), y by BMI bands (12,18.5,25,35); each band maps to one
  cell, linear inside the cell, clamped to [0.15, 2.85] cells.
Tests: position mapping unit tests (Standard for 21.2 % / BMI 22.6), golden.
Acceptance: matches prototype; analyze/test green. Update roadmap, report.
```

---

## Prompt 7 — Export + final QA (Sonnet for export, then switch to Opus/Medium for the QA pass)

```
Read CLAUDE.md and all docs. Prereq: Prompts 1–6.

Part A — Export (Sonnet):
1. Add pdf and printing packages.
2. Export button → menu: "Save as PDF" and "Save as PNG".
   Capture the A4Sheet via a RepaintBoundary at pixelRatio 3 (pause the liquid animation at the
   current frame while capturing), then:
   - PNG: save via file_picker saveFile (Linux/Android) or download (web);
   - PDF: one A4 page with the image full-bleed (PdfPageFormat.a4, margin 0), via printing
     (Printing.layoutPdf / sharePdf) and a saved file option.
3. Tests: export service unit test with a fake capture.

Part B — QA (Opus, Medium):
1. Run on Linux. Compare the report with docs/reference/prototype.html for BOTH samples
   (sample_report.json and sample_history.b64) section by section; list and fix deviations.
2. Check: phone-size window (390x844) shows the whole sheet, pinch/zoom and pan work, measurement
   switching animates the water level, reduced-motion disables the wave, errors on bad files are
   clear, no overflow warnings, no jank (profile mode on Linux).
3. Final: flutter analyze clean, all tests + goldens green, README.md with run instructions
   (Linux deps, flutter run -d linux, input format link), roadmap fully checked.
Report: remaining known gaps vs the prototype, if any.
```
