# Implementation Roadmap

Prompts are in `CLAUDE_CODE_PROMPTS.md`. Update this file at the end of every prompt.

- [x] **0 — Master context + docs** (CLAUDE.md, docs/*, reference files copied into docs/reference)
- [x] **1 — Project setup + data layer**: pubspec deps, fonts/sample assets, models, parser
      (device format, base64 detection, error messages), report_math, unit tests
- [x] **2 — Import page + navigation**: ImportCubit, drop zone (desktop_drop), file picker,
      Load sample, error/loading/dragging states, route to Report
- [x] **3 — A4 canvas + static sections**: ReportCubit, toolbar, InteractiveViewer/FittedBox,
      top bar, ident, body composition table, segmental strips, change table, trio, compare table
- [x] **4 — Analysis bars + visceral bar** (parallel with 6): analysis bars done (AnalysisRow +
      AnalysisBarPainter, 5 rows wired into Muscle/Fat and Obesity, unit tests + row golden);
      side-by-side screenshot vs prototype still to be checked by eye
- [x] **5 — Body figures**: Catmull-Rom clipper, Standard figure + animated liquid, segmental figures
- [x] **6 — Body Type Trend chart** (parallel with 4)
- [x] **7 — Export (PDF/PNG) + final QA** (side-by-side vs prototype, analyze/test clean)

## Open questions to resolve
See `docs/OPEN_QUESTIONS.md` — read it at the start of every prompt.

Prompt 2 notes: `cross_file` added as a direct dep (already transitive via file_picker/desktop_drop;
needed for `XFile`). file_picker 13 has no `withData`; bytes are read via `PlatformFile.xFile.readAsBytes()`
(works on web/Android/Linux). Manual drag-and-drop check on Linux still to be done by hand.

Prompt 6 notes: BodyTypePainter (+ BodyTypeTrend widget) done for the single current measurement; the D5 7-point history trail is not drawn yet (prompt scope was one marker).

Prompt 5 notes: point lists copied verbatim (no tuning; golden matches the prototype side by side).
The wave loop is 8.4 s with phases 2π·2·v / 2π·3·v (≈1.496 and 2.244 rad/s vs the prototype's 1.5 and
2.2) so the loop is seamless; a 4.2 s loop cannot close the 2.2 term. Water level tweens 600 ms
easeInOut. Widget tests that use pumpAndSettle on the report now set disableAnimations (the wave
repeats forever). Still to do by hand: performance-overlay / 60 fps check on the Linux report page.

Prompt 7 notes: Export menu (Save as PDF / Save as PNG / Print / Share…) via `ExportService`
(injectable capture + saver, unit-tested). Capture = `RepaintBoundary.toImage(pixelRatio: 3)` with the
sheet in a `TickerMode(enabled: false)` (wave frozen) and `A4Sheet(forExport: true)` (no border colour/shadow, D2).
The dev shortcut in `main.dart` was removed (import page is first again). Phone-size (390x844) widget
test covers fit, pinch zoom and no layout exceptions for both samples.
Known gaps / not verified: (1) frame timing in profile mode was not measured with DevTools; the profile
build used ~90 % of one CPU core while the wave animates — check on real hardware;
(2) actual save dialogs / Printing.layoutPdf were not exercised by hand; (3) segmental strip markers and the
visceral marker follow decisions D3/D6 (real data) and so differ from the static prototype; strip markers are
absent when the file has no level fields; (4) D5 history trail in Body Type Trend not drawn (Prompt 6 note).
