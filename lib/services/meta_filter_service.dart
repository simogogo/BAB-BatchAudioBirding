
import 'dart:math' as math;
import 'dart:developer' as dev;
import 'dart:typed_data';

import 'package:tflite_flutter/tflite_flutter.dart';

import '../models/filter_settings.dart';

/// Applies geographic (meta-model) or species-list filtering
/// to raw BirdNET output scores.
class MetaFilterService {
  static final MetaFilterService _instance = MetaFilterService._();
  factory MetaFilterService() => _instance;
  MetaFilterService._();

  Interpreter? _metaInterpreter;
  bool _ready = false;
  Future<void>? _initFuture;

  // Cache fields for geographic scores
  double? _cachedLat;
  double? _cachedLon;
  int? _cachedWeek;
  Float32List? _cachedScores;

  bool get isReady => _ready;

  Future<void> init(String metaModelPath) async {
    if (_ready) return;
    _initFuture ??= _doInit(metaModelPath);
    return _initFuture;
  }

  Future<void> _doInit(String metaModelPath) async {
    try {
      dev.log('MetaFilterService: Starting initialization of geographic meta-model...');
      _metaInterpreter = await Interpreter.fromAsset(
        metaModelPath,
        options: InterpreterOptions()..threads = 1,
      );
      _ready = true;
      dev.log('MetaFilterService: Geographic meta-model loaded successfully.');
    } catch (e, stack) {
      dev.log('MetaFilterService: Failed to load geographic meta-model', error: e, stackTrace: stack);
      _ready = false;
      _initFuture = null; // Reset to allow retry on next attempt
    }
  }

  void dispose() {
    _metaInterpreter?.close();
    _ready = false;
    _initFuture = null;
    _clearCache();
  }

  void _clearCache() {
    _cachedLat = null;
    _cachedLon = null;
    _cachedWeek = null;
    _cachedScores = null;
  }

  /// Compute a species mask based on [settings].
  /// Returns null if no filtering should be applied.
  /// Returns Float32List of length [numSpecies] with values in [0.0, 1.0].
  Future<Float32List?> computeMask({
    required FilterSettings settings,
    required int numSpecies,
    required List<String> labels,
  }) async {
    switch (settings.mode) {
      case FilterMode.none:
        return null;

      case FilterMode.geographic:
        if (!settings.isGeoValid || !_ready) return null;
        return _computeGeoMask(
          lat: settings.latitude!,
          lon: settings.longitude!,
          week: settings.week!,
          numSpecies: numSpecies,
          threshold: settings.locationThreshold,
        );

      case FilterMode.speciesList:
        if (settings.speciesList.isEmpty) return null;
        return _computeListMask(
          allowedSpecies: settings.speciesList,
          labels: labels,
          numSpecies: numSpecies,
        );
    }
  }

  // ─── Geographic filter via meta-model ──────────────────────────────────────

  Float32List _computeGeoMask({
    required double lat,
    required double lon,
    required int week,
    required int numSpecies,
    required double threshold,
  }) {
    final scores = _getRawGeoScoresDirect(
      lat: lat,
      lon: lon,
      week: week,
      numSpecies: numSpecies,
    );

    final mask = Float32List(numSpecies);
    int allowedCount = 0;
    for (int i = 0; i < numSpecies; i++) {
      if (scores[i] >= threshold) {
        mask[i] = 1.0;
        allowedCount++;
      } else {
        mask[i] = 0.0;
      }
    }
    dev.log('MetaFilterService: Mask computed. Allowed $allowedCount / $numSpecies species at threshold $threshold.');
    return mask;
  }

  /// Get the raw geographic probability scores for all species.
  /// Used by the allowed species preview modal to dynamically filter by threshold.
  Future<Float32List?> getRawGeoScores({
    required double lat,
    required double lon,
    required int week,
    required int numSpecies,
  }) async {
    if (!_ready) return null;
    return _getRawGeoScoresDirect(
      lat: lat,
      lon: lon,
      week: week,
      numSpecies: numSpecies,
    );
  }

