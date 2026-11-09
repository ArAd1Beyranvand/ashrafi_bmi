import 'dart:convert';
import 'dart:typed_data';

import '../models/measurement.dart';
import '../models/person.dart';
import '../models/report_data.dart';
import '../models/segmental.dart';

class ReportParseException implements Exception {
  const ReportParseException(this.message);
  final String message;

  @override
  String toString() => message;
}

const _notValid = 'This file is not valid base64 or JSON';

/// Parses a Charder device export (raw JSON or base64 JSON). See docs/DATA_CONTRACT.md.
class ReportParser {
  const ReportParser._();

  /// [fileName] is only used to derive the person's name when the file has none (Q1).
  static ReportData parse(Uint8List bytes, {String? fileName}) {
    final root = _decode(bytes);
    if (root is! Map<String, dynamic>) {
      throw const ReportParseException(
        'Unexpected file structure: expected a JSON object',
      );
    }
    final height = _num(root, 'Height', 'Height', positive: true) / 10;
    final gender = _num(root, 'Gender', 'Gender') == 1
        ? 'Male'
        : 'Female'; // Q2 provisional
    DateTime? birthday;
    if (root['Birthday'] != null) {
      birthday = _date(root['Birthday']);
      if (birthday == null) {
        throw const ReportParseException('Invalid value for Birthday');
      }
    }
    final name = _str(root['Name']) ?? _nameFromFile(fileName) ?? '–';
    final id = _str(root['Id']) ?? '–';

    if (!root.containsKey('DataArray') || root['DataArray'] == null) {
      throw const ReportParseException('Missing field: DataArray');
    }
    final raw = root['DataArray'];
    if (raw is! List || raw.isEmpty) {
      throw const ReportParseException('No measurements found in the file');
    }
    final list = <Measurement>[
      for (var i = 0; i < raw.length; i++) _measurement(raw[i], i),
    ];
    // List.sort is not stable; sort on (timestamp, original index).
    final order = List<int>.generate(list.length, (i) => i)
      ..sort((a, b) {
        final c = list[a].timestamp.compareTo(list[b].timestamp);
        return c != 0 ? c : a.compareTo(b);
      });
    return ReportData(
      person: Person(
        name: name,
        id: id,
        gender: gender,
        heightCm: height,
        birthday: birthday,
      ),
      measurements: [for (final i in order) list[i]],
    );
  }

  static dynamic _decode(Uint8List bytes) {
    var text = utf8.decode(bytes, allowMalformed: true);
    if (text.startsWith('\uFEFF')) text = text.substring(1);
    text = text.trim();
    if (text.isEmpty) throw const ReportParseException('The file is empty');
    if (!text.startsWith('{')) {
      text = _decodeBase64(text);
      if (text.isEmpty) throw const ReportParseException(_notValid);
    }
    try {
      return jsonDecode(text);
    } on FormatException {
      throw const ReportParseException(_notValid);
    }
  }

  static String _decodeBase64(String input) {
    var s = input;
    if (s.startsWith('data:')) {
      final comma = s.indexOf(',');
      if (comma < 0) throw const ReportParseException(_notValid);
      s = s.substring(comma + 1);
    }
    s = s
        .replaceAll(RegExp(r'\s'), '')
        .replaceAll('-', '+')
        .replaceAll('_', '/');
    s = s.replaceAll(RegExp(r'=+$'), '');
    if (s.length % 4 == 1) throw const ReportParseException(_notValid);
    s = s.padRight(s.length + (4 - s.length % 4) % 4, '=');
    try {
      return utf8.decode(base64.decode(s)).replaceFirst('\uFEFF', '').trim();
    } on FormatException {
      throw const ReportParseException(_notValid);
    }
  }

  static Measurement _measurement(dynamic item, int i) {
    final p = 'DataArray[$i]';
    if (item is! Map<String, dynamic>) {
      throw ReportParseException('Invalid value for $p');
    }
    double n(
      String k, {
      double scale = 1,
      bool pct = false,
      bool positive = false,
    }) => _num(item, k, '$p.$k', positive: positive, pct: pct) / scale;

    final dateRaw = item['date'];
    if (dateRaw == null) throw ReportParseException('Missing field: $p.date');
    final ts = _date(dateRaw);
    if (ts == null) throw ReportParseException('Invalid date in $p.date');

    final weight = n('weight', scale: 100, positive: true);
    final fatPct = n('bodyFat', scale: 10, pct: true);
    final bmi = n('bmi', scale: 10);
    final smm = n('smm', scale: 10);
    final lean = n('muscleMass', scale: 10);
    final water = n('bodyWater', scale: 10, pct: true);
    final visc = n('vatLevel');
    final bodyAge = n('bodyAge');
    final bmr = n('bmr');
    final bone = n('boneMass', scale: 10);

    SegmentalValues seg(String Function(String) key, double scale) =>
        SegmentalValues(
          trunk: n(key('Trunk'), scale: scale),
          rightArm: n(key('RightArm'), scale: scale),
          leftArm: n(key('LeftArm'), scale: scale),
          rightLeg: n(key('RightLeg'), scale: scale),
          leftLeg: n(key('LeftLeg'), scale: scale),
        );
    SegmentalValues? optSeg(String Function(String) key, double scale) {
      final keys = [
        'Trunk',
        'RightArm',
        'LeftArm',
        'RightLeg',
        'LeftLeg',
      ].map(key);
      return keys.every((k) => item[k] != null) ? seg(key, scale) : null;
    }

    final segmental = Segmental(
      muscle: seg((s) => 'muscleMass$s', 10),
      fat: seg((s) => 'bodyFat${s}Mass', 10),
      fatPercent: optSeg((s) => 'bodyFat$s', 10),
      fatLevel: optSeg((s) => '${_lower(s)}Fat', 1),
      leanLevel: optSeg((s) => '${_lower(s)}Lean', 1),
    );

    return Measurement(
      timestamp: ts,
      weight: weight,
      bmi: bmi,
      visceralFat: visc,
      bodyFatPercent: fatPct,
      bodyFatMass:
          (weight * fatPct / 10).round() / 10, // Q3 provisional: weight × fat%
      smm: smm,
      leanMass: lean,
      bodyWaterPercent: water,
      bodyAge: bodyAge,
      bmr: bmr,
      boneMass: bone,
      segmental: segmental,
    );
  }

  static String _lower(String s) => s[0].toLowerCase() + s.substring(1);

  static double _num(
    Map<String, dynamic> m,
    String key,
    String path, {
    bool positive = false,
    bool pct = false,
  }) {
    final v = m[key];
    if (v == null) throw ReportParseException('Missing field: $path');
    if (v is! num || !v.isFinite) {
      throw ReportParseException('Invalid value for $path');
    }
    final d = v.toDouble();
    if ((positive && d <= 0) || (pct && (d < 0 || d > 1000))) {
      throw ReportParseException('Invalid value for $path');
    }
    return d;
  }

  static String? _str(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  static DateTime? _date(dynamic v) {
    if (v is! String) return null;
    return DateTime.tryParse(v.trim().replaceFirst(' ', 'T'));
  }

  static String? _nameFromFile(String? fileName) {
    if (fileName == null) return null;
    var base = fileName.split(RegExp(r'[\\/]')).last;
    final dot = base.lastIndexOf('.');
    if (dot > 0) base = base.substring(0, dot);
    final us = base.indexOf('_');
    final name = (us > 0 ? base.substring(0, us) : base).trim();
    return name.isEmpty ? null : name;
  }
}
