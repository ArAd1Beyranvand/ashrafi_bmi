import 'package:flutter/material.dart';

import '../../../core/theme/report_colors.dart';
import '../../../core/theme/report_text.dart';
import '../domain/status.dart';
import 'standard_figure.dart';

/// I-Shape section: Standard figure (left) + status matrix and legend (right).
class IShapePanel extends StatelessWidget {
  const IShapePanel({
    super.key,
    required this.weight,
    required this.smm,
    required this.bfm,
    required this.waterPercent,
  });

  final Level weight;
  final Level smm;
  final Level bfm;
  final double waterPercent;

  Widget _sym(String s) =>
      Center(child: _Symbol(s, ReportText.matrixSymbol, 9));

  Widget _cell(Color c, bool dot) => Container(
    height: 18,
    color: c,
    alignment: Alignment.center,
    child: dot
        ? Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: ReportColors.dot,
              shape: BoxShape.circle,
            ),
          )
        : null,
  );

  Widget _matrixRow(String name, Level level) => Row(
    children: [
      SizedBox(width: 42, child: Text(name, style: ReportText.matrixLabel)),
      const SizedBox(width: 1),
      SizedBox(
        width: 18,
        child: _cell(ReportColors.matrixLow, level == Level.low),
      ),
      const SizedBox(width: 1),
      SizedBox(
        width: 18,
        child: _cell(ReportColors.matrixNormal, level == Level.normal),
      ),
      const SizedBox(width: 1),
      SizedBox(
        width: 18,
        child: _cell(ReportColors.matrixHigh, level == Level.high),
      ),
    ],
  );

  Widget _legendRow(String sym, String text) => SizedBox(
    height: 9,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 14,
          child: Center(child: _Symbol(sym, ReportText.legendSymbol, 7)),
        ),
        const SizedBox(width: 8),
        Text(text, softWrap: false, style: ReportText.legend),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 282,
    child: Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: ReportColors.ishVLine,
                    width: ReportColors.rule,
                  ),
                ),
              ),
              child: _StandardColumn(waterPercent),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                _ishTitle('I-Shape'),
                const SizedBox(height: 10),
                SizedBox(
                  width: 99,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 11,
                        child: Row(
                          children: [
                            const SizedBox(width: 43),
                            SizedBox(width: 18, child: _sym('—')),
                            const SizedBox(width: 1),
                            SizedBox(width: 18, child: _sym('○')),
                            const SizedBox(width: 1),
                            SizedBox(width: 18, child: _sym('+')),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      _matrixRow('Weight', weight),
                      const SizedBox(height: 4),
                      _matrixRow('SMM', smm),
                      const SizedBox(height: 4),
                      _matrixRow('BFM', bfm),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _legendRow('—', 'Result is Low'),
                    const SizedBox(height: 9),
                    _legendRow('○', 'Result is Normal'),
                    const SizedBox(height: 9),
                    _legendRow('+', 'Result is High'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _ishTitle(String t) => Container(
  height: 28,
  padding: const EdgeInsets.fromLTRB(18, 4, 18, 8),
  margin: const EdgeInsets.only(bottom: 8),
  decoration: const BoxDecoration(
    border: Border(
      bottom: BorderSide(
        color: ReportColors.ishTitleLine,
        width: ReportColors.rule,
      ),
    ),
  ),
  child: Text(t, style: ReportText.ishTitle),
);

class _StandardColumn extends StatelessWidget {
  const _StandardColumn(this.waterPercent);

  final double waterPercent;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      _ishTitle('Standard'),
      StandardFigure(waterPercent: waterPercent),
    ],
  );
}

/// Montserrat has no "○" glyph, so draw it; other symbols are plain text.
class _Symbol extends StatelessWidget {
  const _Symbol(this.symbol, this.style, this.size);

  final String symbol;
  final TextStyle style;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (symbol != '○') return Text(symbol, style: style);
    final d = size * .55;
    return Container(
      width: d,
      height: d,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: style.color!, width: size * .08),
      ),
    );
  }
}
