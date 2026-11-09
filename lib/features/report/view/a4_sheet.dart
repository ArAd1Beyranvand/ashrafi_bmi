import 'package:flutter/material.dart';

import '../../../core/theme/report_colors.dart';
import '../../../core/utils/format.dart';
import '../../../data/models/measurement.dart';
import '../painters/segmental_figure_painter.dart';
import '../../../data/models/segmental.dart';
import '../cubit/report_cubit.dart';
import '../domain/status.dart';
import '../../report/report_math.dart';
import '../painters/analysis_bar_painter.dart';
import '../widgets/analysis_row.dart';
import '../widgets/body_composition_table.dart';
import '../widgets/body_type_trend.dart';
import '../widgets/change_table.dart';
import '../widgets/common.dart';
import '../widgets/i_shape_panel.dart';
import '../widgets/segmental_panel.dart';
import '../widgets/top_bar.dart';
import '../widgets/trio_and_compare.dart';
import '../widgets/visceral_fat_bar.dart';

/// The fixed 794×1123 sheet (CSS px == logical px).
class A4Sheet extends StatelessWidget {
  const A4Sheet({super.key, required this.state, this.forExport = false});

  final ReportState state;

  /// Export drops the on-screen border colour and shadow (decision D2); layout is unchanged.
  final bool forExport;

