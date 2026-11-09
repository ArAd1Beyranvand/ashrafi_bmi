import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ashrafi_bmi/features/import/cubit/import_cubit.dart';
import 'package:ashrafi_bmi/features/import/cubit/import_state.dart';

Uint8List get _sample =>
    File('assets/sample/sample_report.json').readAsBytesSync();
XFile _file(List<int> b, String name) =>
    XFile.fromData(Uint8List.fromList(b), name: name);

Future<List<ImportState>> _collect(
  ImportCubit c,
  Future<void> Function() act,
) async {
  final states = <ImportState>[];
  final sub = c.stream.listen(states.add);
  await act();
  await Future<void>.delayed(Duration.zero);
  await sub.cancel();
  return states;
}

void main() {
  test('starts idle', () => expect(ImportCubit().state, const ImportIdle()));

  test('setDragging toggles Dragging/Idle', () async {
    final c = ImportCubit();
    final s = await _collect(c, () async {
      c.setDragging(true);
      c.setDragging(false);
    });
    expect(s, [const ImportDragging(), const ImportIdle()]);
  });

  test('dropFiles with valid bytes -> Loading, Success', () async {
    final c = ImportCubit();
    final s = await _collect(
      c,
      () => c.dropFiles([_file(_sample, 'Ali_data.json')]),
    );
    expect(s.first, const ImportLoading());
    expect(s.last, isA<ImportSuccess>());
    expect((s.last as ImportSuccess).data.person.name, 'CHARDER EGYPT');
  });

  test('dropFiles with invalid bytes -> Error', () async {
    final c = ImportCubit();
    final s = await _collect(
      c,
      () => c.dropFiles([_file(utf8.encode('%%%'), 'x.txt')]),
    );
    expect(s, [
      const ImportLoading(),
      const ImportError('This file is not valid base64 or JSON'),
    ]);
  });

  test('dropFiles empty -> Idle', () async {
    final c = ImportCubit();
    await c.dropFiles([]);
    expect(c.state, const ImportIdle());
  });

  test('pickFile: cancel emits nothing, file loads, throw -> Error', () async {
    final cancel = ImportCubit(picker: () async => null);
    expect(await _collect(cancel, cancel.pickFile), isEmpty);

    final ok = ImportCubit(picker: () async => _file(_sample, 'Sample.json'));
    await ok.pickFile();
    expect(ok.state, isA<ImportSuccess>());

    final bad = ImportCubit(picker: () async => throw Exception('x'));
    await bad.pickFile();
    expect(bad.state, isA<ImportError>());
  });

  test('loadSample -> Loading, Success named from file', () async {
    final c = ImportCubit(sampleLoader: () async => _sample);
    final s = await _collect(c, c.loadSample);
    expect(s.first, const ImportLoading());
    expect((s.last as ImportSuccess).data.person.name, 'CHARDER EGYPT');
  });

  test('reset returns to Idle; setDragging ignored while loading', () async {
    final c = ImportCubit(sampleLoader: () async => _sample);
    await c.loadSample();
    c.reset();
    expect(c.state, const ImportIdle());
  });
}
