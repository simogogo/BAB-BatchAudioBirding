import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:batch_audio_birding/l10n/app_localizations.dart';

import 'package:audioplayers/audioplayers.dart';
import '../models/detection.dart';
import '../models/analysis_result.dart';
import '../providers/analysis_provider.dart';
import '../services/csv_exporter.dart';
import '../widgets/detection_detail_modal.dart';

class ResultsDetailScreen extends ConsumerStatefulWidget {
  final int resultIndex;

  const ResultsDetailScreen({super.key, required this.resultIndex});

  @override
  ConsumerState<ResultsDetailScreen> createState() =>
      _ResultsDetailScreenState();
}

class _ResultsDetailScreenState extends ConsumerState<ResultsDetailScreen> {
  double _minConfidence = 0.0;
  final _audioPlayer = AudioPlayer();
  final _playerStateNotifier = ValueNotifier<PlayerState>(PlayerState.stopped);
  final _positionNotifier = ValueNotifier<Duration>(Duration.zero);
  final _selectedDetectionNotifier = ValueNotifier<Detection?>(null);
  Duration _duration = Duration.zero;
  bool _playerReady = false;

  @override
  void initState() {
    super.initState();
    _initPlayer();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _initPlayer() async {
    _audioPlayer.onPlayerStateChanged.listen((s) {
      if (mounted) _playerStateNotifier.value = s;
    });
    _audioPlayer.onPositionChanged.listen((p) {
      if (mounted) _positionNotifier.value = p;
    });
    _audioPlayer.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });

    final result = ref.read(analysisProvider).results[widget.resultIndex];
    if (result == null) return;

    try {
      await _audioPlayer.setSourceDeviceFile(result.filePath);
      if (mounted) setState(() => _playerReady = true);
    } catch (_) {}
  }

  void _seekTo(double seconds) {
    _audioPlayer.seek(Duration(milliseconds: (seconds * 1000).toInt()));
  }

  void _showDetailModal(BuildContext context, Detection detection, AnalysisResult result) async {
    // Release the main player completely to avoid MediaServer deadlocks on Android
    // when the modal tries to open the exact same file.
    await _audioPlayer.release();
    
    if (!context.mounted) return;
    
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DetectionDetailModal(
        detection: detection,
        result: result,
      ),
    );
    
    // Restore the main player when the modal is closed
    if (mounted) {
      _initPlayer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(analysisProvider);
    final result = state.results[widget.resultIndex];

    if (result == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.resultsTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final detections = result.filtered(_minConfidence)
      ..sort((a, b) => a.startSeconds.compareTo(b.startSeconds));

    return Scaffold(
      appBar: AppBar(
        title: Text(result.fileName, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            tooltip: l10n.resultsExportFile,
            onPressed: () => _exportSingle(context, result),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Audio Player ───────────────────────────────────────────────
          ValueListenableBuilder<Duration>(
            valueListenable: _positionNotifier,
            builder: (context, pos, _) {
              return ValueListenableBuilder<PlayerState>(
                valueListenable: _playerStateNotifier,
                builder: (context, playerState, _) {
                  return _PlayerBar(
                    position: pos,
                    duration: _duration,
                    isPlaying: playerState == PlayerState.playing,
                    isReady: _playerReady,
                    onToggle: () => playerState == PlayerState.playing
                        ? _audioPlayer.pause()
                        : _audioPlayer.resume(),
                    onSeek: (v) => _audioPlayer.seek(
                      Duration(milliseconds: v.toInt()),
                    ),
                  );
                },
              );
            },
          ),

          // ── Stats banner ───────────────────────────────────────────────
          _StatsBanner(result: result),

          // ── Confidence filter ──────────────────────────────────────────
          _ConfidenceFilter(
            value: _minConfidence,
            onChanged: (v) => setState(() => _minConfidence = v),
          ),

          // ── Detections list ────────────────────────────────────────────
          Expanded(
            child: detections.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.search_off,
                            size: 48, color: Color(0xFF8B949E)),
                        const SizedBox(height: 12),
                        Text(
                          l10n.resultsNoDetections,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: const Color(0xFF8B949E),
                                  ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    itemCount: detections.length,
                    itemBuilder: (ctx, i) => ValueListenableBuilder<Duration>(
                        valueListenable: _positionNotifier,
                        builder: (context, pos, _) {
                          return ValueListenableBuilder<PlayerState>(
                            valueListenable: _playerStateNotifier,
                            builder: (context, playerState, _) {
                              return ValueListenableBuilder<Detection?>(
                                valueListenable: _selectedDetectionNotifier,
                                builder: (context, selected, _) {
                                  final isActive =
                                      playerState == PlayerState.playing &&
                                          pos.inSeconds >=
                                              detections[i]
                                                  .startSeconds
                                                  .floor() &&
                                          pos.inSeconds <=
                                              detections[i].endSeconds.ceil();
                                  final isSelected = selected == detections[i];

                                  return _DetectionTile(
                                    detection: detections[i],
                                    totalDuration: result.durationSeconds,
                                    isPlaying: isActive,
                                    isSelected: isSelected,
                                    onSeek: () {
                                      _selectedDetectionNotifier.value = detections[i];
                                      _seekTo(detections[i].startSeconds);
                                    },
                                    onDetail: () {
                                      _selectedDetectionNotifier.value = detections[i];
                                      _showDetailModal(context, detections[i], result);
                                    },
                                  );
                                },
                              );
                            },
                          );
                        },
                      )
                        .animate(delay: (i * 20).ms)
                        .fadeIn(duration: 250.ms)
                        .slideX(begin: 0.04, end: 0),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportSingle(
      BuildContext context, AnalysisResult result) async {
    try {
      final path = await CsvExporter.exportSingle(
          result, minConfidence: _minConfidence);
      final baseName = result.fileName.replaceAll(RegExp(r'\.\w+$'), '');
      final success = await CsvExporter.save(path, '${baseName}_BirdNET.csv');
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.csvExportSuccess)),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(AppLocalizations.of(context)!.csvExportError)),
        );
      }
    }
  }
}

