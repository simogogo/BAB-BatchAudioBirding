import 'dart:math' as math;
import 'package:fftea/fftea.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/spectrogram_color_theme.dart';

// ─── SpectrogramData ─────────────────────────────────────────────────────────

class SpectrogramData {
  /// frames[i] == null means that region is not yet computed.
  final List<Uint8List?> frames;
  final double sampleRate;
  final int windowSize;
  final int hopSize;
  final double totalDuration;
  bool isComplete;

  SpectrogramData({
    required this.frames,
    required this.sampleRate,
    required this.windowSize,
    required this.hopSize,
    required this.totalDuration,
    this.isComplete = false,
  });

  int get frameCount => frames.length;

  int get completedFrameCount => frames.fold(0, (n, f) => n + (f != null ? 1 : 0));

  /// Pre-allocate a container for a file of known total duration.
  /// All frames start as null (not computed).
  factory SpectrogramData.empty({
    required double totalDuration,
    required double sampleRate,
    int windowSize = SpectrogramService.defaultWindowSize,
    int hopSize = SpectrogramService.defaultHopSize,
  }) {
    final totalSamples = (totalDuration * sampleRate).round();
    final expectedFrames = totalSamples > windowSize
        ? ((totalSamples - windowSize) ~/ hopSize) + 1
        : 0;
    return SpectrogramData(
      frames: List<Uint8List?>.filled(expectedFrames, null, growable: false),
      sampleRate: sampleRate,
      windowSize: windowSize,
      hopSize: hopSize,
      totalDuration: totalDuration,
    );
  }

  void addChunk(int startFrameIndex, List<Uint8List> chunkFrames) {
    for (int i = 0; i < chunkFrames.length; i++) {
      final idx = startFrameIndex + i;
      if (idx < frames.length) frames[idx] = chunkFrames[i];
    }
  }
}

// ─── Isolate params (using a simple List to stay compatible) ─────────────────

// Top-level function required by compute()
List<Uint8List> _computeFramesIsolate(List<Object> args) {
  final samples = args[0] as Float32List;
  final sampleRate = args[1] as double;
  final windowSize = args[2] as int;
  final hopSize = args[3] as int;
  return SpectrogramService.computeFrames(
    samples: samples,
    sampleRate: sampleRate,
    windowSize: windowSize,
    hopSize: hopSize,
  );
}

// ─── SpectrogramService ───────────────────────────────────────────────────────

class SpectrogramService {
  static const int defaultWindowSize = 1024;
  static const int defaultHopSize = 512;
  static const double _maxFreq = 12000.0;
  static const int chunkSeconds = 30;

  static final List<Paint> _grayscalePalette = List.generate(256, (i) {
    final double t = i / 255.0;
    // Apply gamma curve to compress ambient noise and make background beautifully clean and white
    final double gamma = math.pow(t, 2.2).toDouble();
    final int gray = (255 * (1.0 - gamma)).round().clamp(0, 255);
    return Paint()..color = Color.fromARGB(255, gray, gray, gray);
  });

  static final List<Paint> _coloredPalette = List.generate(256, (i) {
    final double t = i / 255.0;

    // Exact color stops matching the dBFS scale in the user's reference image:
    // t = 0.00 (-120 dBFS) -> Pure Black (#000000) for clean background and noise floor
    // t = 0.16 (-100 dBFS) -> Deep Navy Blue (#000044)
    // t = 0.25 (-90 dBFS)  -> Indigo / Dark Purple (#1e0059)
    // t = 0.33 (-80 dBFS)  -> Deep Violet (#55006a)
    // t = 0.42 (-70 dBFS)  -> Dark Magenta (#8b0062)
    // t = 0.50 (-60 dBFS)  -> Vibrant Red-Pink (#c20042)
    // t = 0.58 (-50 dBFS)  -> Pure Red (#ff0000)
    // t = 0.67 (-40 dBFS)  -> Vibrant Orange (#ff6600)
    // t = 0.75 (-30 dBFS)  -> Golden Orange (#ffaa00)
    // t = 0.83 (-20 dBFS)  -> Gold / Amber (#ffd500)
    // t = 0.92 (-10 dBFS)  -> Bright Yellow (#ffff44)
    // t = 1.00 (0 dBFS)    -> Pure White (#ffffff) for peak intensities

    final List<double> stops = [
      0.0,   // -120 dBFS
      0.16,  // -100 dBFS
      0.25,  // -90 dBFS
      0.33,  // -80 dBFS
      0.42,  // -70 dBFS
      0.50,  // -60 dBFS
      0.58,  // -50 dBFS
      0.67,  // -40 dBFS
      0.75,  // -30 dBFS
      0.83,  // -20 dBFS
      0.92,  // -10 dBFS
      1.0,   // 0 dBFS
    ];

    final List<Color> colors = [
      const Color(0xFF000000), // -120 dBFS
      const Color(0xFF000044), // -100 dBFS
      const Color(0xFF1E0059), // -90 dBFS
      const Color(0xFF55006A), // -80 dBFS
      const Color(0xFF8B0062), // -70 dBFS
      const Color(0xFFC20042), // -60 dBFS
      const Color(0xFFFF0000), // -50 dBFS
      const Color(0xFFFF6600), // -40 dBFS
      const Color(0xFFFFAA00), // -30 dBFS
      const Color(0xFFFFD500), // -20 dBFS
      const Color(0xFFFFFF44), // -10 dBFS
      const Color(0xFFFFFFFF), // 0 dBFS
    ];

    Color color = colors.first;
    for (int idx = 0; idx < stops.length - 1; idx++) {
      if (t >= stops[idx] && t <= stops[idx + 1]) {
        final double range = stops[idx + 1] - stops[idx];
        final double localT = range == 0.0 ? 0.0 : (t - stops[idx]) / range;
        color = Color.lerp(colors[idx], colors[idx + 1], localT)!;
        break;
      }
    }

    return Paint()..color = color;
  });

