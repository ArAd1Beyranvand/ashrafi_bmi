import 'package:flutter/material.dart';

import '../painters/body_path.dart';
import '../painters/liquid_painter.dart';

/// Standard figure of the I-Shape panel: gradient silhouette + animated body-water liquid.
class StandardFigure extends StatefulWidget {
  const StandardFigure({super.key, required this.waterPercent});

  final double waterPercent;

  static const height = 236.0;
  static const width = height * 200 / 410; // 115.1

  @override
  State<StandardFigure> createState() => _StandardFigureState();
}

class _StandardFigureState extends State<StandardFigure>
    with SingleTickerProviderStateMixin {
  late final _wave = AnimationController(vsync: this, duration: liquidLoop);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _wave.stop();
    } else if (!_wave.isAnimating) {
      _wave.repeat();
    }
  }

  @override
  void dispose() {
    _wave.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);
    return SizedBox(
      width: StandardFigure.width,
      height: StandardFigure.height,
      child: ClipPath(
        clipper: const BodyClipper(BodyPose.standing),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF163F73),
                    Color(0xFF1F5D83),
                    Color(0xFF3A9C9A),
                  ],
                  stops: [0, .45, 1],
                ),
              ),
            ),
            RepaintBoundary(
              child: TweenAnimationBuilder<double>(
                tween: Tween(end: widget.waterPercent),
                duration: still
                    ? Duration.zero
                    : const Duration(milliseconds: 600),
                curve: Curves.easeInOut,
                builder: (_, water, _) => CustomPaint(
                  painter: LiquidPainter(
                    animation: _wave,
                    waterPercent: water,
                    still: still,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
