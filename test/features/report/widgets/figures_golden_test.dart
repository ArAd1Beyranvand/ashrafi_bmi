import 'dart:io';

import 'package:ashrafi_bmi/data/parser/report_parser.dart';
import 'package:ashrafi_bmi/features/report/painters/segmental_figure_painter.dart';
import 'package:ashrafi_bmi/features/report/widgets/standard_figure.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../test_fonts.dart';

void main() {
  final m = ReportParser.parse(
    File('docs/reference/sample_input.b64').readAsBytesSync(),
  ).measurements.last;

  setUpAll(loadMontserrat);

  Widget host(Widget child) => MediaQuery(
    data: const MediaQueryData(disableAnimations: true),
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: RepaintBoundary(
          key: const Key('fig'),
          child: ColoredBox(color: Colors.white, child: child),
        ),
      ),
    ),
  );

  testWidgets('figures golden (animations disabled)', (tester) async {
    tester.view.physicalSize = const Size(600, 300);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      host(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            StandardFigure(waterPercent: m.bodyWaterPercent),
            for (final k in SegmentKind.values)
              SizedBox(
                width: 231,
                height: 166,
                child: CustomPaint(
                  painter: SegmentalFigurePainter(
                    kind: k,
                    values: k == SegmentKind.muscle
                        ? m.segmental.muscle
                        : m.segmental.fat,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
    expect(tester.binding.hasScheduledFrame, isFalse); // no wave ticking
    await expectLater(
      find.byKey(const Key('fig')),
      matchesGoldenFile('../../../goldens/figures.png'),
    );
  });

  testWidgets('water level animates over 600 ms', (tester) async {
    Widget fig(double w) => MaterialApp(home: StandardFigure(waterPercent: w));
    await tester.pumpWidget(fig(40));
    await tester.pumpWidget(fig(60));
    await tester.pump(const Duration(milliseconds: 300));
    final mid = tester.widget<TweenAnimationBuilder<double>>(
      find.byType(TweenAnimationBuilder<double>),
    );
    expect(mid.tween.end, 60);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpWidget(
      const SizedBox(),
    ); // disposes the repeating controller
  });
}
