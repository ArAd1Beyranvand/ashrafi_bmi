import 'package:flutter/painting.dart';

import 'report_colors.dart';

/// Text styles of the report (Montserrat bundled in assets/fonts, tabular figures).
abstract final class ReportText {
  /// CSS `line-height: normal` of Montserrat (hhea 968 + 251 per 1000). Flutter on Linux picks the
  /// larger win metrics instead, so every style pins the Chrome value.
  static const normalLineHeight = 1.219;

  static const _w4 = FontWeight.w400;
  static const _w5 = FontWeight.w500;
  static const _w6 = FontWeight.w600;
  static const _w7 = FontWeight.w700;
  static const _w8 = FontWeight.w800;

  static TextStyle _s(
    double size,
    FontWeight weight,
    Color color, {
    double? height,
    double? letterSpacing,
    bool italic = false,
  }) => TextStyle(
    fontFamily: 'Montserrat',
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height ?? normalLineHeight,
    letterSpacing: letterSpacing,
    fontStyle: italic ? FontStyle.italic : FontStyle.normal,
    fontFeatures: const [FontFeature.tabularFigures()],
    leadingDistribution: TextLeadingDistribution.even,
  );

  static const white = Color(0xFFFFFFFF);

  static final toolbar = _s(13, _w6, ReportColors.uiInk);
  static final logo = _s(
    33,
    _w5,
    ReportColors.logo,
    height: 1,
    letterSpacing: .5,
  );
  static final logoSup = _s(9, _w5, ReportColors.logo, height: 1);
  static final model = _s(13, _w6, ReportColors.model);
  static final identHead = _s(12.5, _w7, white);
  static final identValue = _s(11.5, _w5, ReportColors.identValue);
  static final title = _s(13.5, _w8, white, letterSpacing: .1);
  static final titleSmall = _s(10.5, _w8, white, letterSpacing: .1);
  static final cellLabel = _s(12.5, _w7, ReportColors.cellLabel);
  static final cellSub = _s(9.5, _w4, ReportColors.cellSub, italic: true);
  static final cellValue = _s(11.5, _w6, ReportColors.text);
  static final segTitle = _s(12.5, _w8, white);
  static final stripLabel = _s(7.4, _w4, ReportColors.segLabel);
  static final changeCell = _s(12, _w4, ReportColors.ink);
  static final changeKey = _s(15, _w5, ReportColors.rowName, height: 1);
  static final changeSup = _s(6, _w4, ReportColors.rowName, height: 1);
  static final changeSub = _s(5.5, _w4, ReportColors.rowSub, height: 1);
  static final changeDate = _s(8, _w6, ReportColors.dateRowText);
  static final ishTitle = _s(12, _w5, ReportColors.text);
  static final matrixLabel = _s(10.5, _w4, ReportColors.text);
  static final matrixSymbol = _s(9, _w4, ReportColors.symbol);
  static final legend = _s(7, _w4, ReportColors.legendText);
  static final legendSymbol = _s(7, _w4, ReportColors.symbol);
  static final visceralLabel = _s(9, _w7, ReportColors.ink);
  static final visceralNumber = _s(22, _w6, ReportColors.visceralNumber);
  static final visceralUnit = _s(9, _w6, ReportColors.visceralNumber);
  static final trioHead = _s(9.5, _w8, white);
  static final trioValue = _s(12, _w4, ReportColors.text);
  static final cmpHead = _s(7.5, _w8, white);
  static final cmpRowHead = _s(6.3, _w8, white, height: 1.1);
  static final cmpCell = _s(12, _w4, ReportColors.text);
  static final placeholder = _s(8, _w5, ReportColors.rowSub);
}
