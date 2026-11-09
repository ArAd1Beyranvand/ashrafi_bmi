import '../report_math.dart';

enum Level { low, normal, high }

/// [v] below [lo] → low, above [hi] → high, otherwise normal (both bounds inclusive).
Level levelOf(double v, double lo, double hi) =>
    v < lo ? Level.low : (v > hi ? Level.high : Level.normal);

/// Normal weight: 85–115 % of the standard weight.
(double, double) weightRange(double heightCm) =>
    (0.85 * stdWeight(heightCm), 1.15 * stdWeight(heightCm));

/// Normal SMM: 90–110 % of the standard SMM.
(double, double) smmRange(double heightCm) =>
    (0.9 * stdSmm(heightCm), 1.1 * stdSmm(heightCm));

/// Normal BFM: 80–160 % of the standard BFM.
(double, double) bfmRange(double heightCm) =>
    (0.8 * stdBfm(heightCm), 1.6 * stdBfm(heightCm));

/// Normal PBF: 10–25 %.
const pbfRange = (10.0, 25.0);

Level weightLevel(double weightKg, double heightCm) {
  final (lo, hi) = weightRange(heightCm);
  return levelOf(weightKg, lo, hi);
}

Level smmLevel(double smmKg, double heightCm) {
  final (lo, hi) = smmRange(heightCm);
  return levelOf(smmKg, lo, hi);
}

Level bfmLevel(double bfmKg, double heightCm) {
  final (lo, hi) = bfmRange(heightCm);
  return levelOf(bfmKg, lo, hi);
}

Level pbfLevel(double percent) => levelOf(percent, pbfRange.$1, pbfRange.$2);

/// Device grade of a segment → Low/Normal/High (OPEN_QUESTIONS Q5, provisional: 1/2/3).
Level? segmentLevel(double grade) => switch (grade.round()) {
  1 => Level.low,
  2 => Level.normal,
  3 => Level.high,
  _ => null,
};
