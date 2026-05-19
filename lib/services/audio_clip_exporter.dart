import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'audio_processor.dart';

class AudioClipExporter {
  /// Extracts a clip from [audioPath] between [startSec] and [endSec].
  /// Returns the path to the temporary WAV file containing the clip.
  static Future<String> extractClipAsWav(
      String audioPath, double startSec, double endSec) async {
    final result = await AudioProcessor.decodeSegment(audioPath, startSec, endSec);
    final sampleRate = result.sampleRate;

    final clipSamples = result.samples;
    
    if (clipSamples.isEmpty) {
      throw Exception('Invalid clip range');
    }
    
    // Convert float32 back to int16 for WAV export
    final int16List = Int16List(clipSamples.length);
    for (int i = 0; i < clipSamples.length; i++) {
      int16List[i] = (clipSamples[i] * 32767).clamp(-32768, 32767).toInt();
    }

    final byteData = ByteData.view(int16List.buffer);
    final pcmBytes = byteData.buffer.asUint8List();

    final wavBytes = _buildWavHeader(pcmBytes.length, sampleRate);
    final fullBytes = Uint8List(wavBytes.length + pcmBytes.length);
    fullBytes.setAll(0, wavBytes);
    fullBytes.setAll(wavBytes.length, pcmBytes);

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/clip_${DateTime.now().millisecondsSinceEpoch}.wav');
    await file.writeAsBytes(fullBytes);

    return file.path;
  }

  static Uint8List _buildWavHeader(int dataLength, int sampleRate) {
    final channels = 1;
    final byteRate = sampleRate * channels * 2; // 16-bit
    final blockAlign = channels * 2;

    final header = ByteData(44);
    
    // "RIFF"
    header.setUint8(0, 82);
    header.setUint8(1, 73);
    header.setUint8(2, 70);
    header.setUint8(3, 70);
    
    // Chunk size
    header.setUint32(4, 36 + dataLength, Endian.little);
    
    // "WAVE"
    header.setUint8(8, 87);
    header.setUint8(9, 65);
    header.setUint8(10, 86);
    header.setUint8(11, 69);
    
    // "fmt "
    header.setUint8(12, 102);
    header.setUint8(13, 109);
    header.setUint8(14, 116);
    header.setUint8(15, 32);
    
    // Subchunk1Size (16 for PCM)
    header.setUint32(16, 16, Endian.little);
    
    // AudioFormat (1 for PCM)
    header.setUint16(20, 1, Endian.little);
    
    // NumChannels
    header.setUint16(22, channels, Endian.little);
    
    // SampleRate
    header.setUint32(24, sampleRate, Endian.little);
    
    // ByteRate
    header.setUint32(28, byteRate, Endian.little);
    
    // BlockAlign
    header.setUint16(32, blockAlign, Endian.little);
    
    // BitsPerSample
    header.setUint16(34, 16, Endian.little);
    
    // "data"
    header.setUint8(36, 100);
    header.setUint8(37, 97);
    header.setUint8(38, 116);
    header.setUint8(39, 97);
    
    // Subchunk2Size
    header.setUint32(40, dataLength, Endian.little);
    
    return header.buffer.asUint8List();
  }
}
