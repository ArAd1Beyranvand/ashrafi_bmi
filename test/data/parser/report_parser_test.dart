import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:ashrafi_bmi/data/parser/report_parser.dart';
import 'package:flutter_test/flutter_test.dart';

Uint8List b(String s) => Uint8List.fromList(utf8.encode(s));

Map<String, dynamic> entry(String date, {int weight = 8000}) => {
  'date': date,
  'weight': weight,
  'bmi': 250,
  'bodyFat': 200,
  'muscleMass': 600,
  'bmr': 1700,
  'boneMass': 31,
  'smm': 340,
  'vatLevel': 8,
  'bodyAge': 40,
  'bodyWater': 550,
  'muscleMassTrunk': 290,
  'muscleMassRightArm': 40,
  'muscleMassLeftArm': 40,
  'muscleMassRightLeg': 90,
  'muscleMassLeftLeg': 90,
  'bodyFatTrunkMass': 100,
  'bodyFatRightArmMass': 10,
  'bodyFatLeftArmMass': 10,
  'bodyFatRightLegMass': 20,
  'bodyFatLeftLegMass': 20,
};

Map<String, dynamic> file(List<Map<String, dynamic>> data) => {
  'Gender': 1,
  'Birthday': '1990-05-10 00:00:00',
  'Height': 1800,
  'DataArray': data,
};

String msg(Object? Function() f) {
  try {
    f();
  } on ReportParseException catch (e) {
    return e.message;
  }
  fail('expected ReportParseException');
}

