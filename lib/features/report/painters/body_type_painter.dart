import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Body Type Trend chart in the prototype's 270×290 design space.
class BodyTypePainter extends CustomPainter {
  const BodyTypePainter({required this.bodyFatPercent, required this.bmi});

  final double bodyFatPercent;
  final double bmi;

  static const designSize = Size(270, 290);
  static const x0 = 26.0, y0 = 24.0, s = 228.0, c = s / 3;

  static const labels = [
    ['Athletic', 'Over Weight|Muscular', 'Obese'],
    ['Low Fat|Muscular', 'Standard', 'Over Fat'],
    ['Low Fat|Low Weight', 'Low Weight', 'Skinny Fat'],
  ];

  static const _axis = Color(0xFF1D2327);
  static const _axisLabel = Color(0xFF3A454C);

  /// Position in cells (0..3) along one axis, before clamping.
  static double band(double v, double a, double b, double lo, double hi) =>
      v < a
      ? (v - lo) / (a - lo)
      : v < b
      ? 1 + (v - a) / (b - a)
      : 2 + math.min(1.0, (v - b) / (hi - b));

  /// Computed point (without the marker's −11 offset) in design space.
  static Offset position(double bodyFatPercent, double bmi) {
    final cx = band(bodyFatPercent, 10, 25, 0, 40).clamp(.15, 2.85);
    final cy = band(bmi, 18.5, 25, 12, 35).clamp(.15, 2.85);
    return Offset(x0 + cx * c, y0 + s - cy * c);
  }

  static TextPainter _text(String t, double size, FontWeight w, Color color) =>
      TextPainter(
        text: TextSpan(
          text: t,
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: size,
            fontWeight: w,
            color: color,
            height: 1.219,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

  /// Draws [t] centred on x with its alphabetic baseline at y.
  static void _centered(Canvas canvas, TextPainter tp, double x, double y) {
    final b = tp.computeDistanceToActualBaseline(TextBaseline.alphabetic);
    tp.paint(canvas, Offset(x - tp.width / 2, y - b));
  }

  static void _arrow(Canvas canvas, Offset from, Offset to) {
    final p = Paint()
      ..color = _axis
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    canvas.drawLine(from, to, p);
    // Marker 10×10 in stroke-width units, refX/refY 5, chevron M1 1 L6 5 L1 9.
    const k = 1.4;
    final angle = (to - from).direction;
    canvas.save();
    canvas.translate(to.dx, to.dy);
    canvas.rotate(angle);
    canvas.scale(k);
    canvas.translate(-5, -5);
    canvas.drawPath(
      Path()
        ..moveTo(1, 1)
        ..lineTo(6, 5)
        ..lineTo(1, 9),
      p..strokeWidth = 1.4,
    );
    canvas.restore();
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / designSize.width);
    const grid = Rect.fromLTWH(x0, y0, s, s);
    canvas.drawRect(
      grid,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: [Color(0xFF1C4B86), Color(0xFF2B7591), Color(0xFF4BAE9E)],
          stops: [0, .5, 1],
        ).createShader(grid),
    );
    canvas.drawRect(
      grid.deflate(2),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = const Color(0xFFBFE3DC).withValues(alpha: .7),
    );
    final line = Paint()
      ..strokeWidth = 1.4
      ..color = const Color(0xFFD6EFE9).withValues(alpha: .8);
    for (final i in [1, 2]) {
      canvas.drawLine(Offset(x0 + i * c, y0), Offset(x0 + i * c, y0 + s), line);
      canvas.drawLine(Offset(x0, y0 + i * c), Offset(x0 + s, y0 + i * c), line);
    }
    for (var ri = 0; ri < 3; ri++) {
      for (var ci = 0; ci < 3; ci++) {
        final ls = labels[ri][ci].split('|');
        final cx = x0 + ci * c + c / 2;
        final cy = y0 + ri * c + c / 2 - (ls.length - 1) * 5.5 + 3;
        for (var k = 0; k < ls.length; k++) {
          _centered(
            canvas,
            _text(ls[k], 8.5, FontWeight.w700, Colors.white),
            cx,
            cy + k * 11,
          );
        }
      }
    }
    final pt = position(bodyFatPercent, bmi).translate(0, -11);
    canvas.drawCircle(
      pt,
      4.5,
      Paint()..color = Colors.white.withValues(alpha: .85),
    );
    canvas.drawCircle(
      pt,
      4.5,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = Colors.white,
    );
    canvas.drawCircle(pt, 1.8, Paint()..color = const Color(0xFF2B7591));

    _arrow(
      canvas,
      const Offset(x0 - 6, y0 + s + 6),
      const Offset(x0 - 6, y0 - 14),
    );
    _arrow(
      canvas,
      const Offset(x0 - 6, y0 + s + 6),
      const Offset(x0 + s + 16, y0 + s + 6),
    );
    canvas.save();
    canvas.translate(x0 - 12, y0 + s / 2);
    canvas.rotate(-math.pi / 2);
    _centered(canvas, _text('BMI', 10, FontWeight.w400, _axisLabel), 0, 0);
    canvas.restore();
    _centered(
      canvas,
      _text('Body Fat (%)', 12, FontWeight.w400, _axisLabel),
      x0 + s / 2,
      y0 + s + 24,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(BodyTypePainter old) =>
      old.bodyFatPercent != bodyFatPercent || old.bmi != bmi;
}
