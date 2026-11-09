import 'package:flutter/material.dart';

import '../../../core/theme/gradients.dart';
import '../../../core/theme/report_colors.dart';
import '../../../core/theme/report_text.dart';
import '../../../data/models/segmental.dart';
import '../domain/status.dart';
import '../painters/segmental_figure_painter.dart';

/// One Segmental column: sub-title, figure (231×166) and the 5-cell strip.
class SegmentalPanel extends StatelessWidget {
  const SegmentalPanel({
    super.key,
    required this.title,
    required this.kind,
    required this.values,
    required this.levels,
  });

  final String title;
  final SegmentKind kind;

  /// Segment masses (kg) shown next to the figure.
  final SegmentalValues values;

  /// Right Leg, Right Arm, Trunk, Left Arm, Left Leg (null → no marker).
  final List<Level?> levels;

  static const _names = [
    'Right Leg',
    'Right Arm',
    'Trunk',
    'Left Arm',
    'Left Leg',
  ];

  static double _markerTop(Level l) => switch (l) {
    Level.high => 7,
    Level.normal => 13,
    Level.low => 19,
  };

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Container(
        width: double.infinity,
        decoration: BoxDecoration(gradient: ReportGradients.g),
        height: 23,
        alignment: Alignment.center,
        child: Text(title, style: ReportText.segTitle),
      ),
      SizedBox(
        height: 166,
        width: double.infinity,
        child: CustomPaint(
          painter: SegmentalFigurePainter(kind: kind, values: values),
        ),
      ),
      Row(
        children: [
          for (var i = 0; i < 5; i++) ...[
            if (i > 0) const SizedBox(width: 2),
            Expanded(
              child: Column(
                children: [
                  SizedBox(
                    height: 17,
                    child: Center(
                      child: Text(
                        _names[i],
                        softWrap: false,
                        textAlign: TextAlign.center,
                        style: ReportText.stripLabel,
                      ),
                    ),
                  ),
                  Container(
                    height: 24,
                    decoration: BoxDecoration(gradient: ReportGradients.strip),
                    child: levels[i] == null
                        ? null
                        : Stack(
                            children: [
                              Positioned(
                                left: 0,
                                right: 0,
                                top: _markerTop(levels[i]!),
                                child: Center(
                                  child: FractionallySizedBox(
                                    widthFactor: .4,
                                    child: Container(
                                      height: 1.6,
                                      color: ReportColors.stripMarker,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ],
  );
}
