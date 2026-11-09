import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Montserrat is bundled in assets/fonts; never fetch at runtime.
  GoogleFonts.config.allowRuntimeFetching = false;
  runApp(const App());
}