// ─── Stats banner ─────────────────────────────────────────────────────────

class _StatsBanner extends StatelessWidget {
  final AnalysisResult result;

  const _StatsBanner({required this.result});

  @override
  Widget build(BuildContext context) {
    final unique = result.uniqueSpecies.length;
    final dur = result.durationSeconds;
    final durStr =
        '${(dur ~/ 60).toString().padLeft(2, '0')}:${(dur % 60).round().toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
                ? const Color(0xFF30363D)
                : const Color(0xFFE9ECEF),
          ),
        ),
      ),
      child: Row(
        children: [
          _StatChip(
            icon: Icons.sensors,
            label: '${result.detectionCount}',
            sublabel: 'detections',
            color: const Color(0xFF4CAF50),
          ),
          const SizedBox(width: 12),
          _StatChip(
            icon: Icons.flutter_dash,
            label: '$unique',
            sublabel: 'species',
            color: const Color(0xFF00BCD4),
          ),
          const SizedBox(width: 12),
          _StatChip(
            icon: Icons.timer_outlined,
            label: durStr,
            sublabel: 'duration',
            color: const Color(0xFF8B949E),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sublabel;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: color)),
              Text(sublabel,
                  style: const TextStyle(
                      fontSize: 10, color: Color(0xFF8B949E))),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Confidence filter ────────────────────────────────────────────────────

class _ConfidenceFilter extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const _ConfidenceFilter({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            l10n.resultsFilterThreshold,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF8B949E),
                ),
          ),
          Expanded(
            child: Slider(
              value: value,
              min: 0.0,
              max: 0.9,
              divisions: 18,
              onChanged: onChanged,
            ),
          ),
          Text(
            '${(value * 100).round()}%',
            style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF4CAF50),
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// ─── Audio Player Bar ─────────────────────────────────────────────────────

class _PlayerBar extends StatelessWidget {
  final Duration position;
  final Duration duration;
  final bool isPlaying;
  final bool isReady;
  final VoidCallback onToggle;
  final ValueChanged<double> onSeek;

  const _PlayerBar({
    required this.position,
    required this.duration,
    required this.isPlaying,
    required this.isReady,
    required this.onToggle,
    required this.onSeek,
  });

