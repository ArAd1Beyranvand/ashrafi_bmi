import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Renders the A4 sheet to PNG bytes (pixelRatio 3 in the app).
typedef SheetCapture = Future<Uint8List> Function();

/// Writes [bytes] to a user-chosen location. Returns the saved path, '' when saved without a
/// known path (web download), or null when cancelled.
typedef FileSaver = Future<String?> Function(
  String fileName,
  Uint8List bytes,
  String mimeType,
);

Future<String?> pickerFileSaver(
  String fileName,
  Uint8List bytes,
  String mimeType,
) async {
  final result = await FilePicker.saveFile(
    dialogTitle: 'Save report',
    fileName: fileName,
    bytes: bytes,
    mimeType: mimeType,
  );
  if (result == null) {
    return kIsWeb ? '' : null; // web: download starts, no path
  }
  return result.scheme == 'file' ? result.toFilePath() : result.toString();
}

class ExportService {
  ExportService({required this.capture, FileSaver? saver})
    : _saver = saver ?? pickerFileSaver;

  final SheetCapture capture;
  final FileSaver _saver;

  /// One A4 page with the captured sheet full-bleed, no margin.
  static Future<Uint8List> buildPdf(Uint8List png) async {
    final doc = pw.Document();
    final image = pw.MemoryImage(png);
    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.zero,
        build: (_) => pw.Image(image, fit: pw.BoxFit.fill),
      ),
    );
    return doc.save();
  }

  Future<Uint8List> pdfBytes() async => buildPdf(await capture());

  Future<String?> savePng(String baseName) async =>
      _saver('$baseName.png', await capture(), 'image/png');

  Future<String?> savePdf(String baseName) async =>
      _saver('$baseName.pdf', await pdfBytes(), 'application/pdf');

  /// System print / share dialog.
  Future<void> printPdf(String baseName) async {
    final bytes = await pdfBytes();
    await Printing.layoutPdf(
      name: baseName,
      format: PdfPageFormat.a4,
      onLayout: (_) async => bytes,
    );
  }
}
