import 'package:ashrafi_bmi/features/report/painters/analysis_bar_painter.dart';
import 'package:ashrafi_bmi/features/report/widgets/analysis_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../test_fonts.dart';

void main() {
  const t = <double>[0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100];

  group('analysisPos', () {
    test('edges', () {
      expect(analysisPos(t, 0), 0);
      expect(analysisPos(t, 100), 100);
    });
    test('on and between ticks', () {
      expect(analysisPos(t, 10), closeTo(10, 1e-9));
      expect(analysisPos(t, 25), closeTo(25, 1e-9));
    });
    test('non-uniform ticks', () {
      const b = <double>[40, 60, 80, 100, 160, 220, 280, 340, 400, 460, 520];
      expect(analysisPos(b, 130), closeTo(35, 1e-9));
    });
    test('clamps', () {
      expect(analysisPos(t, -5), 0);
      expect(analysisPos(t, 500), 100);
    });
  });

  group('tickText', () {
    test('integers and decimals', () {
      expect(AnalysisBarPainter.tickText(55), '55');
      expect(AnalysisBarPainter.tickText(18.5), '18.5');
    });
  });

  setUpAll(loadMontserrat);

  testWidgets('AnalysisRow golden', (tester) async {
    tester.view.physicalSize = const Size(500, 60);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.white,
          body: Align(
            alignment: Alignment.topLeft,
            child: RepaintBoundary(
              key: const Key('row'),
              child: SizedBox(
                width: 470,
                child: AnalysisRow(
                  name: 'BMI',
                  unit: 'kg/m²',
                  subtitle: 'Body Mass Index',
                  ticks: const [10, 15, 18.5, 21, 25, 30, 35, 40, 45, 50, 55],
                  bands: const [
                    AnalysisBand(2, bandBlue),
                    AnalysisBand(4, bandGreen),
                    AnalysisBand(5, bandBeige),
                    AnalysisBand(10, bandRed, striped: true),
                  ],
                  value: 27.4,
                  label: '27.4',
                  showHeader: true,
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await expectLater(
      find.byKey(const Key('row')),
      matchesGoldenFile('../../../goldens/analysis_row.png'),
    );
  });
}
