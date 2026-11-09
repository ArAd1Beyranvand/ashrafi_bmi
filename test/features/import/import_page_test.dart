import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ashrafi_bmi/app.dart';
import 'package:ashrafi_bmi/features/report/view/report_page.dart';

import '../../test_fonts.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(loadMontserrat);

  setUp(() {
    final sample = File('assets/sample/sample_report.json').readAsBytesSync();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (message) async {
          final key = const StringCodec().decodeMessage(message)!;
          if (key == 'assets/sample/sample_report.json') {
            return ByteData.sublistView(Uint8List.fromList(sample));
          }
          return null;
        });
  });

  testWidgets('idle render', (tester) async {
    tester.view.physicalSize = const Size(1000, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await tester.pumpWidget(const App());
    expect(find.text('Open a report file'), findsOneWidget);
    expect(find.text('Drag & drop a file here'), findsOneWidget);
    expect(find.text('Choose file'), findsOneWidget);
    expect(find.text('Load sample'), findsOneWidget);
  });

  testWidgets('sample load navigates to ReportPage', (tester) async {
    tester.view.physicalSize = const Size(1000, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await tester.pumpWidget(const App());
    await tester.tap(find.text('Load sample'));
    await tester.pumpAndSettle();
    expect(find.byType(ReportPage), findsOneWidget);
    expect(find.text('CHARDER EGYPT'), findsOneWidget);
    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    expect(find.text('Open a report file'), findsOneWidget);
  });
}
