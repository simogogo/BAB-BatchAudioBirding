import 'detection.dart';

class AnalysisResult {
  final String filePath;
  final String fileName;
  final List<Detection> detections;
  final double durationSeconds;
  final String? error;
  final DateTime analyzedAt;

  const AnalysisResult({
    required this.filePath,
    required this.fileName,
    required this.detections,
    required this.durationSeconds,
    this.error,
    required this.analyzedAt,
  });

  bool get hasError => error != null;
  bool get hasDetections => detections.isNotEmpty;

  int get detectionCount => detections.length;

  List<String> get uniqueSpecies =>
      detections.map((d) => d.scientificName).toSet().toList();

  List<Detection> filtered(double minConfidence) =>
      detections.where((d) => d.confidence >= minConfidence).toList();

  /// Top-N detections by confidence (deduplicated by species)
  List<Detection> topDetections(int n) {
    final seen = <String>{};
    final top = <Detection>[];
    final sorted = List<Detection>.from(detections)
      ..sort((a, b) => b.confidence.compareTo(a.confidence));
    for (final d in sorted) {
      if (seen.add(d.scientificName)) {
        top.add(d);
        if (top.length >= n) break;
      }
    }
    return top;
  }
}
