/// Standard weight `22·h²` (h in metres) and the standards derived from it.
double stdWeight(double heightCm) => 22 * (heightCm / 100) * (heightCm / 100);
double stdSmm(double heightCm) => 0.45 * stdWeight(heightCm);
double stdBfm(double heightCm) => 0.18 * stdWeight(heightCm);

/// Visceral-fat marker position in % of the bar: piecewise linear through the label anchors
/// 1 → 2 %, 10 → 44 %, 50 → 96 %, clamped.
double visceralPos(double level) {
  if (level <= 1) return 2;
  if (level >= 50) return 96;
  if (level <= 10) return 2 + (level - 1) / 9 * 42;
  return 44 + (level - 10) / 40 * 52;
}