  @override
  Widget build(BuildContext context) {
    final posStr = _fmt(position);
    final durStr = _fmt(duration);
    final maxMs = duration.inMilliseconds.toDouble();
    final curMs = position.inMilliseconds
        .toDouble()
        .clamp(0.0, maxMs > 0 ? maxMs : 1.0);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final bgColor = isDark ? const Color(0xFF161B22) : const Color(0xFFF1F3F5);
    final borderColor = isDark ? const Color(0xFF30363D) : const Color(0xFFE9ECEF);
    final inactiveTrackColor = isDark ? const Color(0xFF30363D) : const Color(0xFFDEE2E6);
    final textColor = isDark ? const Color(0xFF8B949E) : const Color(0xFF495057);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          bottom: BorderSide(color: borderColor),
        ),
      ),
      child: Row(
        children: [
          // Play / Pause button
          IconButton(
            icon: isReady
                ? Icon(isPlaying
                    ? Icons.pause_circle_filled_rounded
                    : Icons.play_circle_filled_rounded)
                : const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
            onPressed: isReady ? onToggle : null,
            color: primaryColor,
            iconSize: 36,
          ),

          // Current position
          Text(posStr,
              style: TextStyle(
                  fontSize: 12,
                  color: textColor,
                  fontFamily: 'monospace')),

          // Seek slider
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 3,
                thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 7),
                overlayShape:
                    const RoundSliderOverlayShape(overlayRadius: 16),
                activeTrackColor: primaryColor,
                inactiveTrackColor: inactiveTrackColor,
                thumbColor: primaryColor,
              ),
              child: Slider(
                value: curMs,
                max: maxMs > 0 ? maxMs : 1,
                onChanged: isReady ? onSeek : null,
              ),
            ),
          ),

          // Total duration
          Text(durStr,
              style: TextStyle(
                  fontSize: 12,
                  color: textColor,
                  fontFamily: 'monospace')),

          const SizedBox(width: 8),
        ],
      ),
    );
  }

  String _fmt(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}

// ─── Detection tile ───────────────────────────────────────────────────────

class _DetectionTile extends StatelessWidget {
  final Detection detection;
  final double totalDuration;
  final bool isPlaying;
  final bool isSelected;
  final VoidCallback onSeek;
  final VoidCallback onDetail;

  const _DetectionTile({
    required this.detection,
    required this.totalDuration,
    required this.onSeek,
    required this.onDetail,
    this.isPlaying = false,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final pct = detection.confidence;
    final color = _confidenceColor(pct, context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: isSelected ? color.withValues(alpha: 0.1) : null,
      shape: isSelected || isPlaying
          ? RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isSelected ? color : color.withValues(alpha: 0.5),
                width: isSelected ? 2.0 : 1.5,
              ),
            )
          : null,
      child: InkWell(
        onTap: onSeek,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Time indicator
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    detection.startFormatted,
                    style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF8B949E),
                        fontFamily: 'monospace'),
                  ),
                  Container(
                      width: 1, height: 12, color: const Color(0xFF30363D)),
                  Text(
                    detection.endFormatted,
                    style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF8B949E),
                        fontFamily: 'monospace'),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              
              // Species name
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      detection.commonName,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isPlaying ? color : null,
                          ),
                    ),
                    Text(
                      detection.scientificName,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF8B949E),
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ],
                ),
              ),

              // Confidence badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withOpacity(0.4)),
                ),
                child: Text(
                  detection.confidencePercent,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: color),
                ),
              ),
              
              const SizedBox(width: 8),

              // Details Action (placed far right)
              IconButton(
                icon: const Icon(Icons.graphic_eq_rounded, color: Color(0xFF00BCD4)),
                onPressed: onDetail,
                tooltip: 'Details',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _confidenceColor(double pct, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (pct >= 0.75) return isDark ? const Color(0xFF4CAF50) : const Color(0xFF2E7D32);
    if (pct >= 0.50) return isDark ? const Color(0xFFFF9800) : const Color(0xFFE65100);
    return const Color(0xFF8B949E);
  }
}
