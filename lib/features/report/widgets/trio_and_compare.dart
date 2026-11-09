import 'package:flutter/material.dart';

import '../../../core/theme/gradients.dart';
import '../../../core/theme/report_colors.dart';
import '../../../core/theme/report_text.dart';

/// Body Age / Bone Mass / BMR.
class Trio extends StatelessWidget {
  const Trio({super.key, required this.values});

  final List<String> values;

  static const _heads = ['Body Age', 'Bone Mass', 'BMR'];

  @override
  Widget build(BuildContext context) {
    final gradients = [
      ReportGradients.trio1,
      ReportGradients.trio2,
      ReportGradients.trio3,
    ];
    return Column(
      children: [
        Row(
          children: [
            for (var i = 0; i < 3; i++)
              Expanded(
                child: Container(
                  height: 27,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: gradients[i],
                    border: i < 2
                        ? Border(
                            right: BorderSide(
                              color: Colors.white.withValues(alpha: .5),
                            ),
                          )
                        : null,
                  ),
                  child: Text(_heads[i], style: ReportText.trioHead),
                ),
              ),
          ],
        ),
        Row(
          children: [
            for (var i = 0; i < 3; i++)
              Expanded(
                child: Container(
                  height: 39,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: i < 2
                        ? const Border(
                            right: BorderSide(color: ReportColors.ishVLine),
                          )
                        : null,
                  ),
                  child: Text(values[i], style: ReportText.trioValue),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Compared To First And Last Measurement grid.
class CompareTable extends StatelessWidget {
  const CompareTable({super.key, required this.rows});

  /// (row header, weight, fat, SMM)
  final List<(String, String, String, String)> rows;

  static const _heads = ['%', 'Weight', 'Fat', 'SMM'];
  static final _whiteLine = Colors.white.withValues(alpha: .45);

  Border _border(Color c) => Border(
    right: BorderSide(color: c),
    bottom: BorderSide(color: c),
  );

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(gradient: ReportGradients.compare),
    child: Column(
      children: [
        Row(
          children: [
            for (var i = 0; i < 4; i++)
              _sized(
                i,
                Container(
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(border: _border(_whiteLine)),
                  child: Text(_heads[i], style: ReportText.cmpHead),
                ),
              ),
          ],
        ),
        for (final r in rows)
          Row(
            children: [
              _sized(
                0,
                Container(
                  height: 27,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(border: _border(_whiteLine)),
                  child: Text(
                    r.$1,
                    textAlign: TextAlign.center,
                    style: ReportText.cmpRowHead,
                  ),
                ),
              ),
              for (var i = 0; i < 3; i++)
                _sized(
                  i + 1,
                  Container(
                    height: 27,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: _border(ReportColors.compareLine),
                    ),
                    child: Text(
                      [r.$2, r.$3, r.$4][i],
                      style: ReportText.cmpCell,
                    ),
                  ),
                ),
            ],
          ),
      ],
    ),
  );

  Widget _sized(int col, Widget child) =>
      col == 0 ? SizedBox(width: 72, child: child) : Expanded(child: child);
}
