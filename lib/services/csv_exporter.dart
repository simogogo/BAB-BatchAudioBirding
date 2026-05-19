import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../models/analysis_result.dart';
import '../models/detection.dart';

class CsvExporter {
  static const _headers = [
    'Start (s)',
    'End (s)',
    'Scientific name',
    'Common name',
    'Confidence',
    'File',
  ];

  /// Export all results to a single CSV file.
  /// Returns the path of the created file.
  static Future<String> exportAll(
    List<AnalysisResult> results, {
    double minConfidence = 0.0,
  }) async {
    final rows = <List<dynamic>>[_headers];

    for (final result in results) {
      for (final d in result.filtered(minConfidence)) {
        rows.add(_detectionRow(d, result.fileName));
      }
    }

    return _writeAndReturn('BirdNET_batch_results.csv', rows);
  }

  /// Export a single file result.
  static Future<String> exportSingle(
    AnalysisResult result, {
    double minConfidence = 0.0,
  }) async {
    final rows = <List<dynamic>>[_headers];
    for (final d in result.filtered(minConfidence)) {
      rows.add(_detectionRow(d, result.fileName));
    }

    final baseName = result.fileName.replaceAll(RegExp(r'\.\w+$'), '');
    return _writeAndReturn('${baseName}_BirdNET.csv', rows);
  }

  static List<dynamic> _detectionRow(Detection d, String fileName) => [
        d.startSeconds.toStringAsFixed(1),
        d.endSeconds.toStringAsFixed(1),
        d.scientificName,
        d.commonName,
        d.confidence.toStringAsFixed(4),
        fileName,
      ];

  static Future<String> _writeAndReturn(
    String fileName,
    List<List<dynamic>> rows,
  ) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    final csvString = const ListToCsvConverter().convert(rows);
    await file.writeAsString(csvString);
    return file.path;
  }

  /// Share a CSV file via the system share sheet.
  static Future<void> share(String csvPath, {String? subject}) async {
    await Share.shareXFiles(
      [XFile(csvPath, mimeType: 'text/csv')],
      subject: subject ?? 'BirdNET Analysis Results',
    );
  }

  /// Save a CSV file to device storage using file picker.
  /// Returns true if saved successfully, false if cancelled.
  static Future<bool> save(String csvPath, String defaultName) async {
    final bytes = await File(csvPath).readAsBytes();
    final String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Save CSV',
      fileName: defaultName,
      bytes: bytes,
      type: FileType.any,
    );

    return outputFile != null;
  }
}
