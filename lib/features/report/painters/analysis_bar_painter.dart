import 'package:flutter/widgets.dart';

import '../../../core/theme/report_colors.dart';

/// A band ending at tick index [end]; [striped] is the BMI dark-red repeating pattern.
class AnalysisBand {
  const AnalysisBand(this.end, this.color, {this.striped = false});

  final int end;
  final Color color;
  final bool striped;
}

const bandBlue = Color(0xFF7D98CF);
const bandGreen = Color(0xFF8FC6A2);
const bandBeige = Color(0xFFF4D9A7);
const bandRed = Color(0xFFC3202A);
const bandStripeDark = Color(0xFF8F1218);

/// Header labels (x in %) shown above the band strip of the Weight and PBF rows.
const analysisHeader = [(13.0, 'Under'), (33.0, 'Normal'), (70.0, 'Over')];

/// Position of [v] on the tick scale in % (piecewise linear between equally spaced ticks, clamped).
double analysisPos(List<double> ticks, double v) {
  if (v <= ticks[0]) return 0;
  for (var i = 0; i < ticks.length - 1; i++) {
    if (v <= ticks[i + 1]) {
      return (i + (v - ticks[i]) / (ticks[i + 1] - ticks[i])) /
          (ticks.length - 1) *
          100;
    }
  }
  return 100;
}

TextStyle _style(double size, FontWeight w, Color c) => TextStyle(
  fontFamily: 'Montserrat',
  fontSize: size,
  fontWeight: w,
  color: c,
  height: 1.219,
);

/// Paints the 40 px high scale area: header, bands, ticks, value bar and its label.
class AnalysisBarPainter extends CustomPainter {
  const AnalysisBarPainter({
    required this.ticks,
    required this.bands,
    required this.value,
    required this.label,
    required this.showHeader,
  });

  final List<double> ticks;
  final List<AnalysisBand> bands;
  final double value;
  final String label;
  final bool showHeader;

  static const _tickMark = Color(0xFF9AA3A8);

  static String tickText(double t) =>
      t == t.roundToDouble() ? t.toInt().toString() : t.toString();

  void _text(
    Canvas canvas,
    String s,
    TextStyle st,
    double cx,
    double y, {
    double padLeft = 0,
    double? left,
  }) {
    final tp = TextPainter(
      text: TextSpan(text: s, style: st),
      textDirection: TextDirection.ltr,
    )..layout();
    final x = left ?? cx - (tp.width + padLeft) / 2 + padLeft;
    tp.paint(canvas, Offset(x, y));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final n = ticks.length;

    if (showHeader) {
      final st = _style(6.5, FontWeight.w400, const Color(0xFF58636A));
      for (final (p, t) in analysisHeader) {
        _text(canvas, t, st, p / 100 * w, -3);
      }
    }

    var x = 0.0;
    for (final b in bands) {
      final x1 = b.end / (n - 1) * w;
      final rect = Rect.fromLTRB(x, 8, x1, 15);
      if (b.striped) {
        canvas.save();
        canvas.clipRect(rect);
        canvas.drawRect(rect, Paint()..color = bandRed);
        for (var sx = x + 18; sx < x1; sx += 22) {
          canvas.drawRect(
            Rect.fromLTWH(sx, 8, 4, 7),
            Paint()..color = bandStripeDark,
          );
        }
        canvas.restore();
      } else {
        canvas.drawRect(rect, Paint()..color = b.color);
      }
      x = x1;
    }

    final tickStyle = _style(6.3, FontWeight.w400, const Color(0xFF6B757B));
    final markPaint = Paint()..color = _tickMark;
    for (var i = 0; i < n; i++) {
      final cx = i / (n - 1) * w;
      _text(canvas, tickText(ticks[i]), tickStyle, cx, 16, padLeft: 2);
      canvas.drawRect(Rect.fromLTWH(cx - .3, 14, .6, 9), markPaint);
    }

    final barW = analysisPos(ticks, value) / 100 * w;
    canvas.drawRect(
      Rect.fromLTWH(0, 28, barW, 5.5),
      Paint()..color = ReportColors.visceralMarker,
    );
    _text(
      canvas,
      label,
      _style(8.5, FontWeight.w700, const Color(0xFF1F2529)),
      0,
      25,
      left: barW + 5,
    );
  }

  @override
  bool shouldRepaint(AnalysisBarPainter old) =>
      old.value != value ||
      old.label != label ||
      old.showHeader != showHeader ||
      old.ticks != ticks ||
      old.bands != bands;
}
