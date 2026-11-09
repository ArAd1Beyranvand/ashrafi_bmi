import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/measurement.dart';
import '../../../data/models/report_data.dart';

class ReportState extends Equatable {
  const ReportState(this.data, this.selectedIndex);

  final ReportData data;
  final int selectedIndex;

  Measurement get current => data.measurements[selectedIndex];

  /// Everything up to and including the selected measurement.
  List<Measurement> get history =>
      data.measurements.sublist(0, selectedIndex + 1);

  Measurement get first => history.first;

  Measurement get previous =>
      history.length > 1 ? history[history.length - 2] : current;

  /// Change-table columns: last 7 of [history].
  List<Measurement> get changeColumns => data.historyUpTo(selectedIndex);

  int? get age => data.person.ageAt(current.timestamp);

  @override
  List<Object?> get props => [data, selectedIndex];
}

class ReportCubit extends Cubit<ReportState> {
  ReportCubit(ReportData data)
    : super(ReportState(data, data.measurements.length - 1));

  void select(int index) {
    if (index < 0 ||
        index >= state.data.measurements.length ||
        index == state.selectedIndex) {
      return;
    }
    emit(ReportState(state.data, index));
  }
}
