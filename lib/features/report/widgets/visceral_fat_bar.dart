import 'package:flutter/material.dart';

import '../../../core/theme/report_colors.dart';
import '../../../core/theme/report_text.dart';
import '../report_math.dart';

class VisceralFatBar extends StatelessWidget {
  const VisceralFatBar({super.key, required this.level, required this.label});

  final double level;
  final String label;

  Widget _tick(double w, double pct, String t) => Positioned(
    left: w * pct / 100 - 20,
    width: 40,
    top: 2,
    child: Text(
      t,
      textAlign: TextAlign.center,
      style: ReportText.visceralLabel,
    ),
  );

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(2, 8, 2, 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (_, c) {
              final w = c.maxWidth;
              return SizedBox(
                height: 30,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      width: w * .44,
                      bottom: 0,
                      height: 9,
                      child: const ColoredBox(color: ReportColors.visceralLow),
                    ),
                    Positioned(
                      left: w * .44,
                      right: 0,
                      bottom: 0,
                      height: 9,
                      child: const ColoredBox(color: ReportColors.visceralHigh),
                    ),
                    _tick(w, 2, '1'),
                    _tick(w, 44, '10'),
                    _tick(w, 96, '50'),
                    Positioned(
                      left: w * visceralPos(level) / 100 - 3.5,
                      top: 16,
                      width: 7,
                      height: 5,
                      child: CustomPaint(painter: _MarkerPainter()),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        SizedBox(
          width: 54,
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(text: '$label ', style: ReportText.visceralNumber),
                TextSpan(text: 'lv', style: ReportText.visceralUnit),
              ],
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    ),
  );
}

class _MarkerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width / 2, size.height)
        ..close(),
      Paint()..color = ReportColors.visceralMarker,
    );
  }

  @override
  bool shouldRepaint(_MarkerPainter old) => false;
}
