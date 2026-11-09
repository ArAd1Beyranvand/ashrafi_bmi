import 'package:flutter/material.dart';

import '../../../core/theme/gradients.dart';
import '../../../core/theme/report_colors.dart';
import '../../../core/theme/report_text.dart';

/// `.t` section title bar (gradient G).
class SectionTitle extends StatelessWidget {
  const SectionTitle(
    this.text, {
    super.key,
    this.center = false,
    this.small = false,
  });

  final String text;
  final bool center;
  final bool small;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    // Chrome's rendered heights (rounded text line + 12 padding).
    height: small ? 25 : 28,
    alignment: center ? Alignment.center : Alignment.centerLeft,
    decoration: BoxDecoration(gradient: ReportGradients.g),
    padding: const EdgeInsets.symmetric(horizontal: 10),
    child: Text(
      text,
      softWrap: false,
      textAlign: center ? TextAlign.center : TextAlign.left,
      style: small ? ReportText.titleSmall : ReportText.title,
    ),
  );
}

/// Same-size stand-in for sections drawn in later prompts.
class PlaceholderBox extends StatelessWidget {
  const PlaceholderBox(
    this.label, {
    super.key,
    this.width,
    required this.height,
  });

  final String label;
  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    height: height,
    color: ReportColors.placeholder,
    alignment: Alignment.center,
    child: Text(label, style: ReportText.placeholder),
  );
}

/// Paints a 1 px dashed line on the right edge (CSS `border-right: 1px dashed`).
class DashedRightBorder extends CustomPainter {
  const DashedRightBorder(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1;
    final x = size.width - .5;
    for (double y = 0; y < size.height; y += 6) {
      canvas.drawLine(
        Offset(x, y),
        Offset(x, (y + 3).clamp(0, size.height)),
        p,
      );
    }
  }

  @override
  bool shouldRepaint(DashedRightBorder old) => old.color != color;
}
