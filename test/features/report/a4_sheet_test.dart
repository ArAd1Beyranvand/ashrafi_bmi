import 'dart:io';

import 'package:ashrafi_bmi/core/utils/format.dart';
import 'package:ashrafi_bmi/data/parser/report_parser.dart';
import 'package:ashrafi_bmi/features/report/cubit/report_cubit.dart';
import 'package:ashrafi_bmi/features/report/view/a4_sheet.dart';
import 'package:ashrafi_bmi/features/report/view/report_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_fonts.dart';

void main() {
  final history = ReportParser.parse(
    File('assets/sample/sample_history.b64').readAsBytesSync(),
  );

  setUpAll(loadMontserrat);

  testWidgets('A4Sheet golden (history sample, newest)', (tester) async {
    tester.view.physicalSize = const Size(840, 1170);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: 'Montserrat'),
        home: Scaffold(
          backgroundColor: const Color(0xFFDFE4E7),
          body: Center(
            child: RepaintBoundary(
              key: const Key('sheet'),
              child: A4Sheet(
                state: ReportState(history, history.measurements.length - 1),
              ),
            ),
          ),
        ),
      ),
    );
    await expectLater(
      find.byKey(const Key('sheet')),
      matchesGoldenFile('../../goldens/a4_sheet.png'),
    );
  });

  testWidgets('switching measurement updates the sheet', (tester) async {
    tester.view.physicalSize = const Size(1000, 1300);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await tester.pumpWidget(MaterialApp(home: ReportPage(data: history)));
    final last = history.measurements.last;
    expect(find.text('${last.bmr.round()}kcal'), findsWidgets);
    await tester.tap(find.byKey(const Key('measurementSelector')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.text(formatSelectorLabel(history.measurements.first.timestamp)).last,
    );
    await tester.pumpAndSettle();
    final first = history.measurements.first;
    expect(find.text('${first.bmr.round()}kcal'), findsWidgets);
    expect(find.text('${last.bmr.round()}kcal'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
