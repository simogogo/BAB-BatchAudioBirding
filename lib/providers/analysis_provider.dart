import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/analysis_result.dart';
import '../models/audio_file.dart';
import '../services/batch_analyzer.dart';

// ─── Analysis State ───────────────────────────────────────────────────────

class AnalysisState {
  final List<AudioFile> files;
  final Map<int, AnalysisResult> results;
  final bool running;
  final bool done;
  final int currentIndex;

  const AnalysisState({
    this.files = const [],
    this.results = const {},
    this.running = false,
    this.done = false,
    this.currentIndex = -1,
  });

  int get totalFiles => files.length;
  int get completedFiles =>
      files.where((f) => f.status == AudioFileStatus.done).length;
  int get totalDetections =>
      results.values.fold(0, (sum, r) => sum + r.detectionCount);
  double get totalAudioSeconds =>
      results.values.fold(0.0, (sum, r) => sum + r.durationSeconds);

  List<AnalysisResult> get allResults => results.values.toList()
    ..sort((a, b) => a.fileName.compareTo(b.fileName));

  AnalysisState copyWith({
    List<AudioFile>? files,
    Map<int, AnalysisResult>? results,
    bool? running,
    bool? done,
    int? currentIndex,
  }) {
    return AnalysisState(
      files: files ?? this.files,
      results: results ?? this.results,
      running: running ?? this.running,
      done: done ?? this.done,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }
}

// ─── Notifier ─────────────────────────────────────────────────────────────

class AnalysisNotifier extends Notifier<AnalysisState> {
  BatchAnalyzer? _currentAnalyzer;
  StreamSubscription? _subscription;

  @override
  AnalysisState build() {
    ref.onDispose(() => stopAnalysis());
    return const AnalysisState();
  }

  /// Load audio files from a directory path.
  Future<void> loadFolder(String folderPath) async {
    try {
      final dir = Directory(folderPath);
      if (!await dir.exists()) return;

      final entities = await dir.list().toList();
      final audioFiles = entities
          .whereType<File>()
          .where((f) => AudioFile.isSupported(f.path))
          .map((f) => AudioFile.fromFile(f))
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));

      state = AnalysisState(files: audioFiles);
    } catch (e) {
      rethrow;
    }
  }

  /// Load audio files from a list of paths.
  Future<void> loadFiles(List<String> paths,
      {void Function(int current, int total)? onProgress}) async {
    // Stop any ongoing analysis and reset state
    stopAnalysis();

    final List<AudioFile> audioFiles = [];
    final total = paths.length;

    for (int i = 0; i < total; i++) {
      final p = paths[i];
      if (AudioFile.isSupported(p)) {
        try {
          audioFiles.add(AudioFile.fromFile(File(p)));
        } catch (e) {
          // Skip files that can't be read
        }
      }
      onProgress?.call(i + 1, total);

      // Give UI a chance to breathe
      if (i % 10 == 0) {
        await Future.delayed(Duration.zero);
      }
    }

    audioFiles.sort((a, b) => a.name.compareTo(b.name));
    state = AnalysisState(files: audioFiles);
  }

  /// Remove a file from the selection.
  void removeFile(int index) {
    if (index < 0 || index >= state.files.length) return;

    final newFiles = List<AudioFile>.from(state.files)..removeAt(index);

    // Indices in results map would be shifted, so we just clear them
    // as removal is intended for the selection phase.
    state = state.copyWith(
      files: newFiles,
      results: {},
      done: false,
      currentIndex: -1,
    );
  }

  /// Start the batch analysis.
  void startAnalysis({
    required double threshold,
    required double overlapSeconds,
    required double sensitivity,
    required filterSettings,
    required List<String> labels,
  }) {
    if (state.files.isEmpty) return;

    // Force stop any existing process
    stopAnalysis();

    // Reset statuses
    final freshFiles = state.files
        .map((f) => f.copyWith(status: AudioFileStatus.waiting))
        .toList();
    state = state.copyWith(
      files: freshFiles,
      results: {},
      running: true,
      done: false,
      currentIndex: -1,
    );

    stopAnalysis();
    _currentAnalyzer = BatchAnalyzer();

    final stream = _currentAnalyzer!.analyze(
      files: freshFiles,
      filterSettings: filterSettings,
      threshold: threshold,
      overlapSeconds: overlapSeconds,
      sensitivity: sensitivity,
      labels: labels,
    );

    _subscription = stream.listen(
      _handleEvent,
      onError: (_) => state = state.copyWith(running: false, done: true),
      onDone: () => state = state.copyWith(running: false, done: true),
    );
  }

  void stopAnalysis() {
    _subscription?.cancel();
    _subscription = null;
    _currentAnalyzer?.stop();
    _currentAnalyzer = null;
    state = state.copyWith(running: false);
  }

  void _handleEvent(BatchEvent event) {
    switch (event) {
      case BatchFileStarted(:final index):
        _updateFile(index, AudioFileStatus.processing);
        state = state.copyWith(currentIndex: index);

      case BatchFileCompleted(:final index, :final result):
        _updateFile(index, AudioFileStatus.done,
            detections: result.detectionCount,
            duration: result.durationSeconds);
        final newResults = Map<int, AnalysisResult>.from(state.results)
          ..[index] = result;
        state = state.copyWith(results: newResults);

      case BatchFileError(:final index, :final error):
        _updateFile(index, AudioFileStatus.error, errorMessage: error);

      case BatchAllDone():
        state = state.copyWith(running: false, done: true);
    }
  }

  void _updateFile(
    int index,
    AudioFileStatus status, {
    int? detections,
    double? duration,
    String? errorMessage,
  }) {
    final files = List<AudioFile>.from(state.files);
    files[index] = files[index].copyWith(
      status: status,
      detectionCount: detections,
      durationSeconds: duration,
      errorMessage: errorMessage,
    );
    state = state.copyWith(files: files);
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────

final analysisProvider =
    NotifierProvider<AnalysisNotifier, AnalysisState>(AnalysisNotifier.new);
