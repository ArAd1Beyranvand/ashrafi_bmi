import 'package:equatable/equatable.dart';

import '../../../data/models/report_data.dart';

sealed class ImportState extends Equatable {
  const ImportState();

  @override
  List<Object?> get props => [];
}

class ImportIdle extends ImportState {
  const ImportIdle();
}

class ImportDragging extends ImportState {
  const ImportDragging();
}

class ImportLoading extends ImportState {
  const ImportLoading();
}

class ImportError extends ImportState {
  const ImportError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

class ImportSuccess extends ImportState {
  const ImportSuccess(this.data);
  final ReportData data;

  @override
  List<Object?> get props => [data];
}