  static const width = 794.0;
  static const height = 1123.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: forExport ? Colors.transparent : ReportColors.sheetBorder,
            width: 2,
          ),
          boxShadow: forExport
              ? null
              : const [
                  BoxShadow(
                    color: Color(0x2E000000),
                    offset: Offset(0, 4),
                    blurRadius: 24,
                  ),
                ],
        ),
        padding: const EdgeInsets.fromLTRB(26, 22, 26, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TopBar(model: state.data.device),
            const SizedBox(height: 6),
            IdentGrid(values: _identValues()),
            const SizedBox(height: 9),
            // Overflow is allowed (CSS overflow: visible), the columns start at the top.
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(width: 470, child: _leftColumn()),
                  const SizedBox(width: 9),
                  Expanded(child: _rightColumn()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _identValues() {
    final p = state.data.person;
    return [
      p.name,
      p.id,
      p.gender,
      state.age?.toString() ?? '–',
      fmtNum(p.heightCm),
      formatIdentDate(state.current.timestamp),
    ];
  }

  static Widget _gap(Widget a) =>
      Padding(padding: const EdgeInsets.only(bottom: 6), child: a);

  Widget _section(
    String title,
    Widget body, {
    bool center = false,
    bool small = false,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      SectionTitle(title, center: center, small: small),
      body,
    ],
  );

  Widget _leftColumn() {
    final m = state.current;
    final cols = state.changeColumns;
    List<String> cells(String Function(Measurement) f) => [
      for (var i = 0; i < 7; i++) i < cols.length ? f(cols[i]) : '',
    ];
    final seg = m.segmental;
    // Strip order: Right Leg, Right Arm, Trunk, Left Arm, Left Leg.
    List<Level?> levels(SegmentalValues? v) => v == null
        ? List<Level?>.filled(5, null)
        : [
            segmentLevel(v.rightLeg),
            segmentLevel(v.rightArm),
            segmentLevel(v.trunk),
            segmentLevel(v.leftArm),
            segmentLevel(v.leftLeg),
          ];

    return OverflowBox(
      alignment: Alignment.topCenter,
      minHeight: 0,
      maxHeight: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _gap(
            _section(
              'Body Composition Analysis',
              BodyCompositionTable(
                rows: [
                  ('Weight', 'Body Weight', '${fmtNum(m.weight)}kg'),
                  ('BMI', 'Body Mass Index', fmtNum(m.bmi)),
                  ('Visceral Fat', 'Visceral Fat Level', fmtNum(m.visceralFat)),
                  (
                    'Body Fat %',
                    'Percentage of body fat',
                    '${fmtNum(m.bodyFatPercent)}%',
                  ),
                  (
                    'Body Fat Mass',
                    'Weight of body fat',
                    '${fmtNum(m.bodyFatMass)}kg',
                  ),
                  ('SMM', 'Skeletal Muscle Mass', '${fmtNum(m.smm)}kg'),
                  ('Muscle Mass', 'Lean Body Mass', '${fmtNum(m.leanMass)}kg'),
                  (
                    'Body Water',
                    'Body Water Percentage',
                    '${fmtNum(m.bodyWaterPercent)}%',
                  ),
                  ('Body Age', 'Estimated Body Age', fmtNum(m.bodyAge)),
                  ('BMR', 'Basal Metabolic Rate', '${fmtNum(m.bmr)}kcal'),
                  ('Bone Mass', 'Bone Mineral Mass', '${fmtNum(m.boneMass)}kg'),
                ],
              ),
            ),
          ),
          _gap(
            _section(
              'Muscle / Fat Analysis',
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 2, 0, 4),
                child: _muscleFatRows(),
              ),
            ),
          ),
          _gap(
            _section(
              'Obesity Analysis',
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 2, 0, 4),
                child: _obesityRows(),
              ),
            ),
          ),
          _gap(
            _section(
              'Segmental Analysis',
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SegmentalPanel(
                        title: 'Segmental Muscle Analysis',
                        kind: SegmentKind.muscle,
                        values: seg.muscle,
                        levels: levels(seg.leanLevel),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SegmentalPanel(
                        title: 'Segmental Fat Analysis',
                        kind: SegmentKind.fat,
                        values: seg.fat,
                        levels: levels(seg.fatLevel),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _section(
            'Body Composition Change',
            ChangeTable(
              rows: [
                (
                  'Weight',
                  'kg',
                  'Total Body Weight',
                  cells((h) => '${fmtNum(h.weight)}kg'),
                ),
                (
                  'SMM',
                  'kg',
                  'Skeletal Muscle Mass',
                  cells((h) => '${fmtNum(h.smm)}kg'),
                ),
                (
                  'PBF',
                  '%',
                  'Percent Body Fat',
                  cells((h) => '${fmtNum(h.bodyFatPercent)}%'),
                ),
              ],
              dates: cells((h) => formatShortDate(h.timestamp)),
            ),
          ),
        ],
      ),
    );
  }

  static const _bandsStd = [
    AnalysisBand(2, bandBlue),
    AnalysisBand(4, bandGreen),
    AnalysisBand(7, bandBeige),
    AnalysisBand(10, bandRed),
  ];
  static const _bandsFat = [
    AnalysisBand(2, bandBlue),
    AnalysisBand(4, bandGreen),
    AnalysisBand(10, bandRed),
  ];

  Widget _muscleFatRows() {
    final m = state.current;
    final h = state.data.person.heightCm;
    return Column(
      children: [
        AnalysisRow(
          name: 'Weight',
          unit: 'kg',
          subtitle: 'Total Body Weight',
          ticks: const [55, 70, 85, 100, 115, 130, 145, 160, 175, 190, 205],
          bands: _bandsStd,
          value: m.weight / stdWeight(h) * 100,
          label: fmtNum(round1(m.weight)),
          showHeader: true,
        ),
        AnalysisRow(
          name: 'SMM',
          unit: 'kg',
          subtitle: 'Skeletal Muscle Mass',
          ticks: const [70, 80, 90, 100, 110, 120, 130, 140, 150, 160, 170],
          bands: _bandsStd,
          value: m.smm / stdSmm(h) * 100,
          label: fmtNum(round1(m.smm)),
        ),
        AnalysisRow(
          name: 'BFM',
          unit: 'kg',
          subtitle: 'Body Fat Mass',
          ticks: const [40, 60, 80, 100, 160, 220, 280, 340, 400, 460, 520],
          bands: _bandsFat,
          value: m.bodyFatMass / stdBfm(h) * 100,
          label: fmtNum(round1(m.bodyFatMass)),
          showRule: false,
        ),
      ],
    );
  }

  Widget _obesityRows() {
    final m = state.current;
    return Column(
      children: [
        AnalysisRow(
          name: 'PBF',
          unit: '%',
          subtitle: 'Percent Body Fat',
          ticks: const [0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50],
          bands: _bandsFat,
          value: m.bodyFatPercent,
          label: fmtNum(round1(m.bodyFatPercent)),
          showHeader: true,
        ),
        AnalysisRow(
          name: 'BMI',
          unit: 'kg/m²',
          subtitle: 'Body Mass Index',
          ticks: const [10, 15, 18.5, 21, 25, 30, 35, 40, 45, 50, 55],
          bands: const [
            AnalysisBand(2, bandBlue),
            AnalysisBand(4, bandGreen),
            AnalysisBand(5, bandBeige),
            AnalysisBand(10, bandRed, striped: true),
          ],
          value: m.bmi,
          label: fmtNum(round1(m.bmi)),
          showRule: false,
        ),
      ],
    );
  }

  Widget _rightColumn() {
    final m = state.current;
    final h = state.data.person.heightCm;
    final hist = state.history;
    final first = state.first;
    final prev = state.previous;

    String delta(double Function(Measurement) f, Measurement ref) =>
        fmtNum(round1(f(m) - f(ref)));
    String maxOf(double Function(Measurement) f) =>
        fmtNum(hist.map(f).reduce((a, b) => a > b ? a : b));
    String minOf(double Function(Measurement) f) =>
        fmtNum(hist.map(f).reduce((a, b) => a < b ? a : b));
    double w(Measurement x) => x.weight;
    double f(Measurement x) => x.bodyFatPercent;
    double s(Measurement x) => x.smm;

    return OverflowBox(
      alignment: Alignment.topCenter,
      minHeight: 0,
      maxHeight: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _gap(
            _section(
              'I-Shape',
              IShapePanel(
                weight: weightLevel(m.weight, h),
                smm: smmLevel(m.smm, h),
                bfm: bfmLevel(m.bodyFatMass, h),
                waterPercent: m.bodyWaterPercent,
              ),
              center: true,
            ),
          ),
          _gap(
            _section(
              'Body Type Trend',
              BodyTypeTrend(bodyFatPercent: m.bodyFatPercent, bmi: m.bmi),
              center: true,
            ),
          ),
          _gap(
            _section(
              'Visceral Fat',
              VisceralFatBar(
                level: m.visceralFat,
                label: fmtNum(m.visceralFat),
              ),
              center: true,
            ),
          ),
          _gap(
            Trio(
              values: [
                '${fmtNum(m.bodyAge)}Y',
                '${fmtNum(m.boneMass)}kg',
                '${fmtNum(m.bmr)}kcal',
              ],
            ),
          ),
          _section(
            'Compared To First And Last Measurement',
            CompareTable(
              rows: [
                (
                  'Result',
                  '${fmtNum(m.weight)}kg',
                  '${fmtNum(m.bodyFatPercent)}%',
                  '${fmtNum(m.smm)}kg',
                ),
                (
                  'Compare To First',
                  delta(w, first),
                  delta(f, first),
                  delta(s, first),
                ),
                (
                  'Compare To Last',
                  delta(w, prev),
                  delta(f, prev),
                  delta(s, prev),
                ),
                ('Max Results', maxOf(w), maxOf(f), maxOf(s)),
                ('Min Results', minOf(w), minOf(f), minOf(s)),
              ],
            ),
            center: true,
            small: true,
          ),
        ],
      ),
    );
  }
}
