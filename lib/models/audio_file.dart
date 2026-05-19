import 'dart:io';

enum AudioFileStatus { waiting, processing, done, error }

class AudioFile {
  final String path;
  final String name;
  final int sizeBytes;
  AudioFileStatus status;
  String? errorMessage;
  int detectionCount;
  double? durationSeconds;

  AudioFile({
    required this.path,
    required this.name,
    required this.sizeBytes,
    this.status = AudioFileStatus.waiting,
    this.errorMessage,
    this.detectionCount = 0,
    this.durationSeconds,
  });

  factory AudioFile.fromFile(File file) {
    return AudioFile(
      path: file.path,
      name: file.uri.pathSegments.last,
      sizeBytes: file.lengthSync(),
    );
  }

  static const supportedExtensions = [
    'wav', 'mp3', 'ogg', 'flac', 'm4a', 'aac', 'opus', 'wma', 'aiff', 'au'
  ];

  static bool isSupported(String path) {
    final ext = path.split('.').last.toLowerCase();
    return supportedExtensions.contains(ext);
  }

  AudioFile copyWith({
    AudioFileStatus? status,
    String? errorMessage,
    int? detectionCount,
    double? durationSeconds,
  }) {
    return AudioFile(
      path: path,
      name: name,
      sizeBytes: sizeBytes,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      detectionCount: detectionCount ?? this.detectionCount,
      durationSeconds: durationSeconds ?? this.durationSeconds,
    );
  }
}
