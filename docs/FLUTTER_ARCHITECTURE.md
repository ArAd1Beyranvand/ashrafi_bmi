# Flutter Architecture

## Folders
```
lib/
  main.dart                 runApp(App)
  app.dart                  MaterialApp, routes '/' → ImportPage, '/report' → ReportPage(args: ReportData)
  core/theme/report_colors.dart   all hex colours from DESIGN_SPECIFICATION
  core/theme/report_text.dart     TextStyle helpers (Montserrat via google_fonts, asset fallback, tabular figures)
  core/theme/gradients.dart       G, ident, trio, compare, figure gradients
  core/utils/catmull_rom.dart     mirror(), closedCatmullRom(points) → Path
  data/models/                    Person, Measurement, Segmental(+SegmentValues), ReportData (Equatable)
  data/parser/report_parser.dart  ReportParser.parse(bytes, fileName) → ReportData | throws ReportParseException
  features/import/cubit/import_cubit.dart, import_state.dart
  features/import/view/import_page.dart, widgets/drop_zone.dart
  features/report/cubit/report_cubit.dart, report_state.dart
  features/report/view/report_page.dart   toolbar + InteractiveViewer
  features/report/view/a4_sheet.dart      the 794×1123 sheet
  features/report/widgets/   top_bar, ident_grid, section_title, body_composition_table,
                             analysis_row, segmental_panel, change_table, i_shape_panel,
                             standard_figure, body_type_trend, visceral_fat_bar, trio, compare_table
  features/report/painters/  body_clipper.dart, liquid_painter.dart, analysis_bar_painter.dart,
                             body_type_trend_painter.dart, segmental_figure_painter.dart
  features/report/report_math.dart   stdW/stdSMM/stdBFM, pos(), band(), round1, history derivation
test/ mirrors lib/ (parser, catmull_rom, report_math, cubits, golden/widget smoke tests)
```

## Cubits
**ImportCubit** — `ImportState`
- `ImportIdle`, `ImportDragging`, `ImportLoading`, `ImportError(message)`, `ImportSuccess(ReportData)`.
- Methods: `dragEntered()`, `dragExited()`, `pickFile()` (file_picker, `withData: true` for web),
  `dropFiles(List<XFile>)`, `loadSample()` (rootBundle), internal `_parse(bytes, name)`.
- View: `BlocConsumer`; on `ImportSuccess` → `Navigator.pushNamed('/report', arguments: data)`
  then reset to idle.

**ReportCubit** — `ReportState(data, selectedIndex)` (Equatable) with getters derived via
`report_math`: `current`, `history`, `previous`, `first`, `changeColumns` (≤7), `maxMin`.
- Default `selectedIndex = data.measurements.length − 1`. Method `select(int)`.
- Export state (Prompt 7): `exporting` flag / one-shot result; kept minimal.

## Report page widget tree
```
Scaffold(bg #DFE4E7)
 └ Column
    ├ Toolbar: Back | Spacer | DropdownButton<int> (measurements) | Export
    └ Expanded
       └ InteractiveViewer(minScale 1, maxScale 4, boundaryMargin: zero)
          └ Center → Padding(8) → FittedBox(fit: BoxFit.scaleDown)   // D1: never above 1.0
             └ RepaintBoundary(key: sheetKey)        // used for PNG/PDF capture
                └ SizedBox(794, 1123) → A4Sheet(state)
A4Sheet: DecoratedBox(white, border 2 #5C656B, shadow) → Padding(22,26,20,26) → Column
 ├ TopBar (44)
 ├ IdentGrid (Row of Expanded flex 13/7/8/8/8/14)
 ├ SizedBox(9)
 └ Row(crossAxis start)
    ├ SizedBox(w 470) Column(gap 6)
    │   ├ Section("Body Composition Analysis", BodyCompositionTable)
    │   ├ Section("Muscle / Fat Analysis", 3× AnalysisRow → CustomPaint(AnalysisBarPainter))
    │   ├ Section("Obesity Analysis", 2× AnalysisRow)
    │   ├ Section("Segmental Analysis", Row[SegmentalPanel(muscle), SegmentalPanel(fat)])
    │   └ Section("Body Composition Change", ChangeTable)
    ├ SizedBox(9)
    └ Expanded(259) Column(gap 6)
        ├ Section("I-Shape", Row[StandardFigure, IShapeMatrix+Legend])
        ├ Section("Body Type Trend", CustomPaint(BodyTypeTrendPainter))
        ├ Section("Visceral Fat", VisceralFatBar)
        ├ Trio
        └ Section("Compared To First And Last Measurement", CompareTable)
```
Fixed heights from the spec are applied with `SizedBox`; grids are `Row`s of fixed/`Expanded`
widths (no Table where borders differ per cell). Text uses `TextHeightBehavior` /
`height` values tuned to match CSS line boxes (verify with screenshots).

## Custom drawing
| Part | Type |
|---|---|
| STAND / FLEX silhouettes | `BodyClipper extends CustomClipper<Path>` (scales the 200×410 path to size); path built once (static final) from `catmull_rom.dart` |
| Standard figure body fill | `CustomPaint` drawing the same path with the linear gradient |
| Liquid | `LiquidPainter(top, animation)` — `CustomPainter(repaint: controller)` inside `ClipPath(clipper: BodyClipper.stand)` inside `RepaintBoundary`; one `AnimationController(duration: e.g. 1 h).repeat()` in a `StatefulWidget` (t = elapsed seconds); if `MediaQuery.disableAnimations` → no ticking, A=0, t=0 |
| Segmental figures (glow, gradient, legend, dots, leaders, labels) | `SegmentalFigurePainter` (blur via `MaskFilter.blur(BlurStyle.normal, 3·scale)` or `ImageFilter`) in a 231×166 box, viewBox −115 0 430 410 with meet-fit |
| Analysis bars (bands, ticks, headers, value bar, label) | `AnalysisBarPainter` (322×40) |
| Body Type Trend | `BodyTypeTrendPainter` (viewBox 270×290 scaled to width 259) |
| Visceral bar, strips, I-Shape matrix | plain widgets (`Container`s / gradients) |

## Scaling strategy
The sheet is always laid out at exactly 794×1123 so all spec px values are used verbatim.
`FittedBox(BoxFit.scaleDown)` shrinks it to the available area (never enlarges, D1); `InteractiveViewer` (minScale 1,
maxScale 4) adds pinch/zoom/pan on top. Export renders the same `A4Sheet` (PNG via
`RepaintBoundary.toImage(pixelRatio: 3)`; PDF via `pdf`/`printing` embedding that image on an
A4 page — exact method decided in Prompt 7).

## Fonts
`google_fonts` Montserrat with `GoogleFonts.config.allowRuntimeFetching` kept on, and the
Montserrat TTFs (400/500/600/700/800 + italic 400) bundled under `assets/fonts/` and declared in
`pubspec.yaml` as family `Montserrat` so offline/export rendering is identical.
