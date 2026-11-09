import 'package:flutter/material.dart';

import '../../../core/theme/report_colors.dart';
import '../../../core/theme/report_text.dart';
import 'common.dart';

/// Body Composition Change grid: key column + 7 history columns, then the Test Date row.
class ChangeTable extends StatelessWidget {
  const ChangeTable({super.key, required this.rows, required this.dates});

  /// (name, unit, sub, 7 cell strings — empty when there is no measurement)
  final List<(String, String, String, List<String>)> rows;

  /// 7 date strings (empty when no measurement).
  final List<String> dates;

  // 470 - 1 (left border) = 469; columns 92 | 72 | 6 x 1fr (grid quirk of the prototype).
  static const _firstW = 92.0;
  static const _secondW = 72.0;

  /// Width of every cell: horizontal padding 6 + 6 and the 1 px dashed border.
  static const _cellExtra = 13.0;

  /// CSS grid track sizing for `92px 72px repeat(6, 1fr)`: a 1fr track never gets narrower than
  /// its min-content, so wide columns are frozen at their content width and the others share
  /// the rest. [contentWidths] = widest text of each of the 8 columns (0 for fixed/empty ones).
  static List<double> columnWidths(
    List<double> contentWidths, {
    double total = 469,
  }) {
    final widths = List<double>.filled(8, 0)
      ..[0] = _firstW
      ..[1] = _secondW;
    final frozen = <int>{};
    var fr = 0.0;
    while (true) {
      final free =
          total -
          _firstW -
          _secondW -
          frozen.fold<double>(0, (a, i) => a + widths[i]);
      fr = free / (6 - frozen.length);
      final over = [
        for (var i = 2; i < 8; i++)
          if (!frozen.contains(i) && contentWidths[i] + _cellExtra > fr) i,
      ];
      if (over.isEmpty) break;
      for (final i in over) {
        frozen.add(i);
        widths[i] = contentWidths[i] + _cellExtra;
      }
    }
    for (var i = 2; i < 8; i++) {
      if (!frozen.contains(i)) widths[i] = fr;
    }
    return widths;
  }

  static double _textWidth(String text, TextStyle style) {
    if (text.isEmpty) return 0;
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    return tp.width;
  }

  List<double> _widths() {
    final content = List<double>.filled(8, 0);
    for (var c = 2; c < 8; c++) {
      var w = 0.0;
      for (final r in rows) {
        w = w > _textWidth(r.$4[c - 1], ReportText.changeCell)
            ? w
            : _textWidth(r.$4[c - 1], ReportText.changeCell);
      }
      final d = _textWidth(dates[c - 1], ReportText.changeDate);
      content[c] = w > d ? w : d;
    }
    return columnWidths(content);
  }

  static const _dash = ReportColors.dashed;

  Widget _cell(
    List<double> ws,
    int col,
    Widget child, {
    double height = 27,
    Color? bg,
    bool bottom = true,
    Alignment align = Alignment.centerLeft,
  }) => SizedBox(
    width: ws[col],
    height: height,
    child: CustomPaint(
      foregroundPainter: const DashedRightBorder(_dash),
      child: Container(
        alignment: align,
        padding: const EdgeInsets.only(left: 6, right: 7),
        decoration: BoxDecoration(
          color: bg,
          border: bottom
              ? const Border(
                  bottom: BorderSide(
                    color: ReportColors.rowLine,
                    width: ReportColors.rule,
                  ),
                )
              : null,
        ),
        child: child,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final ws = _widths();
    return Container(
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: ReportColors.cellBg)),
      ),
      child: Column(
        children: [
          for (final r in rows)
            Row(
              children: [
                _cell(
                  ws,
                  0,
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(r.$1, style: ReportText.changeKey),
                          Text(' ${r.$2}', style: ReportText.changeSup),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(r.$3, style: ReportText.changeSub),
                    ],
                  ),
                ),
                for (var i = 0; i < 7; i++)
                  _cell(
                    ws,
                    i + 1,
                    Text(
                      r.$4[i],
                      softWrap: false,
                      style: ReportText.changeCell,
                    ),
                  ),
              ],
            ),
          Row(
            children: [
              _cell(
                ws,
                0,
                Text('Test Date', style: ReportText.changeDate),
                height: 30,
                bg: ReportColors.dateRowBg,
                bottom: false,
              ),
              for (var i = 0; i < 7; i++)
                _cell(
                  ws,
                  i + 1,
                  Text(
                    dates[i],
                    softWrap: false,
                    overflow: TextOverflow.visible,
                    style: ReportText.changeDate,
                  ),
                  height: 30,
                  bg: ReportColors.dateRowBg,
                  bottom: false,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
