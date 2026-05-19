import 'dart:io';
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';

import '../l10n/app_localizations.dart';
import '../models/analysis_result.dart';
import '../models/detection.dart';
import '../services/audio_clip_exporter.dart';
import '../services/audio_processor.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/spectrogram_color_theme.dart';
import '../providers/settings_provider.dart';
import '../services/spectrogram_service.dart';

class DetectionDetailModal extends ConsumerStatefulWidget {
  final Detection detection;
  final AnalysisResult result;

  const DetectionDetailModal({
    super.key,
    required this.detection,
    required this.result,
  });

  @override
  ConsumerState<DetectionDetailModal> createState() => _DetectionDetailModalState();
}

class _DetectionDetailModalState extends ConsumerState<DetectionDetailModal> {
  final _audioPlayer = AudioPlayer();
  SpectrogramData? _spectrogramData;
  bool _isLoading = true;
  String? _error;

  double _clipStart = 0;
  double _clipEnd = 0;
  double _clipDuration = 0;

  bool _isPlaying = false;
  bool _isLooping = false;
  bool _isSeeking = false;
  final _positionNotifier = ValueNotifier<Duration>(Duration.zero);
  String? _spectrogramImagePath;

  @override
  void initState() {
    super.initState();
    _initClip();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _positionNotifier.dispose();
    if (_spectrogramImagePath != null) {
      try {
        final file = File(_spectrogramImagePath!);
        if (file.existsSync()) {
          file.deleteSync();
        }
      } catch (_) {}
    }
    super.dispose();
  }

  Future<void> _initClip() async {
    try {
      final totalDur = widget.result.durationSeconds;
      _clipStart = math.max(0.0, widget.detection.startSeconds - 3.0);
      _clipEnd = math.min(totalDur, widget.detection.endSeconds + 3.0);
      
      if (_clipEnd <= _clipStart) {
        _clipEnd = _clipStart + 0.1; // Ensure valid slider bounds
      }
      
      _clipDuration = _clipEnd - _clipStart;

      // Decode only the 9-second segment to avoid loading the whole file into RAM
      final decoded = await AudioProcessor.decodeSegment(widget.result.filePath, _clipStart, _clipEnd);
      
      if (!mounted) return;

      final clipSamples = decoded.samples;

      _spectrogramData = SpectrogramData.empty(
        totalDuration: decoded.durationSeconds,
        sampleRate: decoded.sampleRate.toDouble(),
      );

      // Generate spectrogram synchronously (it's short, ~9s)
      final frames = SpectrogramService.computeFrames(
        samples: clipSamples,
        sampleRate: decoded.sampleRate.toDouble(),
      );

      _spectrogramData!.addChunk(0, frames);
      _spectrogramData!.isComplete = true;

      final theme = ref.read(settingsProvider).valueOrNull?.spectrogramTheme ?? SpectrogramColorTheme.colored;

      // Generate static PNG in high resolution for butter-smooth rendering
      _spectrogramImagePath = await _generateSpectrogramImage(
        specData: _spectrogramData!,
        width: _clipDuration * 160.0,
        height: 480.0,
        theme: theme,
      );

      // Extract the 9-second clip to a temporary WAV file
      // This completely avoids loading/seeking inside the original massive file,
      // which prevents Android MediaServer deadlocks and crashes.
      final clipWavPath = await AudioClipExporter.extractClipAsWav(
        widget.result.filePath,
        _clipStart,
        _clipEnd,
      );

      // Setup audio player with the tiny temporary file
      await _audioPlayer.setSourceDeviceFile(clipWavPath);
      await _audioPlayer.setReleaseMode(_isLooping ? ReleaseMode.loop : ReleaseMode.stop);

      _audioPlayer.onPlayerStateChanged.listen((s) {
        if (mounted) setState(() => _isPlaying = s == PlayerState.playing);
      });

      _audioPlayer.onPlayerComplete.listen((_) async {
        if (mounted) {
          setState(() {
            _isPlaying = false;
            _positionNotifier.value = Duration.zero;
          });
          try {
            await _audioPlayer.seek(Duration.zero);
          } catch (_) {}
        }
      });

      _audioPlayer.onPositionChanged.listen((p) {
        if (!mounted || _isSeeking) return;
        _positionNotifier.value = p;
      });

      setState(() {
        _isLoading = false;
        _positionNotifier.value = Duration.zero;
      });
    } catch (e) {
      if (mounted) setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _togglePlay() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      if (_positionNotifier.value.inMilliseconds >= (_clipDuration * 1000).toInt()) {
        await _audioPlayer.seek(Duration.zero);
      }
      await _audioPlayer.resume();
    }
  }

  Future<void> _exportAudio() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final path = await AudioClipExporter.extractClipAsWav(
        widget.result.filePath,
        _clipStart,
        _clipEnd,
      );

