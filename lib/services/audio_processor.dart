import 'dart:io';
import 'dart:developer' as dev;
import 'dart:typed_data';

import 'package:audio_decoder/audio_decoder.dart';

const int _kTargetSampleRate = 48000;

/// Decodes an audio file to a mono Float32 PCM buffer at 48kHz.
class AudioProcessor {
  /// Returns [Float32List] of mono 48kHz PCM samples.
  /// Throws [AudioProcessorException] on failure.
  static Future<AudioProcessorResult> decodeFile(String path) async {
    final file = File(path);
    if (!file.existsSync()) {
      throw AudioProcessorException('File not found: $path');
    }

    try {
      // audio_decoder convert to wav and extract samples
      final wavPath = await AudioDecoder.convertToWav(
        path,
        '${path}_temp.wav',
        sampleRate: _kTargetSampleRate,
        channels: 1, // mono
      );
      dev.log('AudioProcessor: Converted to temp WAV: $wavPath');
      
      final wavFile = File(wavPath);
      final bytes = await wavFile.readAsBytes();
      
      // Find 'data' chunk offset
      int dataOffset = -1;
      for (int i = 0; i < bytes.length - 8; i++) {
        if (bytes[i] == 100 && // 'd'
            bytes[i + 1] == 97 && // 'a'
            bytes[i + 2] == 116 && // 't'
            bytes[i + 3] == 97) { // 'a'
          dataOffset = i + 8;
          break;
        }
      }

      if (dataOffset == -1) {
        throw AudioProcessorException('Invalid WAV: data chunk not found');
      }
      dev.log('AudioProcessor: Found data chunk at offset $dataOffset');

      final pcmBytes = bytes.sublist(dataOffset);
      final int16List = Int16List.view(
        pcmBytes.buffer,
        pcmBytes.offsetInBytes,
        pcmBytes.lengthInBytes ~/ 2,
      );
      
      if (int16List.isEmpty) {
        throw AudioProcessorException('Failed to decode audio: empty result');
      }

      // Convert int16 PCM to float32 normalized [-1.0, 1.0]
      final float32 = _int16ToFloat32(int16List);
      dev.log('AudioProcessor: Decoded ${float32.length} samples (${(float32.length / _kTargetSampleRate).toStringAsFixed(2)}s)');
      
      // Cleanup temp file
      try {
        if (wavFile.existsSync()) wavFile.deleteSync();
      } catch (_) {}

      final durationSeconds = float32.length / _kTargetSampleRate;

      return AudioProcessorResult(
        samples: float32,
        durationSeconds: durationSeconds,
        sampleRate: _kTargetSampleRate,
      );
    } catch (e) {
      if (e is AudioProcessorException) rethrow;
      throw AudioProcessorException('Decode error: $e');
    }
  }

  /// Decodes only a specific segment of the audio file to avoid loading the whole file into RAM.
  static Future<AudioProcessorResult> decodeSegment(String path, double startSec, double endSec) async {
    final file = File(path);
    if (!file.existsSync()) {
      throw AudioProcessorException('File not found: $path');
    }

    try {
      final wavPath = await AudioDecoder.convertToWav(
        path,
        '${path}_temp_seg.wav',
        sampleRate: _kTargetSampleRate,
        channels: 1, // mono
      );
      
      final wavFile = File(wavPath);
      final raf = await wavFile.open(mode: FileMode.read);
      
      try {
        final length = await raf.length();
        if (length < 44) throw AudioProcessorException('WAV file too short');
        
        await raf.setPosition(0);
        final headerBuffer = await raf.read(100);
        int dataOffset = -1;
        int dataSize = 0;
        
        for (int i = 0; i < headerBuffer.length - 8; i++) {
          if (headerBuffer[i] == 100 && // 'd'
              headerBuffer[i + 1] == 97 && // 'a'
              headerBuffer[i + 2] == 116 && // 't'
              headerBuffer[i + 3] == 97) { // 'a'
            dataOffset = i + 8;
            final bd = ByteData.view(headerBuffer.buffer, headerBuffer.offsetInBytes, headerBuffer.lengthInBytes);
            dataSize = bd.getUint32(i + 4, Endian.little);
            break;
          }
        }

        if (dataOffset == -1) {
          throw AudioProcessorException('Invalid WAV: data chunk not found');
        }

        int startByte = (startSec * _kTargetSampleRate).floor() * 2;
        int endByte = (endSec * _kTargetSampleRate).ceil() * 2;
        
        startByte = startByte.clamp(0, dataSize);
        endByte = endByte.clamp(0, dataSize);

        final readLength = endByte - startByte;
        if (readLength <= 0) {
            return AudioProcessorResult(
              samples: Float32List(0),
              durationSeconds: 0,
              sampleRate: _kTargetSampleRate,
            );
        }

        await raf.setPosition(dataOffset + startByte);
        final pcmBytes = await raf.read(readLength);

        final int16List = Int16List.view(
          pcmBytes.buffer,
          pcmBytes.offsetInBytes,
          pcmBytes.lengthInBytes ~/ 2,
        );

        final float32 = _int16ToFloat32(int16List);

        return AudioProcessorResult(
          samples: float32,
          durationSeconds: float32.length / _kTargetSampleRate,
          sampleRate: _kTargetSampleRate,
        );
      } finally {
        await raf.close();
        try {
          if (wavFile.existsSync()) wavFile.deleteSync();
        } catch (_) {}
      }
    } catch (e) {
      if (e is AudioProcessorException) rethrow;
      throw AudioProcessorException('Decode error: $e');
    }
  }

  /// Converts int16 PCM samples to float32 in range [-1.0, 1.0]
  static Float32List _int16ToFloat32(Int16List int16) {
    final result = Float32List(int16.length);
    const scale = 1.0 / 32768.0;
    for (int i = 0; i < int16.length; i++) {
      result[i] = int16[i] * scale;
    }
    return result;
  }
}

class AudioProcessorResult {
  final Float32List samples;
  final double durationSeconds;
  final int sampleRate;

  const AudioProcessorResult({
    required this.samples,
    required this.durationSeconds,
    required this.sampleRate,
  });
}

class AudioProcessorException implements Exception {
  final String message;
  AudioProcessorException(this.message);

  @override
  String toString() => 'AudioProcessorException: $message';
}
