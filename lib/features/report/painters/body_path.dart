import 'package:flutter/widgets.dart';

import '../../../core/utils/catmull_rom.dart';

enum BodyPose { standing, flex }

/// Figure design space of the silhouettes.
const figureSize = Size(200, 410);

final _standPath = closedCatmullRom(mirrorHalf(standHalf));
final _flexPath = closedCatmullRom(mirrorHalf(flexHalf));

/// Silhouette in figure space (built once per pose).
Path bodyPath(BodyPose pose) =>
    pose == BodyPose.standing ? _standPath : _flexPath;

/// Clips to the silhouette, scaled from 200×410 to the widget size.
class BodyClipper extends CustomClipper<Path> {
  const BodyClipper(this.pose);

  final BodyPose pose;

  @override
  Path getClip(Size size) => bodyPath(pose).transform(
    (Matrix4.identity()..scaleByDouble(
          size.width / figureSize.width,
          size.height / figureSize.height,
          1,
          1,
        ))
        .storage,
  );

  /// Size changes re-clip automatically; only the pose matters here.
  @override
  bool shouldReclip(BodyClipper oldClipper) => oldClipper.pose != pose;
}
