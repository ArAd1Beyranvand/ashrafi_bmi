import 'dart:io';

import 'package:flutter/services.dart';

/// Loads the bundled Montserrat files so widget/golden tests don't render with Ahem.
Future<void> loadMontserrat() async {
  final loader = FontLoader('Montserrat');
  for (final w in [400, 500, 600, 700, 800]) {
    loader.addFont(
      Future.value(
        ByteData.sublistView(
          File('assets/fonts/Montserrat-$w.ttf').readAsBytesSync(),
        ),
      ),
    );
  }
  await loader.load();
}
