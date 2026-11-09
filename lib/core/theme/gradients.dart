import 'package:flutter/painting.dart';

LinearGradient _h(List<Color> colors, [List<double>? stops]) => LinearGradient(
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
  colors: colors,
  stops: stops,
);

/// Gradients of the report (left → right, i.e. CSS 90deg).
abstract final class ReportGradients {
  /// "G": header bars.
  static final g = _h(
    const [
      Color(0xFF1C4785),
      Color(0xFF245F8D),
      Color(0xFF2F8E94),
      Color(0xFF45AD9B),
    ],
    const [0, .4, .75, 1],
  );

  /// Ident header cells ID, Gender, Age, Height, Date (Name uses [g]).
  static final identId = _h(const [Color(0xFF20508A), Color(0xFF245A8C)]);
  static final identGender = _h(const [Color(0xFF245A8C), Color(0xFF27698E)]);
  static final identAge = _h(const [Color(0xFF27698E), Color(0xFF2B7A91)]);
  static final identHeight = _h(const [Color(0xFF2B7A91), Color(0xFF348E94)]);
  static final identDate = _h(const [Color(0xFF348E94), Color(0xFF45AD9B)]);

  static final trio1 = _h(const [Color(0xFF1C4785), Color(0xFF245F8D)]);
  static final trio2 = _h(const [Color(0xFF245F8D), Color(0xFF2F8E94)]);
  static final trio3 = _h(const [Color(0xFF2F8E94), Color(0xFF45AD9B)]);

  static final compare = _h(
    const [Color(0xFF1C4785), Color(0xFF2F8E94), Color(0xFF45AD9B)],
    const [0, .6, 1],
  );

  /// Segmental strip, top → bottom.
  static const strip = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFF2D9B0),
      Color(0xFFECD8B6),
      Color(0xFFA9D6CC),
      Color(0xFF94C9C6),
      Color(0xFF5F86C6),
      Color(0xFF4A74BD),
    ],
    stops: [0, .3, .4, .62, .72, 1],
  );
}
