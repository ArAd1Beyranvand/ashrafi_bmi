// Number/date formatting that mirrors the prototype's JavaScript output.

/// JS `String(number)` for the values we show (no forced decimals, no "-0").
String fmtNum(double v) {
  final r = double.parse(v.toStringAsFixed(2));
  if (r == 0) return '0';
  return r == r.truncateToDouble() ? r.toInt().toString() : r.toString();
}

/// JS `Math.round(v * 10) / 10`.
double round1(double v) => (v * 10 + 0.5).floorToDouble() / 10;

String _two(int n) => n.toString().padLeft(2, '0');

int _hour12(DateTime d) => d.hour % 12 == 0 ? 12 : d.hour % 12;

String _ampm(DateTime d) => d.hour < 12 ? 'AM' : 'PM';

/// `10/21/2026 10:37:41 AM`
String formatIdentDate(DateTime d) =>
    '${d.month}/${d.day}/${d.year} ${_hour12(d)}:${_two(d.minute)}:${_two(d.second)} ${_ampm(d)}';

/// `2026.10.21`
String formatShortDate(DateTime d) =>
    '${d.year}.${_two(d.month)}.${_two(d.day)}';

/// `2026.10.21 10:37 AM`
String formatSelectorLabel(DateTime d) =>
    '${formatShortDate(d)} ${_two(_hour12(d))}:${_two(d.minute)} ${_ampm(d)}';
