import 'dart:ui';

/// Every colour of the A4 report, copied from docs/reference/prototype.html.
abstract final class ReportColors {
  /// Thickness of the prototype's `1.6px` rules: Chrome renders them as 1 px at 1x, which is what
  /// the pixel comparison is made against.
  static const rule = 1.0;

  static const canvas = Color(0xFFDFE4E7);
  static const ink = Color(0xFF2E3B44);
  static const uiInk = Color(0xFF33434C);
  static const uiLine = Color(0xFFC7D1D6);

  static const sheetBorder = Color(0xFF5C656B);
  static const logo = Color(0xFF8D2525);
  static const model = Color(0xFF37444C);

  static const identValueBg = Color(0xFFECECEC);
  static const identValue = Color(0xFF3A454C);
  static const text = Color(0xFF3A454C);

  static const cellBg = Color(0xFFE3E3E3);
  static const cellLabel = Color(0xFF38444B);
  static const cellSub = Color(0xFF8A9399);

  static const rowName = Color(0xFF3D474E);
  static const rowSub = Color(0xFF9AA3A8);
  static const rowLine = Color(0xFF4C565C);
  static const dashed = Color(0xFFB9C0C4);
  static const dateRowBg = Color(0xFFDCDCDC);
  static const dateRowText = Color(0xFF4A555B);

  static const ishVLine = Color(0xFF9CA5AA);
  static const ishTitleLine = Color(0xFF6F7A80);
  static const symbol = Color(0xFF9AA3A8);
  static const legendText = Color(0xFF8A949A);
  static const matrixLow = Color(0xFFB8C6E6);
  static const matrixNormal = Color(0xFFA9D5C8);
  static const matrixHigh = Color(0xFFF3D7B3);
  static const dot = Color(0xFF1D2327);

  static const visceralLow = Color(0xFFA8D3D4);
  static const visceralHigh = Color(0xFFF4D4A9);
  static const visceralMarker = Color(0xFF262C30);
  static const visceralNumber = Color(0xFF323D44);

  static const compareLine = Color(0xFF6D777C);

  static const segLabel = Color(0xFF4E5A61);
  static const stripMarker = Color(0xFF3A444A);

  static const placeholder = Color(0xFFEEF2F4);
}
