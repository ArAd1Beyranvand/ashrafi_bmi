import 'package:ashrafi_bmi/features/report/painters/body_type_painter.dart';
import 'package:ashrafi_bmi/features/report/widgets/body_type_trend.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_fonts.dart';

void main() {
  setUpAll(loadMontserrat);

  test('Standard cell for 21.2 % / BMI 22.6', () {
    final p = BodyTypePainter.position(21.2, 22.6);
    // fat: 1 + 11.2/15 ; bmi: 1 + 4.1/6.5 cells.
    expect(p.dx, closeTo(26 + (1 + 11.2 / 15) * 76, 1e-9));
    expect(p.dy, closeTo(24 + 228 - (1 + 4.1 / 6.5) * 76, 1e-9));
    expect(p.dx, inInclusiveRange(26 + 76, 26 + 152));
    expect(p.dy, inInclusiveRange(24 + 76, 24 + 152));
  });

  test('band edges and clamping', () {
    expect(BodyTypePainter.band(10, 10, 25, 0, 40), 1);
    expect(BodyTypePainter.band(25, 10, 25, 0, 40), 2);
    expect(BodyTypePainter.band(40, 10, 25, 0, 40), 3);
    final lo = BodyTypePainter.position(0, 5);
    expect(lo.dx, closeTo(26 + .15 * 76, 1e-9));
    expect(lo.dy, closeTo(24 + 228 - .15 * 76, 1e-9));
    final hi = BodyTypePainter.position(60, 50);
    expect(hi.dx, closeTo(26 + 2.85 * 76, 1e-9));
    expect(hi.dy, closeTo(24 + 228 - 2.85 * 76, 1e-9));
  });

  testWidgets('BodyTypeTrend golden', (tester) async {
    tester.view.physicalSize = const Size(300, 330);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: SizedBox(
              width: 259,
              child: RepaintBoundary(
                key: Key('chart'),
                child: BodyTypeTrend(bodyFatPercent: 21.2, bmi: 22.6),
              ),
            ),
          ),
        ),
      ),
    );
    await expectLater(
      find.byKey(const Key('chart')),
      matchesGoldenFile('../../goldens/body_type_trend.png'),
    );
  });
}
