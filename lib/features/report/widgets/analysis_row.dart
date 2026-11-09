import 'package:flutter/material.dart';

import '../../../core/theme/report_colors.dart';
import '../painters/analysis_bar_painter.dart';

/// One analysis row (118 px label column + 322 px scale), 39 px high with a bottom rule.
class AnalysisRow extends StatelessWidget {
  const AnalysisRow({
    super.key,
    required this.name,
    required this.unit,
    required this.subtitle,
    required this.ticks,
    required this.bands,
    required this.value,
    required this.label,
    this.showHeader = false,
    this.showRule = true,
  });

  final String name;
  final String unit;
  final String subtitle;
  final List<double> ticks;
  final List<AnalysisBand> bands;
  final double value;
  final String label;
  final bool showHeader;
  final bool showRule;

  static const height = 39.0;

  static const _font = 'Montserrat';

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        border: showRule
            ? const Border(
                bottom: BorderSide(
                  color: ReportColors.rowLine,
                  width: ReportColors.rule,
                ),
              )
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 118,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontFamily: _font,
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: ReportColors.rowName,
                        height: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Text(
                        unit,
                        style: const TextStyle(
                          fontFamily: _font,
                          fontSize: 7,
                          fontWeight: FontWeight.w600,
                          color: ReportColors.rowName,
                          height: 1,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: _font,
                    fontSize: 6,
                    color: ReportColors.rowSub,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 30),
              child: SizedBox(
                height: 40,
                child: CustomPaint(
                  painter: AnalysisBarPainter(
                    ticks: ticks,
                    bands: bands,
                    value: value,
                    label: label,
                    showHeader: showHeader,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
