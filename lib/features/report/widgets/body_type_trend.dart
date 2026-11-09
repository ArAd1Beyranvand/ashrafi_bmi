import 'package:flutter/material.dart';

import '../painters/body_type_painter.dart';

/// Body Type Trend chart scaled to the available width (270×290 design space).
class BodyTypeTrend extends StatelessWidget {
  const BodyTypeTrend({
    super.key,
    required this.bodyFatPercent,
    required this.bmi,
  });

  final double bodyFatPercent;
  final double bmi;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 4),
    child: AspectRatio(
      aspectRatio: 270 / 290,
      child: RepaintBoundary(
        child: CustomPaint(
          painter: BodyTypePainter(bodyFatPercent: bodyFatPercent, bmi: bmi),
        ),
      ),
    ),
  );
}
