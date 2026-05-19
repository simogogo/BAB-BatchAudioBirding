import 'dart:async';
import 'dart:developer' as dev;
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:tflite_flutter/tflite_flutter.dart';

import '../models/detection.dart';

// ─── Constants ───────────────────────────────────────────────────────────────

const int _kSampleRate = 48000;
const int _kChunkSamples = 144000; // 3s * 48000
const double _kChunkDurationSec = 3.0;

// ─── BirdnetService ───────────────────────────────────────────────────────────

/// Loads the BirdNET TFLite model and runs inference in an isolate.
class BirdnetService {
  static final BirdnetService _instance = BirdnetService._();
  factory BirdnetService() => _instance;
  BirdnetService._();

  IsolateInterpreter? _interpreter;
  Interpreter? _baseInterpreter;
  List<String> _labels = [];
  bool _ready = false;

  bool get isReady => _ready;

  Future<void> init({
    required String modelPath,
    required List<String> labels,
  }) async {
    if (_ready) return;

    _labels = labels;

    // Load interpreter in background isolate
    _baseInterpreter = await Interpreter.fromAsset(
      modelPath,
      options: InterpreterOptions()..threads = 2,
    );
    _interpreter =
        await IsolateInterpreter.create(address: _baseInterpreter!.address);
    _ready = true;
    dev.log('BirdnetService: Initialized with ${_labels.length} labels');
  }

  void dispose() {
    _interpreter?.close();
    _baseInterpreter?.close();
    _ready = false;
  }
  /// Run inference on a single 3-second chunk.
  /// Returns raw confidence scores indexed by species.
  Future<Float32List> inferChunk(Float32List chunk) async {
    assert(_ready, 'BirdnetService not initialized');
    
    // Input shape: [1, 144000], Output shape: [1, numSpecies]
    final numSpecies = _labels.length;
    
    // Use a standard nested List<double> for output to be safe across isolates
    final output = [List<double>.filled(numSpecies, 0.0)];
    
    await _interpreter!.run(
      chunk.reshape([1, _kChunkSamples]),
      output,
    );
    
    return Float32List.fromList(output[0]);
  }

  /// Full analysis of a PCM audio buffer (arbitrary length).
  /// Returns list of detections above [threshold].
  Future<List<Detection>> analyzeAudio({
    required Float32List pcmMono48k,
    required double threshold,
    required double overlapSeconds,
    required double sensitivity,
    Float32List? metaScores, // pre-computed meta-model filter (optional)
  }) async {
    assert(_ready);
    final stepSamples = (_kChunkSamples -
            (overlapSeconds * _kSampleRate).round())
        .clamp(1, _kChunkSamples);

    dev.log('BirdnetService: Starting analysis (threshold: $threshold, overlap: $overlapSeconds, sensitivity: $sensitivity)');
    final detections = <Detection>[];
    int offset = 0;
    double startSec = 0.0;

    while (offset < pcmMono48k.length) {
      // Extract chunk, zero-pad if shorter than 3s
      final end = (offset + _kChunkSamples).clamp(0, pcmMono48k.length);
      final chunk = Float32List(_kChunkSamples);
      chunk.setRange(0, end - offset, pcmMono48k, offset);

      final rawScores = await inferChunk(chunk);
      // Apply Sigmoid activation to raw scores scaled by sensitivity
      final scores = Float32List(rawScores.length);
      for (int i = 0; i < rawScores.length; i++) {
        scores[i] = 1.0 / (1.0 + math.exp(-rawScores[i] * sensitivity));
      }

      final endSec = startSec + _kChunkDurationSec;

      // Apply meta-model filter if provided
      final filtered = (metaScores != null && metaScores.length == scores.length)
          ? Float32List.fromList(
              List.generate(scores.length, (i) => scores[i] * metaScores[i]),
            )
          : scores;

      // Collect detections above threshold
      for (int i = 0; i < filtered.length && i < _labels.length; i++) {
        if (filtered[i] >= threshold) {
          final parts = _labels[i].split('_');
          final scientific = parts.isNotEmpty ? parts[0] : _labels[i];
          final common = parts.length > 1 ? parts.sublist(1).join(' ') : scientific;
          detections.add(Detection(
            scientificName: scientific,
            commonName: common,
            confidence: filtered[i],
            startSeconds: startSec,
            endSeconds: endSec,
          ));
        }
      }

      if (end >= pcmMono48k.length) break;
      offset += stepSamples;
      startSec += stepSamples / _kSampleRate;
    }

    dev.log('BirdnetService: Analysis complete, found ${detections.length} detections');
    return detections;
  }

}
