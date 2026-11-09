import 'dart:convert';
import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ashrafi_bmi/features/import/cubit/import_cubit.dart';
import 'package:ashrafi_bmi/features/import/view/import_page.dart';

void main() {
  testWidgets('invalid bytes show the parser message', (tester) async {
    tester.view.physicalSize = const Size(1000, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final cubit = ImportCubit(
      picker: () async => XFile.fromData(
        Uint8List.fromList(utf8.encode('%%%')),
        name: 'bad.txt',
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(value: cubit, child: const ImportView()),
      ),
    );
    await tester.tap(find.text('Choose file'));
    await tester.pumpAndSettle();
    expect(find.text('This file is not valid base64 or JSON'), findsOneWidget);
  });
}
