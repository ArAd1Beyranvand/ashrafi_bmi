import 'package:ashrafi_bmi/core/utils/format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fmtNum mirrors JS String(number)', () {
    expect(fmtNum(82.25), '82.25');
    expect(fmtNum(54), '54');
    expect(fmtNum(3.1), '3.1');
    expect(fmtNum(-0.0), '0');
    expect(fmtNum(0.1 + 0.2), '0.3');
  });

  test('round1 rounds half up like Math.round', () {
    expect(round1(1.25), 1.3);
    expect(round1(-0.25), -0.2);
    expect(round1(-0.04), 0);
  });

  test('date formats', () {
    final d = DateTime(2024, 1, 1, 18, 34, 29);
    expect(formatIdentDate(d), '1/1/2024 6:34:29 PM');
    expect(formatShortDate(d), '2024.01.01');
    expect(formatSelectorLabel(d), '2024.01.01 06:34 PM');
    expect(
      formatSelectorLabel(DateTime(2026, 10, 31, 0, 5)),
      '2026.10.31 12:05 AM',
    );
  });
}
