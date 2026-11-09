import 'package:flutter/material.dart';

import '../../../core/theme/report_colors.dart';
import '../../../core/theme/report_text.dart';

class BodyCompositionTable extends StatelessWidget {
  const BodyCompositionTable({super.key, required this.rows});

  /// (label, sub-label, value)
  final List<(String, String, String)> rows;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 5),
    child: Column(
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0) const SizedBox(height: 3),
          Row(
            children: [
              Container(
                width: 283,
                height: 21.6,
                color: ReportColors.cellBg,
                padding: const EdgeInsets.only(left: 10, right: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(rows[i].$1, style: ReportText.cellLabel),
                    Text('(${rows[i].$2})', style: ReportText.cellSub),
                  ],
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Container(
                  height: 21.6,
                  color: ReportColors.cellBg,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 10),
                  child: Text(rows[i].$3, style: ReportText.cellValue),
                ),
              ),
            ],
          ),
        ],
      ],
    ),
  );
}
