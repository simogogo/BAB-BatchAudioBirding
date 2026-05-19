import 'dart:async';
import 'dart:developer' as dev;

import '../models/analysis_result.dart';
import '../models/audio_file.dart';
import 'audio_processor.dart';
import 'birdnet_service.dart';

import '../models/filter_settings.dart';
import 'meta_filter_service.dart';

// ─── Events emitted to UI ─────────────────────────────────────────────────────

sealed class BatchEvent {}

class BatchFileStarted extends BatchEvent {
  final int index;
  BatchFileStarted(this.index);
}

class BatchFileCompleted extends BatchEvent {
  final int index;
  final AnalysisResult result;
  BatchFileCompleted(this.index, this.result);
}

class BatchFileError extends BatchEvent {
  final int index;
  final String error;
  BatchFileError(this.index, this.error);
}

class BatchAllDone extends BatchEvent {
  final List<AnalysisResult> results;
  BatchAllDone(this.results);
}

// ─── BatchAnalyzer ────────────────────────────────────────────────────────────

class BatchAnalyzer {
  BatchAnalyzer();

  StreamController<BatchEvent>? _controller;
  bool _running = false;
  bool _stopRequested = false;

  bool get isRunning => _running;

  /// Start batch analysis.
  /// Emits [BatchEvent]s on the returned stream.
  Stream<BatchEvent> analyze({
    required List<AudioFile> files,
    required FilterSettings filterSettings,
    required double threshold,
    required double overlapSeconds,
    required double sensitivity,
    required List<String> labels,
  }) {
    if (_running) {
      throw StateError('Batch analysis already in progress');
    }

    _controller = StreamController<BatchEvent>.broadcast();
    _running = true;
    _stopRequested = false;

    _run(
      files: files,
      filterSettings: filterSettings,
      threshold: threshold,
      overlapSeconds: overlapSeconds,
      sensitivity: sensitivity,
      labels: labels,
    );

    return _controller!.stream;
  }

  void stop() => _stopRequested = true;

  Future<void> _run({
    required List<AudioFile> files,
    required FilterSettings filterSettings,
    required double threshold,
    required double overlapSeconds,
    required double sensitivity,
    required List<String> labels,
  }) async {
    final results = <AnalysisResult>[];
    final birdnet = BirdnetService();
    final metaFilter = MetaFilterService();

    // Pre-compute species mask (same for all files in this batch)
    final mask = await metaFilter.computeMask(
      settings: filterSettings,
      numSpecies: labels.length,
      labels: labels,
    );

    for (int i = 0; i < files.length; i++) {
      if (_stopRequested) break;

      _emit(BatchFileStarted(i));

      final file = files[i];
      dev.log('BatchAnalyzer: Analyzing file $i/${files.length}: ${file.name}');
      try {
        // 1. Decode audio
        final audio = await AudioProcessor.decodeFile(file.path);
        if (_stopRequested) break;

        // 2. Run inference
        final detections = await birdnet.analyzeAudio(
          pcmMono48k: audio.samples,
          threshold: threshold,
          overlapSeconds: overlapSeconds,
          sensitivity: sensitivity,
          metaScores: mask,
        );
        if (_stopRequested) break;

        // 3. Sort by start time
        detections.sort((a, b) => a.startSeconds.compareTo(b.startSeconds));

        final result = AnalysisResult(
          filePath: file.path,
          fileName: file.name,
          detections: detections,
          durationSeconds: audio.durationSeconds,
          analyzedAt: DateTime.now(),
        );

        results.add(result);
        dev.log('BatchAnalyzer: Completed ${file.name} - ${result.detectionCount} detections');
        _emit(BatchFileCompleted(i, result));
      } catch (e) {
        final errorMsg = e is AudioProcessorException ? e.message : e.toString();
        dev.log('BatchAnalyzer: Error analyzing ${file.name}: $errorMsg');
        _emit(BatchFileError(i, errorMsg));
      }
    }

    if (!_stopRequested) {
      _emit(BatchAllDone(results));
    }
    _controller?.close();
    _running = false;
  }

  void _emit(BatchEvent event) {
    if (_controller?.isClosed == false) {
      _controller!.add(event);
    }
  }
}
