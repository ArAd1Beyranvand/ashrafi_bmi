import 'package:cross_file/cross_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/parser/report_parser.dart';
import 'import_state.dart';

typedef FilePickerFn = Future<XFile?> Function();
typedef SampleLoader = Future<Uint8List> Function();

const sampleAsset = 'assets/sample/sample_report.json';

class ImportCubit extends Cubit<ImportState> {
  ImportCubit({FilePickerFn? picker, SampleLoader? sampleLoader})
    : _picker = picker ?? _defaultPicker,
      _sampleLoader = sampleLoader ?? _defaultSample,
      super(const ImportIdle());

  final FilePickerFn _picker;
  final SampleLoader _sampleLoader;

  // Bytes are read through XFile, which works on Linux, Android and web (no paths).
  static Future<XFile?> _defaultPicker() async {
    final file = await FilePicker.pickFile();
    return file?.xFile;
  }

  static Future<Uint8List> _defaultSample() async {
    final data = await rootBundle.load(sampleAsset);
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }

  bool get _busy => state is ImportLoading;

  void setDragging(bool dragging) {
    if (_busy) return;
    if (dragging) {
      emit(const ImportDragging());
    } else if (state is ImportDragging) {
      emit(const ImportIdle());
    }
  }

  /// Back to idle (called after navigating to the report).
  void reset() => emit(const ImportIdle());

  Future<void> pickFile() async {
    if (_busy) return;
    final XFile? file;
    try {
      file = await _picker();
    } catch (_) {
      emit(const ImportError('Could not open the file picker'));
      return;
    }
    if (file == null) return; // cancelled
    await _load(file);
  }

  Future<void> dropFiles(List<XFile> files) async {
    if (_busy) return;
    if (files.isEmpty) {
      emit(const ImportIdle());
      return;
    }
    await _load(files.first);
  }

  Future<void> loadSample() async {
    if (_busy) return;
    emit(const ImportLoading());
    try {
      final bytes = await _sampleLoader();
      emit(ImportSuccess(ReportParser.parse(bytes, fileName: 'Sample.json')));
    } on ReportParseException catch (e) {
      emit(ImportError(e.message));
    } catch (_) {
      emit(const ImportError('Could not load the sample'));
    }
  }

  Future<void> _load(XFile file) async {
    emit(const ImportLoading());
    try {
      final bytes = await file.readAsBytes();
      emit(ImportSuccess(ReportParser.parse(bytes, fileName: file.name)));
    } on ReportParseException catch (e) {
      emit(ImportError(e.message));
    } catch (_) {
      emit(const ImportError('Could not read the file'));
    }
  }
}
