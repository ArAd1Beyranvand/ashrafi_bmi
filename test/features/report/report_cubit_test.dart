import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ashrafi_bmi/data/parser/report_parser.dart';
import 'package:ashrafi_bmi/features/report/cubit/report_cubit.dart';

void main() {
  final data = ReportParser.parse(
    File('assets/sample/sample_report.json').readAsBytesSync(),
  );

  test('defaults to last measurement and select() updates/validates', () {
    final c = ReportCubit(data);
    expect(c.state.selectedIndex, data.measurements.length - 1);
    c.select(0);
    expect(c.state.selectedIndex, 0);
    c.select(999);
    c.select(-1);
    expect(c.state.selectedIndex, 0);
  });
}