      final cleanCommonName = widget.detection.commonName.replaceAll(RegExp(r'[^\w\s\-]'), '_');
      final defaultName = '${cleanCommonName}_clip_${_clipStart.toStringAsFixed(1)}-${_clipEnd.toStringAsFixed(1)}.wav';

      final bytes = await File(path).readAsBytes();
      final String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Audio Clip',
        fileName: defaultName,
        bytes: bytes,
        type: FileType.any,
      );

      if (outputFile != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.audioExportSuccess)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.audioExportError}: $e')),
        );
      }
    }
  }

  Future<void> _exportSpectrogram() async {
    if (_spectrogramImagePath == null) return;
    final l10n = AppLocalizations.of(context)!;
    try {
      final cleanCommonName = widget.detection.commonName.replaceAll(RegExp(r'[^\w\s\-]'), '_');
      final defaultName = '${cleanCommonName}_spectrogram.png';

      final bytes = await File(_spectrogramImagePath!).readAsBytes();
      final String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: 'Save Spectrogram',
        fileName: defaultName,
        bytes: bytes,
        type: FileType.any,
      );

      if (outputFile != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.spectrogramExportSuccess)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.spectrogramExportError}: $e')),
        );
      }
    }
  }

  Future<String> _generateSpectrogramImage({
    required SpectrogramData specData,
    required double width,
    required double height,
    required SpectrogramColorTheme theme,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final palette = SpectrogramService.getPalette(theme);
    final bgPaintColor = palette[0].color;
    final isLight = ThemeData.estimateBrightnessForColor(bgPaintColor) == Brightness.light;

    final Color canvasBgColor = isLight ? const Color(0xFFFFFFFF) : const Color(0xFF0D1117);
    final Color axisTextColor = isLight ? const Color(0xFF222222) : const Color(0xFF8B949E);
    final Color borderLineColor = isLight ? const Color(0xFFCCCCCC) : const Color(0xFF30363D);
    final Color tickLineColor = isLight ? const Color(0xFF888888) : const Color(0xFF30363D);

    // 1. Draw entire canvas background
    canvas.drawRect(Rect.fromLTWH(0, 0, width, height), Paint()..color = canvasBgColor);

    // 2. Setup margins and plot area
    const double leftMargin = 75.0; // Fit "12.0 kHz" beautifully
    const double rightMargin = 20.0;
    const double topMargin = 20.0;
    const double bottomMargin = 40.0;

    final double plotWidth = width - leftMargin - rightMargin;
    final double plotHeight = height - topMargin - bottomMargin;

    // 3. Draw plot area background (pure black/white for high contrast spectrogram)
    canvas.drawRect(Rect.fromLTWH(leftMargin, topMargin, plotWidth, plotHeight), Paint()..color = bgPaintColor);

    // 4. Draw spectrogram frames inside the plot area
    final frameWidth = plotWidth / specData.frameCount;

    for (int i = 0; i < specData.frameCount; i++) {
      final frame = specData.frames[i];
      if (frame == null) continue;

      final x = leftMargin + i * frameWidth;
      final numBins = frame.length;
      final binHeight = plotHeight / numBins;

      for (int j = 0; j < numBins; j++) {
        final val = frame[j];
        if (val < 15) continue;
        canvas.drawRect(
          Rect.fromLTWH(x, topMargin + plotHeight - (j + 1) * binHeight, frameWidth + 0.3, binHeight + 0.3),
          palette[val],
        );
      }
    }

    // 5. Draw border around the plot area
    final borderPaint = Paint()
      ..color = borderLineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRect(Rect.fromLTWH(leftMargin, topMargin, plotWidth, plotHeight), borderPaint);

    // 6. Draw Y-axis frequency labels and ticks (0 to 12 kHz)
    void drawYLabel(String text, double yVal) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: axisTextColor,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            fontFamily: 'monospace',
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      
      final double tickY = topMargin + plotHeight - (yVal / 12.0) * plotHeight;
      final double labelY = tickY - (textPainter.height / 2);
      final double labelX = leftMargin - textPainter.width - 10.0;
      
      textPainter.paint(canvas, Offset(labelX, labelY));

      // Draw horizontal tick mark
      canvas.drawLine(
        Offset(leftMargin - 5.0, tickY),
        Offset(leftMargin, tickY),
        Paint()..color = tickLineColor..strokeWidth = 2.0,
      );
    }

    drawYLabel("12.0 kHz", 12.0);
    drawYLabel("9.0 kHz", 9.0);
    drawYLabel("6.0 kHz", 6.0);
    drawYLabel("3.0 kHz", 3.0);
    drawYLabel("0.0 kHz", 0.0);

    // 7. Draw X-axis time labels and ticks (0s, 3s, 6s, 9s)
    void drawXLabel(String text, double timeVal) {
      if (timeVal > specData.totalDuration) return;

      final textPainter = TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: axisTextColor,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            fontFamily: 'monospace',
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      final double tickX = leftMargin + (timeVal / specData.totalDuration) * plotWidth;
      final double labelX = tickX - (textPainter.width / 2);
      final double labelY = topMargin + plotHeight + 8.0;
      
      textPainter.paint(canvas, Offset(labelX, labelY));

      // Draw vertical tick mark
      canvas.drawLine(
        Offset(tickX, topMargin + plotHeight),
        Offset(tickX, topMargin + plotHeight + 5.0),
        Paint()..color = tickLineColor..strokeWidth = 2.0,
      );
    }

    drawXLabel("0.0s", 0.0);
    drawXLabel("3.0s", 3.0);
    drawXLabel("6.0s", 6.0);
    drawXLabel("9.0s", 9.0);

    // 8. Finalize image
    final picture = recorder.endRecording();
    final img = await picture.toImage(width.toInt(), height.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/spec_temp_${DateTime.now().microsecondsSinceEpoch}.png');
    await file.writeAsBytes(bytes);
    return file.path;
  }

  void _showFullscreen() {
    if (_spectrogramImagePath == null) return;
    Navigator.of(context).push(MaterialPageRoute(
      fullscreenDialog: true,
      builder: (ctx) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          foregroundColor: Colors.white,
        ),
        body: InteractiveViewer(
          constrained: false,
          minScale: 0.5,
          maxScale: 6.0,
          boundaryMargin: const EdgeInsets.all(300),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 40.0),
            child: Image.file(
              File(_spectrogramImagePath!),
              width: _clipDuration * 160.0,
              height: 480.0,
              fit: BoxFit.fill,
              filterQuality: FilterQuality.high,
            ),
          ),
        ),
      )
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final color = _confidenceColor(widget.detection.confidence, context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;

    // Modal background and border/decorations
    final modalBgColor = isDark ? const Color(0xFF161B22) : Colors.white;
    final handleColor = isDark ? const Color(0xFF30363D) : const Color(0xFFDEE2E6);
    final borderColor = isDark ? const Color(0xFF30363D) : const Color(0xFFE9ECEF);

    // Text colors
    final titleTextColor = isDark ? Colors.white : const Color(0xFF212529);
    final subtitleTextColor = isDark ? const Color(0xFF8B949E) : const Color(0xFF495057);

    // Mini player bar
    final playerBgColor = isDark ? const Color(0xFF21262D) : const Color(0xFFF1F3F5);
    final inactiveTrackColor = isDark ? const Color(0xFF30363D) : const Color(0xFFDEE2E6);

    // Button colors
    final buttonTextColor = isDark ? Colors.white : primaryColor;
    final buttonBorderColor = isDark ? const Color(0xFF30363D) : primaryColor.withOpacity(0.3);

    return Container(
      decoration: BoxDecoration(
        color: modalBgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.only(top: 12, bottom: 24, left: 20, right: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: handleColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.detection.commonName,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: titleTextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.detection.scientificName,
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: subtitleTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withOpacity(0.4)),
                ),
                child: Text(
                  widget.detection.confidencePercent,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Spectrogram area
          if (_isLoading)
            SizedBox(
              height: 180,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(l10n.detailSpectrogramLoading, style: TextStyle(color: subtitleTextColor)),
                  ],
                ),
              ),
            )
          else if (_error != null)
            SizedBox(
              height: 180,
              child: Center(
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      height: 180,
                      decoration: BoxDecoration(
                        border: Border.all(color: borderColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final double specWidth = _clipDuration * 70.0;
                            final double viewportWidth = constraints.maxWidth;

                            final Widget spectrogramWidget = GestureDetector(
                              onTap: _showFullscreen,
                              child: Stack(
                                children: [
                                  Image.file(
                                    File(_spectrogramImagePath!),
                                    width: specWidth,
                                    height: 180.0,
                                    fit: BoxFit.fill,
                                    filterQuality: FilterQuality.medium,
                                  ),
                                  ValueListenableBuilder<Duration>(
                                    valueListenable: _positionNotifier,
                                    builder: (context, pos, _) {
                                      // Map playback position exactly inside the spectrogram plot area
                                      final scale = 70.0 / 160.0; // 0.4375
                                      final leftMarginScaled = 75.0 * scale;
                                      final plotWidthScaled = specWidth - (75.0 * scale) - (20.0 * scale);

                                      return CustomPaint(
                                        size: Size(specWidth, 180.0),
                                        painter: _CursorPainter(
                                          playbackPosition: math.max(0.0, pos.inMilliseconds / 1000.0),
                                          clipDuration: _clipDuration,
                                          leftMarginScaled: leftMarginScaled,
                                          plotWidthScaled: plotWidthScaled,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            );

                            if (specWidth < viewportWidth) {
                              return Center(
                                child: spectrogramWidget,
                              );
                            } else {
                              return SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                child: spectrogramWidget,
                              );
                            }
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IgnorePointer(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.fullscreen_rounded, size: 14, color: Colors.white70),
                              const SizedBox(width: 4),
                              Text(
                                l10n.detailSpectrogramFullscreen,
                                style: const TextStyle(fontSize: 10, color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Mini player
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: playerBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(_isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_filled_rounded),
                        onPressed: _togglePlay,
                        iconSize: 42,
                        color: primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ValueListenableBuilder<Duration>(
                          valueListenable: _positionNotifier,
                          builder: (context, pos, _) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    trackHeight: 4,
                                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                    activeTrackColor: primaryColor,
                                    inactiveTrackColor: inactiveTrackColor,
                                    thumbColor: primaryColor,
                                  ),
                                  child: Slider(
                                    value: math.max(0.0, pos.inMilliseconds / 1000.0).clamp(0.0, _clipDuration),
                                    min: 0.0,
                                    max: _clipDuration,
                                    onChanged: (v) {
                                      _positionNotifier.value = Duration(milliseconds: (v * 1000).toInt());
                                    },
                                    onChangeEnd: (v) async {
                                      _isSeeking = true;
                                      await _audioPlayer.seek(Duration(milliseconds: (v * 1000).toInt()));
                                      if (mounted) _isSeeking = false;
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _formatTime(math.max(0.0, pos.inMilliseconds / 1000.0)),
                                        style: TextStyle(fontSize: 12, color: subtitleTextColor, fontFamily: 'monospace'),
                                      ),
                                      Text(
                                        _formatTime(_clipDuration),
                                        style: TextStyle(fontSize: 12, color: subtitleTextColor, fontFamily: 'monospace'),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.loop_rounded, color: _isLooping ? secondaryColor : subtitleTextColor),
                            onPressed: () {
                              setState(() => _isLooping = !_isLooping);
                              _audioPlayer.setReleaseMode(_isLooping ? ReleaseMode.loop : ReleaseMode.stop);
                            },
                            tooltip: l10n.detailLoopAudio,
                          ),
                          Text(
                            l10n.detailLoopAudio,
                            style: TextStyle(
                              fontSize: 10,
                              color: _isLooping ? secondaryColor : subtitleTextColor
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          
          const SizedBox(height: 24),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.audio_file_rounded),
                  label: Text(l10n.detailExportAudio),
                  onPressed: _isLoading ? null : _exportAudio,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: buttonBorderColor),
                    foregroundColor: buttonTextColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.image_rounded),
                  label: Text(l10n.detailExportSpectrogram),
                  onPressed: _isLoading ? null : _exportSpectrogram,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: buttonBorderColor),
                    foregroundColor: buttonTextColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _confidenceColor(double pct, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (pct >= 0.75) return isDark ? const Color(0xFF4CAF50) : const Color(0xFF2E7D32);
    if (pct >= 0.50) return isDark ? const Color(0xFFFF9800) : const Color(0xFFE65100);
    return const Color(0xFF8B949E);
  }

  String _formatTime(double seconds) {
    final s = math.max(0.0, seconds);
    final m = s ~/ 60;
    final sec = (s % 60).toStringAsFixed(1);
    return '$m:${sec.padLeft(4, '0')}';
  }
}

class _CursorPainter extends CustomPainter {
  final double playbackPosition;
  final double clipDuration;
  final double leftMarginScaled;
  final double plotWidthScaled;

  _CursorPainter({
    required this.playbackPosition,
    required this.clipDuration,
    required this.leftMarginScaled,
    required this.plotWidthScaled,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (playbackPosition < 0 || clipDuration <= 0) return;
    
    final cursorX = leftMarginScaled + (playbackPosition / clipDuration) * plotWidthScaled;
    
    // Draw only inside plot area boundaries
    if (cursorX >= leftMarginScaled && cursorX <= leftMarginScaled + plotWidthScaled) {
      // Scale vertical plot margins to screen height
      final scale = size.height / 480.0;
      final topMarginScaled = 20.0 * scale;
      final bottomMarginScaled = 40.0 * scale;
      final plotHeightScaled = size.height - topMarginScaled - bottomMarginScaled;

      canvas.drawLine(
        Offset(cursorX, topMarginScaled),
        Offset(cursorX, topMarginScaled + plotHeightScaled),
        Paint()
          ..color = Colors.red
          ..strokeWidth = 2.0,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CursorPainter old) {
    return old.playbackPosition != playbackPosition;
  }
}