void main() {
  final raw = jsonEncode(file([entry('2026-01-01 10:00:00')]));

  test('raw JSON, scaling and derived values', () {
    final d = ReportParser.parse(b(raw), fileName: 'Hamid_AllData_x.txt');
    expect(d.person.name, 'Hamid');
    expect(d.person.id, '–');
    expect(d.person.gender, 'Male');
    expect(d.person.heightCm, 180);
    expect(d.person.ageAt(d.current.timestamp), 35);
    expect(d.current.weight, 80);
    expect(d.current.bmi, 25);
    expect(d.current.bodyFatPercent, 20);
    expect(d.current.bodyFatMass, 16);
    expect(d.current.segmental.muscle.trunk, 29);
    expect(d.current.segmental.fatPercent, isNull);
  });

  test('BOM + whitespace', () {
    expect(
      ReportParser.parse(b('\uFEFF\n  $raw \n')).measurements,
      hasLength(1),
    );
  });

  test('base64', () {
    expect(
      ReportParser.parse(b(base64.encode(utf8.encode(raw)))).measurements,
      hasLength(1),
    );
  });

  test('base64 with data URL prefix and newlines', () {
    final e = base64.encode(utf8.encode(raw));
    final wrapped = RegExp('.{1,20}')
        .allMatches(e)
        .map((m) => m[0])
        .join('\r\n');
    expect(
      ReportParser.parse(b('data:application/json;base64,$wrapped'))
          .measurements,
      hasLength(1),
    );
  });

  test('URL-safe base64 without padding', () {
    final text = jsonEncode(
      file([entry('2026-01-01 10:00:00')])..['Name'] = '??>>~~é',
    );
    final e = base64Url.encode(utf8.encode(text)).replaceAll('=', '');
    expect(e, anyOf(contains('-'), contains('_')));
    expect(ReportParser.parse(b(e)).person.name, '??>>~~é');
  });

  test('error messages', () {
    expect(msg(() => ReportParser.parse(b(''))), 'The file is empty');
    expect(
      msg(() => ReportParser.parse(b('@@@@!!!'))),
      'This file is not valid base64 or JSON',
    );
    expect(
      msg(() => ReportParser.parse(b('{"a": '))),
      'This file is not valid base64 or JSON',
    );
    expect(
      msg(() => ReportParser.parse(b(base64.encode(utf8.encode('[1]'))))),
      'Unexpected file structure: expected a JSON object',
    );
    expect(
      msg(() => ReportParser.parse(b('{"Gender":1,"DataArray":[]}'))),
      'Missing field: Height',
    );
    expect(
      msg(() => ReportParser.parse(b(jsonEncode(file([]))))),
      'No measurements found in the file',
    );
    expect(
      msg(
        () => ReportParser.parse(
          b(jsonEncode(file([entry('2026-01-01 10:00:00')..remove('weight')]))),
        ),
      ),
      'Missing field: DataArray[0].weight',
    );
    expect(
      msg(
        () => ReportParser.parse(
          b(jsonEncode(file([entry('2026-01-01 10:00:00')..['bmi'] = 'x']))),
        ),
      ),
      'Invalid value for DataArray[0].bmi',
    );
    expect(
      msg(() => ReportParser.parse(b(jsonEncode(file([entry('nope')]))))),
      'Invalid date in DataArray[0].date',
    );
    expect(
      msg(
        () => ReportParser.parse(
          b(jsonEncode(file([entry('2026-01-01 10:00:00', weight: 0)]))),
        ),
      ),
      'Invalid value for DataArray[0].weight',
    );
  });

  test('sorting ascending; previous/first/history', () {
    final d = ReportParser.parse(
      b(
        jsonEncode(
          file([
            entry('2026-03-01 10:00:00', weight: 8300),
            entry('2026-01-01 10:00:00', weight: 8100),
            entry('2026-02-01 10:00:00', weight: 8200),
          ]),
        ),
      ),
    );
    expect(d.measurements.map((m) => m.weight), [81, 82, 83]);
    expect(d.first.weight, 81);
    expect(d.previous.weight, 82);
    expect(d.current.weight, 83);
    expect(d.history, hasLength(3));
  });

  test('single measurement: previous == current; history capped at 7', () {
    final one = ReportParser.parse(b(raw));
    expect(one.previous, one.current);
    final many = ReportParser.parse(
      b(
        jsonEncode(
          file([
            for (var i = 1; i <= 9; i++)
              entry('2026-01-0$i 10:00:00', weight: 8000 + i),
          ]),
        ),
      ),
    );
    expect(many.history, hasLength(7));
    expect(many.history.first.weight, 80.03);
    expect(many.historyUpTo(2), hasLength(3));
  });

  test('real device export parses', () {
    final d = ReportParser.parse(
      File('docs/reference/sample_input.b64').readAsBytesSync(),
      fileName: 'Hamid_AllData_2026-11-08 10.54.27.txt',
    );
    expect(d.person.name, 'Hamid');
    expect(d.person.heightCm, 168);
    expect(d.current.weight, 82.25);
    expect(d.current.bodyFatMass, 21.5);
    expect(d.current.segmental.muscle.trunk, 29.8);
    expect(d.current.segmental.fat.trunk, 13);
    expect(d.current.segmental.fatPercent!.rightArm, 21.9);
    expect(d.current.segmental.leanLevel!.rightLeg, 2);
    expect(d.person.ageAt(d.current.timestamp), 52);
  });

  test('sample_report.json', () {
    final d = ReportParser.parse(
      File('assets/sample/sample_report.json').readAsBytesSync(),
    );
    expect(d.measurements, hasLength(1));
    expect(d.person.name, 'CHARDER EGYPT');
    expect(d.person.id, 'A00BF');
    expect(d.person.heightCm, 179);
    expect(d.person.ageAt(d.current.timestamp), 29);
    expect(d.current.weight, 72.6);
    expect(d.current.bodyFatMass, 15.4);
    expect(d.current.leanMass, 53.9);
    expect(d.current.segmental.muscle.trunk, 25.3);
  });

  test('sample_history.b64', () {
    final d = ReportParser.parse(
      File('assets/sample/sample_history.b64').readAsBytesSync(),
    );
    expect(d.measurements, hasLength(5));
    expect(d.person.name, 'majid');
    expect(d.person.id, '09133317383');
    expect(d.person.heightCm, 182);
    expect(d.person.ageAt(d.current.timestamp), 36);
    expect(d.current.weight, 77.95);
    expect(d.current.bodyFatMass, 15.2);
    expect(d.current.leanMass, 62.8);
    expect(d.current.segmental.muscle.trunk, 28.3);
    expect(d.current.segmental.fat.trunk, 8.8);
    expect(d.first.weight, 81.4);
    expect(d.previous.weight, 78.6);
  });
}
