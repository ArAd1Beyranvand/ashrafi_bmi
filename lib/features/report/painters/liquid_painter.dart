import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'body_path.dart';

/// Loop length of the wave controller. 8.4 s makes both prototype terms close a whole number of
/// cycles (1.5·8.4 ≈ 2·2π, 2.2·8.4 ≈ 3·2π), so the loop is seamless at ~the prototype speed.
const liquidLoop = Duration(milliseconds: 8400);

/// Water in the Standard figure (prototype `tick()`), drawn in 200×410 figure space:
/// `y(x) = top + A·sin(0.05x + w1 + φ) + 0.4A·sin(0.13x − w2 + 1.6φ)` with `w1 = 2π·2·v`,
/// `w2 = 2π·3·v` (v = controller value), `top = 406 − water/100·400`.
class LiquidPainter extends CustomPainter {
  LiquidPainter({
    required this.animation,
    required this.waterPercent,
    required this.still,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final double waterPercent;

  /// Reduced motion: A = 0, t = 0.
  final bool still;

  static double topFor(double water) => 406 - water / 100 * 400;

  static Path wavePath(double top, double amp, double ph, double v) {
    final w1 = 2 * math.pi * 2 * v, w2 = 2 * math.pi * 3 * v;
    final p = Path()..moveTo(0, top);
    for (var x = 0.0; x <= 200; x += 5) {
      p.lineTo(
        x,
        top +
            amp * math.sin(.05 * x + w1 + ph) +
            .4 * amp * math.sin(.13 * x - w2 + 1.6 * ph),
      );
    }
    return p
      ..lineTo(200, 420)
      ..lineTo(0, 420)
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final v = still ? 0.0 : animation.value;
    final k = still ? 0.0 : 1.0;
    final top = topFor(waterPercent);
    canvas.save();
    canvas.scale(
      size.width / figureSize.width,
      size.height / figureSize.height,
    );
    const c1 = Color(0xFF5CC0AA);
    canvas.drawPath(
      wavePath(top, 4 * k, 0, v),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [c1.withValues(alpha: .22), c1.withValues(alpha: .45)],
        ).createShader(Rect.fromLTRB(0, top, 200, 410)),
    );
    canvas.drawPath(
      wavePath(top + 2, 3 * k, 2, v),
      Paint()..color = const Color(0xFF7FD0BB).withValues(alpha: .15),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(LiquidPainter old) =>
      old.waterPercent != waterPercent ||
      old.still != still ||
      old.animation != animation;
}