  static List<Paint> getPalette(SpectrogramColorTheme theme) {
    return theme == SpectrogramColorTheme.grayscale ? _grayscalePalette : _coloredPalette;
  }

  /// Pure CPU-bound FFT computation. Safe to call inside an isolate.
  static List<Uint8List> computeFrames({
    required Float32List samples,
    required double sampleRate,
    int windowSize = defaultWindowSize,
    int hopSize = defaultHopSize,
  }) {
    final fft = FFT(windowSize);
    final window = Window.hanning(windowSize);
    final nyquist = sampleRate / 2;
    final maxBin = ((_maxFreq / nyquist) * (windowSize / 2)).floor();
    const double minDb = -120.0;
    const double maxDb = 0.0;

    final frames = <Uint8List>[];
    // Scaling factor for Hanning windowed real FFT:
    // Hanning window coherent gain is 0.5, so single-sided FFT amplitude is A * (windowSize / 4.0).
    // Dividing by (windowSize / 4.0) calibrates peak magnitude to 1.0 (0 dBFS) for a full-scale sine wave.
    final double fftScale = windowSize / 4.0;

    for (int i = 0; i <= samples.length - windowSize; i += hopSize) {
      final chunk = Float32List(windowSize);
      for (int j = 0; j < windowSize; j++) {
        chunk[j] = samples[i + j] * window[j];
      }
      final result = fft.realFft(chunk);
      final magnitudes = Uint8List(maxBin);
      for (int j = 0; j < maxBin; j++) {
        final c = result[j];
        final mag = math.sqrt(c.x * c.x + c.y * c.y);
        final normalizedMag = mag / fftScale;
        final db = 20 * math.log(normalizedMag + 1e-6) / math.ln10;
        magnitudes[j] =
            (((db - minDb) / (maxDb - minDb)) * 255).clamp(0, 255).round();
      }
      frames.add(magnitudes);
    }
    return frames;
  }

  /// Generate spectrogram progressively.
  ///
  /// Processes [chunkSeconds] of audio at a time in a background isolate.
  /// [onChunkReady] is called on the main isolate after each chunk completes.
  /// [isCancelled] allows early termination (e.g., when screen is disposed).
  static Future<void> generateProgressive({
    required Float32List samples,
    required double sampleRate,
    required SpectrogramData data,
    required VoidCallback onChunkReady,
    bool Function()? isCancelled,
  }) async {
    const windowSize = defaultWindowSize;
    const hopSize = defaultHopSize;
    final chunkSamples = (chunkSeconds * sampleRate).round();
    int sampleOffset = 0;
    int frameIndex = 0;

    while (sampleOffset < samples.length) {
      if (isCancelled?.call() == true) return;

      final end = (sampleOffset + chunkSamples).clamp(0, samples.length);
      // Float32List.sublist creates an independent copy, safe to send to isolate
      final slice = samples.sublist(sampleOffset, end);

      final frames = await compute(
        _computeFramesIsolate,
        <Object>[slice, sampleRate, windowSize, hopSize],
      );

      if (isCancelled?.call() == true) return;

      data.addChunk(frameIndex, frames);
      frameIndex += frames.length;
      sampleOffset += chunkSamples;
      onChunkReady();
    }

    data.isComplete = true;
    onChunkReady();
  }
}
