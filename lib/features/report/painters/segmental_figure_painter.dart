import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../../../core/theme/report_text.dart';
import '../../../core/utils/format.dart';
import '../../../data/models/segmental.dart';
import 'body_path.dart';

enum SegmentKind { muscle, fat }

/// Segmental figure (prototype `segfig()`), viewBox `−115 0 430 410`, `xMidYMid meet`.
class SegmentalFigurePainter extends CustomPainter {
  const SegmentalFigurePainter({required this.kind, required this.values});

  final SegmentKind kind;
  final SegmentalValues values;

  static const viewBox = Rect.fromLTWH(-115, 0, 430, 410);

  static const _labels = <(double, double, String)>[
    (230, 40, 'Trunk'),
    (-110, 140, 'Right Arm'),
    (230, 140, 'Left Arm'),
    (-110, 288, 'Right Leg'),
    (230, 288, 'Left Leg'),
  ];

  List<Offset> get _dots => kind == SegmentKind.muscle
      ? const [
          Offset(100, 104),
          Offset(22, 84),
          Offset(178, 84),
          Offset(90, 300),
          Offset(110, 300),
        ]
      : const [
          Offset(100, 96),
          Offset(44, 170),
          Offset(156, 170),
          Offset(90, 300),
          Offset(110, 300),
        ];

  List<double> get _values => [
    values.trunk,
    values.rightArm,
    values.leftArm,
    values.rightLeg,
    values.leftLeg,
  ];

  /// Figure-space → widget transform (uniform scale, centred).
  static (double, Offset) fit(Size size) {
    final s = math.min(
      size.width / viewBox.width,
      size.height / viewBox.height,
    );
    return (
      s,
      Offset(
        (size.width - viewBox.width * s) / 2 - viewBox.left * s,
        (size.height - viewBox.height * s) / 2 - viewBox.top * s,
      ),
    );
  }

  /// Prototype leader: `M x y C mx y, mx ly+8, ex ly+8 H end`.
  static Path leader(Offset dot, double lx, double ly) {
    final r = lx > 100, ex = r ? lx - 8 : lx + 86, mx = (dot.dx + ex) / 2;
    return Path()
      ..moveTo(dot.dx, dot.dy)
      ..cubicTo(mx, dot.dy, mx, ly + 8, ex, ly + 8)
      ..lineTo(r ? lx + 80 : lx + 6, ly + 8);
  }

  /// SVG `<text>`: [y] is the alphabetic baseline.
  static void _text(Canvas c, String s, double x, double y, TextStyle st) {
    final tp = TextPainter(
      text: TextSpan(text: s, style: st),
      textDirection: TextDirection.ltr,
    )..layout();
    final base = tp.computeDistanceToActualBaseline(TextBaseline.alphabetic);
    tp.paint(c, Offset(x, y - base));
  }

  static TextStyle _style(double size, FontWeight w, Color c) => TextStyle(
    fontFamily: 'Montserrat',
    fontSize: size,
    fontWeight: w,
    color: c,
    height: ReportText.normalLineHeight,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final m = kind == SegmentKind.muscle;
    final (s, o) = fit(size);
    canvas.save();
    canvas.translate(o.dx, o.dy);
    canvas.scale(s);

    final body = bodyPath(m ? BodyPose.flex : BodyPose.standing);
    canvas.drawPath(
      body,
      Paint()
        ..color = (m ? const Color(0xFFF5D6A2) : const Color(0xFFD6E1F1))
            .withValues(alpha: .55)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    // objectBoundingBox radial gradient (cx .5, cy .4, r .7): unit square mapped onto the bbox.
    final b = body.getBounds();
    canvas.drawPath(
      body,
      Paint()
        ..shader = ui.Gradient.radial(
          const Offset(.5, .4),
          .7,
          m
              ? const [Color(0xFFF7D9A6), Color(0xFFF1C98D)]
              : const [Color(0xFFDAE4F2), Color(0xFFC9D7EC)],
          null,
          TileMode.clamp,
          (Matrix4.translationValues(
            b.left,
            b.top,
            0,
          )..scaleByDouble(b.width, b.height, 1, 1)).storage,
        ),
    );

    const legend = [
      (Color(0xFFF2D9B0), 'High'),
      (Color(0xFFA9D6CC), 'Normal'),
      (Color(0xFF5F86C6), 'Low'),
    ];
    final legendStyle = _style(10, FontWeight.w400, const Color(0xFF4A555B));
    for (var i = 0; i < legend.length; i++) {
      canvas.drawRect(
        Rect.fromLTWH(-112, 4 + i * 20.0, 16, 18),
        Paint()..color = legend[i].$1,
      );
      _text(canvas, legend[i].$2, -90, 17 + i * 20.0, legendStyle);
    }

    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..color = const Color(0xFF3D464C);
    final dot = Paint()..color = const Color(0xFF2D353A);
    final name = _style(11, FontWeight.w400, const Color(0xFF4A555B));
    final value = _style(17, FontWeight.w600, const Color(0xFF2F393F));
    final dots = _dots, vals = _values;
    for (var i = 0; i < 5; i++) {
      final (lx, ly, n) = _labels[i];
      final tx = lx + (lx > 100 ? 0 : 6);
      canvas.drawPath(leader(dots[i], lx, ly), line);
      canvas.drawCircle(dots[i], 4.2, dot);
      _text(canvas, n, tx, ly - 18, name);
      _text(canvas, '${fmtNum(vals[i])}kg', tx, ly + 2, value);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(SegmentalFigurePainter old) =>
      old.kind != kind || old.values != values;
}
