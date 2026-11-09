import 'package:equatable/equatable.dart';

import 'measurement.dart';
import 'person.dart';

class ReportData extends Equatable {
  /// [measurements] must be non-empty and ascending by timestamp (the parser guarantees it).
  ReportData({
    required this.person,
    required List<Measurement> measurements,
    this.device = 'U310',
  }) : assert(measurements.isNotEmpty),
       measurements = List.unmodifiable(measurements);

  final Person person;
  final String device;
  final List<Measurement> measurements;

  Measurement get current => measurements.last;
  Measurement get first => measurements.first;
  Measurement get previous =>
      measurements.length > 1 ? measurements[measurements.length - 2] : current;

  /// Last 7 measurements (Change table columns).
  List<Measurement> get history => historyUpTo(measurements.length - 1);

  /// Last 7 measurements ending at [index] (inclusive).
  List<Measurement> historyUpTo(int index) {
    final end = index + 1;
    return measurements.sublist(end > 7 ? end - 7 : 0, end);
  }

  @override
  List<Object?> get props => [person, device, measurements];
}
