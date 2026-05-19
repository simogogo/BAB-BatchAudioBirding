import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';

class SpeciesListExporter {
  /// Generates a .txt file with one species name per line.
  /// Returns the temporary file path.
  static Future<String> exportList(String name, List<String> scientificNames) async {
    // Sanitize file name
    final sanitizedName = name
        .replaceAll(RegExp(r'[^\w\s\-]'), '')
        .replaceAll(RegExp(r'\s+'), '_');
    final fileName = '${sanitizedName}_species_list.txt';
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');

    // Join names with a newline
    final content = scientificNames.join('\n');
    await file.writeAsString(content);
    return file.path;
  }

  /// Save a .txt species list file to device storage using file picker.
  /// Returns true if saved successfully, false if cancelled.
  static Future<bool> save(String txtPath, String defaultName) async {
    final bytes = await File(txtPath).readAsBytes();
    final String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'Save Species List',
      fileName: defaultName,
      bytes: bytes,
      type: FileType.any,
    );

    return outputFile != null;
  }
}
