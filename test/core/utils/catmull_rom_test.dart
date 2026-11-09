import 'package:ashrafi_bmi/core/utils/catmull_rom.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('point counts match the prototype', () {
    expect(standHalf.length, 58);
    expect(flexHalf.length, 53);
    expect(mirrorHalf(standHalf).length, 114);
    expect(mirrorHalf(flexHalf).length, 104);
  });

  test('mirrorHalf appends reversed inner points with x = 200 − x', () {
    final m = mirrorHalf(const [
      Offset(100, 0),
      Offset(150, 10),
      Offset(160, 20),
      Offset(100, 30),
    ]);
    expect(m, const [
      Offset(100, 0),
      Offset(150, 10),
      Offset(160, 20),
      Offset(100, 30),
      Offset(40, 20),
      Offset(50, 10),
    ]);
  });

  for (final (name, half) in [('STAND', standHalf), ('FLEX', flexHalf)]) {
    test('$name outline is symmetric about x = 100', () {
      final full = mirrorHalf(half);
      final n = full.length;
      // point k mirrors to point (n − k) mod n
      for (var k = 0; k < n; k++) {
        final a = full[k], b = full[(n - k) % n];
        expect(a.dx + b.dx, closeTo(200, 1e-9));
        expect(a.dy, b.dy);
      }
      final bounds = closedCatmullRom(full).getBounds();
      expect(bounds.left + bounds.right, closeTo(200, 0.01));
    });
  }

  test('spline is closed and passes through every point', () {
    const sq = [Offset(0, 0), Offset(10, 0), Offset(10, 10), Offset(0, 10)];
    final p = closedCatmullRom(sq);
    final metrics = p.computeMetrics().toList();
    expect(metrics, hasLength(1));
    expect(metrics.single.isClosed, isTrue);
    for (final pt in sq) {
      expect(
        p.contains(pt + const Offset(.01, .01) * (pt.dx == 0 ? 1 : -1)),
        isTrue,
      );
    }
    // control points: c1 of segment 0 = p1 + (p2 − p0)/6 = (0,0) + ((10,0) − (0,10))/6
    expect(p.getBounds().top, lessThan(0)); // overshoot from the tangents
  });

  test('STAND bounds stay inside the 200×410 design space', () {
    final b = closedCatmullRom(mirrorHalf(standHalf)).getBounds();
    expect(b.top, closeTo(6, 1.5));
    expect(b.bottom, closeTo(406, 1.5));
    expect(b.right, closeTo(165.5, 1.5));
  });
}
