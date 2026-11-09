import 'package:flutter/material.dart';

import 'data/models/report_data.dart';
import 'features/import/view/import_page.dart';
import 'features/report/view/report_page.dart';

class App extends StatelessWidget {
  const App({super.key, this.initialData});

  /// Dev shortcut: when set, the report opens first (the import page stays underneath).
  final ReportData? initialData;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Charder U310 Report',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Montserrat',
        scaffoldBackgroundColor: const Color(0xFFDFE4E7),
      ),
      initialRoute: initialData == null ? '/' : '/report',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => const ImportPage(),
            );
          case '/report':
            final data = (settings.arguments as ReportData?) ?? initialData!;
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => ReportPage(data: data),
            );
        }
        return null;
      },
    );
  }
}
