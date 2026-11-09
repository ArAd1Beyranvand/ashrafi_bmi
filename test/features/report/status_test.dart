import 'package:ashrafi_bmi/features/report/domain/status.dart';
import 'package:ashrafi_bmi/features/report/report_math.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('standards derive from height', () {
    expect(stdWeight(179), closeTo(70.4902, 1e-3));
    expect(stdSmm(179), closeTo(0.45 * 70.4902, 1e-3));
    expect(stdBfm(179), closeTo(0.18 * 70.4902, 1e-3));
  });

  test('weight 85–115 % of standard', () {
    final (lo, hi) = weightRange(179);
    expect(lo, closeTo(59.91, 0.01));
    expect(hi, closeTo(81.06, 0.01));
    expect(weightLevel(59.8, 179), Level.low);
    expect(weightLevel(59.92, 179), Level.normal);
    expect(weightLevel(72.6, 179), Level.normal);
    expect(weightLevel(81.2, 179), Level.high);
  });

  test('SMM 90–110 % of 0.45 stdW', () {
    final (lo, hi) = smmRange(179);
    expect(lo, closeTo(0.9 * 0.45 * 70.4902, 1e-2));
    expect(hi, closeTo(1.1 * 0.45 * 70.4902, 1e-2));
    expect(smmLevel(27, 179), Level.low);
    expect(smmLevel(31.7, 179), Level.normal);
    expect(smmLevel(35, 179), Level.high);
  });

  test('BFM 80–160 % of 0.18 stdW', () {
    expect(bfmLevel(9, 179), Level.low); // < 10.15
    expect(bfmLevel(15.4, 179), Level.normal);
    expect(bfmLevel(21, 179), Level.high); // > 20.30
  });

  test('PBF 10–25 inclusive', () {
    expect(pbfLevel(9.9), Level.low);
    expect(pbfLevel(10), Level.normal);
    expect(pbfLevel(25), Level.normal);
    expect(pbfLevel(25.1), Level.high);
  });

  test('segment grades (provisional Q5)', () {
    expect(segmentLevel(1), Level.low);
    expect(segmentLevel(2), Level.normal);
    expect(segmentLevel(3), Level.high);
    expect(segmentLevel(0), isNull);
  });

  test('visceralPos is piecewise linear through the anchors', () {
    expect(visceralPos(0), 2);
    expect(visceralPos(1), 2);
    expect(visceralPos(10), 44);
    expect(visceralPos(30), 70);
    expect(visceralPos(50), 96);
    expect(visceralPos(99), 96);
  });
}
