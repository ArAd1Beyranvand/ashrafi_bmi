import 'package:flutter/material.dart';

import '../../../core/theme/gradients.dart';
import '../../../core/theme/report_text.dart';

class TopBar extends StatelessWidget {
  const TopBar({super.key, required this.model});

  final String model;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 44,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 11),
              child: Text('charder', style: ReportText.logo),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 1, top: 3.6),
              child: Text('®', style: ReportText.logoSup),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Text(model, style: ReportText.model),
        ),
      ],
    ),
  );
}

/// Name / ID / Gender / Age / Height / Date strip.
class IdentGrid extends StatelessWidget {
  const IdentGrid({super.key, required this.values});

  /// Six values in column order.
  final List<String> values;

  static const _heads = ['Name', 'ID', 'Gender', 'Age', 'Height', 'Date'];
  static const _flex = [13, 7, 8, 8, 8, 14];

  static final _gradients = [
    ReportGradients.g,
    ReportGradients.identId,
    ReportGradients.identGender,
    ReportGradients.identAge,
    ReportGradients.identHeight,
    ReportGradients.identDate,
  ];

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Row(
        children: [
          for (var i = 0; i < 6; i++)
            Expanded(
              flex: _flex[i],
              child: Container(
                height: 25,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: _gradients[i],
                  border: i < 5
                      ? const Border(
                          right: BorderSide(color: Colors.white, width: 2),
                        )
                      : null,
                ),
                child: Text(
                  _heads[i],
                  softWrap: false,
                  style: ReportText.identHead,
                ),
              ),
            ),
        ],
      ),
      Row(
        children: [
          for (var i = 0; i < 6; i++)
            Expanded(
              flex: _flex[i],
              child: Container(
                height: 24,
                alignment: Alignment.center,
                color: const Color(0xFFECECEC),
                child: Text(
                  values[i],
                  softWrap: false,
                  style: ReportText.identValue,
                ),
              ),
            ),
        ],
      ),
    ],
  );
}
