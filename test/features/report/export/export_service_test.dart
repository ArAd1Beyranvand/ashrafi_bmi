import 'dart:convert';

import 'package:ashrafi_bmi/features/report/export/export_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final png = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
  );
  late List<(String, int, String)> saved;
  late int captures;

  ExportService make({bool accept = true}) {
    saved = [];
    captures = 0;
    return ExportService(
      capture: () async {
        captures++;
        return png;
      },
      saver: (name, bytes, mime) async {
        saved.add((name, bytes.length, mime));
        return accept ? '/tmp/$name' : null;
      },
    );
  }

  test('savePng saves the captured bytes unchanged', () async {
    final s = make();
    expect(await s.savePng('r'), '/tmp/r.png');
    expect(saved.single, ('r.png', png.length, 'image/png'));
    expect(captures, 1);
  });

  test('savePdf builds a one-page A4 PDF', () async {
    final s = make();
    expect(await s.savePdf('r'), '/tmp/r.pdf');
    final (name, _, mime) = saved.single;
    expect(name, 'r.pdf');
    expect(mime, 'application/pdf');
    final pdf = String.fromCharCodes(await s.pdfBytes());
    expect(pdf.startsWith('%PDF'), isTrue);
    expect(RegExp(r'/Type\s*/Page\b').allMatches(pdf).length, 1);
    expect(pdf, contains('595.27')); // A4 width in pt
  });

  test('cancelled save returns false', () async {
    expect(await make(accept: false).savePng('r'), isNull);
  });
}
