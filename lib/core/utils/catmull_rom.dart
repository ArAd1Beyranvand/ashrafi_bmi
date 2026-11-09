import 'dart:ui';

/// Closed Catmull-Rom spline through [pts] as cubic Béziers (prototype `spline()`):
/// `c1 = p1 + (p2 − p0)/6`, `c2 = p2 − (p3 − p1)/6`, indices wrap around.
Path closedCatmullRom(List<Offset> pts) {
  final n = pts.length;
  final path = Path()..moveTo(pts[0].dx, pts[0].dy);
  for (var i = 0; i < n; i++) {
    final p0 = pts[(i - 1 + n) % n];
    final p1 = pts[i];
    final p2 = pts[(i + 1) % n];
    final p3 = pts[(i + 2) % n];
    final c1 = p1 + (p2 - p0) / 6;
    final c2 = p2 - (p3 - p1) / 6;
    path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, p2.dx, p2.dy);
  }
  return path..close();
}

/// Prototype `mirror()`: `half + reversed(half[1..n−2])` with `x' = 200 − x`.
List<Offset> mirrorHalf(List<Offset> half) => [
  ...half,
  for (final p in half.sublist(1, half.length - 1).reversed)
    Offset(200 - p.dx, p.dy),
];

List<Offset> _pts(List<List<num>> l) => [
  for (final p in l) Offset(p[0].toDouble(), p[1].toDouble()),
];

/// Standing, arms down (Standard + fat figures). Copied verbatim from the prototype, 200×410 space.
final standHalf = _pts(const [
  [100, 6], [110, 8], [116, 16], [118, 28], [116, 42], [112, 52], [110, 60], //
  [111, 66], [122, 71], [136, 75], [147, 81], [152, 92], [154, 106],
  [155, 122], [156, 140], [157, 158], [158, 176], [160, 194], [161, 210],
  [163, 222], [165, 232], [163, 241], [159, 246], [154, 243], [152, 233],
  [151, 220], [149, 204], [146, 186], [144, 168], [142, 150], [140, 132],
  [137, 116], [135, 132], [133, 150], [131, 168], [133, 186], [136, 204],
  [139, 222], [140, 244], [138, 266], [134, 288], [131, 306], [133, 326],
  [131, 348], [127, 368], [123, 386], [124, 398], [121, 405], [110, 406],
  [106, 401], [106, 388], [105, 366], [104, 344], [104, 322], [103, 300],
  [103, 276], [102, 254], [100, 240],
]);

/// Double-biceps pose (muscle figure). Copied verbatim from the prototype, 200×410 space.
final flexHalf = _pts(const [
  [100, 6], [110, 8], [116, 16], [118, 28], [116, 42], [112, 52], [110, 60], //
  [111, 66], [124, 70], [138, 72], [150, 74], [162, 72], [170, 66], [170, 56],
  [167, 46], [166, 36], [171, 27], [180, 25], [189, 31], [192, 42], [192, 56],
  [190, 72], [187, 88], [180, 98], [168, 102], [154, 106], [140, 114],
  [136, 132], [133, 150], [131, 168], [133, 186], [136, 204], [139, 222],
  [140, 244], [138, 266], [134, 288], [131, 306], [133, 326], [131, 348],
  [127, 368], [123, 386], [124, 398], [121, 405], [110, 406], [106, 401],
  [106, 388], [105, 366], [104, 344], [104, 322], [103, 300], [103, 276],
  [102, 254], [100, 240],
]);
