import 'package:ashrafi_bmi/features/report/painters/body_path.dart';
import 'package:ashrafi_bmi/features/report/painters/liquid_painter.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('BodyClipper scales the figure-space path to the widget size', () {
    final raw = bodyPath(BodyPose.standing).getBounds();
    const size = Size(115.1, 236);
    final b = const BodyClipper(BodyPose.standing).getClip(size).getBounds();
    final sx = size.width / 200, sy = size.height / 410;
    expect(b.left, closeTo(raw.left * sx, 1e-3));
    expect(b.right, closeTo(raw.right * sx, 1e-3));
    expect(b.top, closeTo(raw.top * sy, 1e-3));
    expect(b.bottom, closeTo(raw.bottom * sy, 1e-3));
  });

  test('BodyClipper reclips only on pose change', () {
    const a = BodyClipper(BodyPose.standing);
    expect(a.shouldReclip(const BodyClipper(BodyPose.standing)), isFalse);
    expect(a.shouldReclip(const BodyClipper(BodyPose.flex)), isTrue);
  });

  test('liquid level formula', () {
    expect(LiquidPainter.topFor(0), 406);
    expect(LiquidPainter.topFor(100), 6);
    expect(LiquidPainter.topFor(55), closeTo(186, 1e-9));
  });

  test('flat wave when A = 0', () {
    final b = LiquidPainter.wavePath(100, 0, 0, .3).getBounds();
    expect(b, const Rect.fromLTRB(0, 100, 200, 420));
  });

  test('wave loop is seamless (v = 0 and v = 1 give the same shape)', () {
    final a = LiquidPainter.wavePath(100, 4, 0, 0).getBounds();
    final b = LiquidPainter.wavePath(100, 4, 0, 1).getBounds();
    expect(b.top, closeTo(a.top, 1e-9));
  });

  test('LiquidPainter.shouldRepaint', () {
    final anim = AnimationController(vsync: const TestVSync());
    addTearDown(anim.dispose);
    LiquidPainter p(double w, {bool still = false, Animation<double>? a}) =>
        LiquidPainter(animation: a ?? anim, waterPercent: w, still: still);
    expect(p(50).shouldRepaint(p(50)), isFalse);
    expect(p(50).shouldRepaint(p(51)), isTrue);
    expect(p(50).shouldRepaint(p(50, still: true)), isTrue);
    expect(p(50).shouldRepaint(p(50, a: kAlwaysCompleteAnimation)), isTrue);
  });
}
