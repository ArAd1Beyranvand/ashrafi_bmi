import 'dart:io';

import 'package:ashrafi_bmi/data/parser/report_parser.dart';
import 'package:ashrafi_bmi/features/report/view/a4_sheet.dart';
import 'package:ashrafi_bmi/features/report/view/report_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_fonts.dart';

void main() {
  setUpAll(loadMontserrat);
  _desktop();

  for (final name in ['sample_report.json', 'sample_history.b64']) {
    testWidgets('phone 390x844 shows the whole sheet, zoom works ($name)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final data = ReportParser.parse(
        File('assets/sample/$name').readAsBytesSync(),
      );
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(390, 844),
            disableAnimations: true,
          ),
          child: MaterialApp(
            theme: ThemeData(fontFamily: 'Montserrat'),
            home: ReportPage(data: data),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull); // no overflow / layout errors

      final rect = tester.getRect(find.byType(A4Sheet));
      expect(rect.left, greaterThanOrEqualTo(0));
      expect(rect.right, lessThanOrEqualTo(390));
      expect(rect.bottom, lessThanOrEqualTo(844));
      expect(rect.width / rect.height, closeTo(794 / 1123, .01));

      // Pinch out: the sheet grows.
      final c = tester.getCenter(find.byType(A4Sheet));
      final g1 = await tester.startGesture(c - const Offset(20, 0));
      final g2 = await tester.startGesture(c + const Offset(20, 0));
      await g1.moveBy(const Offset(-60, 0));
      await g2.moveBy(const Offset(60, 0));
      await g1.up();
      await g2.up();
      await tester.pumpAndSettle();
      expect(
        tester.getRect(find.byType(A4Sheet)).width,
        greaterThan(rect.width * 1.5),
      );
      expect(tester.takeException(), isNull);
    });
  }
}

void _desktop() {
  testWidgets('desktop zoom buttons zoom and reset', (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final data = ReportParser.parse(
      File('assets/sample/sample_report.json').readAsBytesSync(),
    );
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: Size(1200, 900),
          disableAnimations: true,
        ),
        child: MaterialApp(home: ReportPage(data: data)),
      ),
    );
    final w0 = tester.getRect(find.byType(A4Sheet)).width;
    await tester.tap(find.byTooltip('Zoom in'));
    await tester.pump();
    await tester.tap(find.byTooltip('Zoom in'));
    await tester.pump();
    expect(tester.getRect(find.byType(A4Sheet)).width, greaterThan(w0 * 1.4));
    await tester.tap(find.byTooltip('Reset zoom'));
    await tester.pump();
    expect(tester.getRect(find.byType(A4Sheet)).width, closeTo(w0, .5));
  });
}