  Float32List _getRawGeoScoresDirect({
    required double lat,
    required double lon,
    required int week,
    required int numSpecies,
  }) {
    if (lat == _cachedLat &&
        lon == _cachedLon &&
        week == _cachedWeek &&
        _cachedScores != null &&
        _cachedScores!.length == numSpecies) {
      dev.log('MetaFilterService: Returning cached geo scores for Lat: $lat, Lon: $lon, Week: $week');
      return _cachedScores!;
    }

    if (_metaInterpreter == null) {
      dev.log('MetaFilterService: _metaInterpreter is null during raw scores retrieval.');
      return Float32List(numSpecies);
    }

    // Dynamically retrieve model's actual output size to handle mismatches gracefully
    final outputTensors = _metaInterpreter!.getOutputTensors();
    final modelOutputSize = outputTensors.isNotEmpty && outputTensors[0].shape.length > 1
        ? outputTensors[0].shape[1]
        : numSpecies;

    // Dynamically retrieve model's actual input shape size to support both 3-input (V2.4 MData) and 6-input models
    final inputTensors = _metaInterpreter!.getInputTensors();
    final modelInputShape = inputTensors.isNotEmpty ? inputTensors[0].shape : [1, 3];
    final inputSize = modelInputShape.length > 1 ? modelInputShape[1] : 3;

    final Float32List input;
    if (inputSize == 6) {
      input = _encodeMetaInput(lat, lon, week);
    } else {
      input = Float32List.fromList([lat, lon, week.toDouble()]);
    }

    // Use a standard nested List<double> representing [1, modelOutputSize]
    final output = [List<double>.filled(modelOutputSize, 0.0)];

    try {
      _metaInterpreter!.run(
        input.reshape([1, inputSize]),
        output,
      );
      
      final rawOutput = Float32List(numSpecies);
      for (int i = 0; i < numSpecies; i++) {
        if (i < modelOutputSize) {
          // The geographic meta-model outputs are already raw probability scores in [0.0, 1.0].
          // No sigmoid scaling is needed (applying it squashes all values into [0.5, 0.73]).
          rawOutput[i] = output[0][i].clamp(0.0, 1.0);
        } else {
          // If the model does not have geographical predictions for this index (e.g., non-avian classes),
          // exclude them (0.0) as requested by the user.
          rawOutput[i] = 0.0;
        }
      }
      
      // Update cache
      _cachedLat = lat;
      _cachedLon = lon;
      _cachedWeek = week;
      _cachedScores = rawOutput;

      dev.log('MetaFilterService: Raw scores computed successfully. Model input size: $inputSize, output size: $modelOutputSize, requested species size: $numSpecies. First 5 scores: ${rawOutput.sublist(0, math.min(5, numSpecies))}');
      return rawOutput;
    } catch (e, stack) {
      dev.log('MetaFilterService: Error during raw geographic scores retrieval (modelInputSize: $inputSize, modelOutputSize: $modelOutputSize, numSpecies: $numSpecies)', error: e, stackTrace: stack);
      return Float32List(numSpecies);
    }
  }

  /// Encode lat/lon/week as sine/cosine circular embeddings.
  /// This matches the BirdNET-Analyzer meta-model input format.
  static Float32List _encodeMetaInput(double lat, double lon, int week) {
    final latRad = lat * math.pi / 180.0;
    final lonRad = lon * math.pi / 180.0;
    final weekAngle = (week - 1) / 48.0 * 2 * math.pi;
    return Float32List.fromList([
      math.sin(latRad),
      math.cos(latRad),
      math.sin(lonRad),
      math.cos(lonRad),
      math.sin(weekAngle),
      math.cos(weekAngle),
    ]);
  }

  // ─── Species list filter ───────────────────────────────────────────────────

  static Float32List _computeListMask({
    required List<String> allowedSpecies,
    required List<String> labels,
    required int numSpecies,
  }) {
    final mask = Float32List(numSpecies);
    
    // Process user list to extract scientific names and common names
    final allowedScientific = <String>{};
    final allowedFull = <String>{};
    
    for (var s in allowedSpecies) {
      final cleaned = s.toLowerCase().trim();
      if (cleaned.isEmpty) continue;
      
      allowedFull.add(cleaned);
      if (cleaned.contains('_')) {
        allowedScientific.add(cleaned.split('_')[0].trim());
      } else {
        // If no underscore, assume it could be a scientific name
        allowedScientific.add(cleaned);
      }
    }

    int matchedCount = 0;

    for (int i = 0; i < labels.length && i < numSpecies; i++) {
      final labelLower = labels[i].toLowerCase();
      final parts = labels[i].split('_');
      
      // Scientific name from model label (part before _)
      final modelScientific = parts.isNotEmpty ? parts[0].toLowerCase().trim() : labelLower;
      // Common name from model label (part after _)
      final modelCommon = parts.length > 1 ? parts.sublist(1).join(' ').toLowerCase().trim() : '';

      // Match if:
      // 1. Full label match (exact same string)
      // 2. Scientific name match (part before _)
      // 3. Common name match
      if (allowedFull.contains(labelLower.trim()) ||
          allowedScientific.contains(modelScientific) ||
          allowedFull.contains(modelCommon)) {
        mask[i] = 1.0;
        matchedCount++;
      }
    }
    
    dev.log('MetaFilterService: Species list filter applied. Matched $matchedCount out of ${labels.length} labels.');
    return mask;
  }
}
