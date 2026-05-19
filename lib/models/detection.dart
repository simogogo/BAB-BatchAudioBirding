class Detection {
  final String scientificName;
  final String commonName;
  final double confidence;
  final double startSeconds;
  final double endSeconds;

  const Detection({
    required this.scientificName,
    required this.commonName,
    required this.confidence,
    required this.startSeconds,
    required this.endSeconds,
  });

  String get startFormatted => _formatSeconds(startSeconds);
  String get endFormatted => _formatSeconds(endSeconds);

  String _formatSeconds(double s) {
    final m = s ~/ 60;
    final sec = (s % 60).toStringAsFixed(1);
    return '${m.toString().padLeft(2, '0')}:${sec.padLeft(4, '0')}';
  }

  /// Confidence as percentage string e.g. "87%"
  String get confidencePercent => '${(confidence * 100).round()}%';

  Map<String, dynamic> toCsvRow(String fileName) => {
    'Start (s)': startSeconds.toStringAsFixed(1),
    'End (s)': endSeconds.toStringAsFixed(1),
    'Scientific name': scientificName,
    'Common name': commonName,
    'Confidence': confidence.toStringAsFixed(4),
    'File': fileName,
  };
}
