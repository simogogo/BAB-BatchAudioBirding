import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:batch_audio_birding/l10n/app_localizations.dart';

import '../models/audio_file.dart';
import '../models/analysis_result.dart';
import '../providers/analysis_provider.dart';
import '../providers/model_provider.dart';
import '../providers/settings_provider.dart';
import '../services/birdnet_service.dart';
import '../services/csv_exporter.dart';
import '../services/meta_filter_service.dart';

class AnalysisScreen extends ConsumerStatefulWidget {
  const AnalysisScreen({super.key});

  @override
  ConsumerState<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends ConsumerState<AnalysisScreen> {
  bool _started = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startIfNeeded());
  }

  Future<void> _startIfNeeded() async {
    if (_started) return;
    _started = true;

    final analysisState = ref.read(analysisProvider);
    if (analysisState.files.isEmpty || analysisState.running) return;

    final settings =
        ref.read(settingsProvider).valueOrNull ?? const AppSettings();
    final modelNotifier = ref.read(modelProvider.notifier);

    try {
      final String langCode = Localizations.localeOf(context).languageCode;
      String labelsPath = 'assets/labels/labels_$langCode.txt';

      List<String> labels;
      try {
        final content = await rootBundle.loadString(labelsPath);
        labels = content.split('\n').where((l) => l.trim().isNotEmpty).toList();
      } catch (_) {
        try {
          final content =
              await rootBundle.loadString('assets/labels/labels_en.txt');
          labels =
              content.split('\n').where((l) => l.trim().isNotEmpty).toList();
        } catch (_) {
          labels = [];
        }
      }

      final birdnet = BirdnetService();
      if (!birdnet.isReady) {
        await birdnet.init(
          modelPath: modelNotifier.mainModelPath,
          labels: labels,
        );
      }

      final metaFilter = MetaFilterService();
      if (!metaFilter.isReady) {
        await metaFilter.init(modelNotifier.metaModelPath);
      }

      ref.read(analysisProvider.notifier).startAnalysis(
            threshold: settings.threshold,
            overlapSeconds: settings.overlapSeconds,
            sensitivity: settings.sensitivity,
            filterSettings: settings.filter,
            labels: labels,
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error initializing models: $e')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(analysisProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.analysisTitle),
        leading: BackButton(
          onPressed: () {
            if (state.running) {
              ref.read(analysisProvider.notifier).stopAnalysis();
            }
            Navigator.pop(context);
          },
        ),
        actions: [
          if (state.done)
            TextButton.icon(
              icon: const Icon(Icons.download_rounded, size: 18),
              label: Text(l10n.analysisExportCsv),
              onPressed: () => _exportAll(context, state.allResults),
            ),
        ],
      ),
      body: Column(
        children: [
          // ── Progress header ────────────────────────────────────────────
          _ProgressHeader(state: state),

          // ── File list ──────────────────────────────────────────────────
          Expanded(
            child: state.files.isEmpty
                ? Center(
                    child: Text(
                      l10n.errorNoFiles,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: const Color(0xFF8B949E)),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    itemCount: state.files.length,
                    itemBuilder: (ctx, i) {
                      final file = state.files[i];
                      final result = state.results[i];
                      return _FileListTile(
                        file: file,
                        result: result,
                        isActive: state.currentIndex == i,
                        onTap: result != null
                            ? () => Navigator.pushNamed(
                                  context,
                                  '/results',
                                  arguments: i,
                                )
                            : null,
                      )
                          .animate(delay: (i * 30).ms)
                          .fadeIn(duration: 300.ms)
                          .slideX(begin: 0.05, end: 0);
                    },
                  ),
          ),

          // ── Bottom stop button ─────────────────────────────────────────
          if (state.running)
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () =>
                      ref.read(analysisProvider.notifier).stopAnalysis(),
                  icon: const Icon(Icons.stop_circle_outlined),
                  label: Text(l10n.analysisStop),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFF85149),
                    side: const BorderSide(color: Color(0xFFF85149)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _exportAll(
      BuildContext context, List<AnalysisResult> results) async {
    try {
      final path = await CsvExporter.exportAll(results);
      final success = await CsvExporter.save(path, 'BirdNET_batch_results.csv');
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.csvExportSuccess)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppLocalizations.of(context)!.csvExportError)),
        );
      }
    }
  }
}

// ─── Progress Header ──────────────────────────────────────────────────────

class _ProgressHeader extends StatelessWidget {
  final AnalysisState state;

  const _ProgressHeader({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final progress = state.totalFiles > 0
        ? state.completedFiles / state.totalFiles
        : 0.0;

    final totalMinutes = (state.totalAudioSeconds / 60).floor();
    final totalHours = totalMinutes ~/ 60;
    final remMin = totalMinutes % 60;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF30363D))),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.analysisProgress(
                          state.completedFiles, state.totalFiles),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.analysisDetections(state.totalDetections),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF4CAF50),
                          ),
                    ),
                  ],
                ),
              ),
              if (state.done && state.totalAudioSeconds > 0)
                Text(
                  l10n.analysisTotalAudio(totalHours, remMin),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF8B949E),
                      ),
                ),
              if (state.running)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: const Color(0xFF30363D),
              valueColor: AlwaysStoppedAnimation<Color>(
                state.done
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFF4CAF50),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── File list tile ───────────────────────────────────────────────────────

class _FileListTile extends StatelessWidget {
  final AudioFile file;
  final AnalysisResult? result;
  final bool isActive;
  final VoidCallback? onTap;

  const _FileListTile({
    required this.file,
    this.result,
    required this.isActive,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    Color statusColor;
    Widget trailing;
    String statusText;

    switch (file.status) {
      case AudioFileStatus.waiting:
        statusColor = const Color(0xFF8B949E);
        trailing = const Icon(Icons.hourglass_empty_rounded,
            size: 18, color: Color(0xFF8B949E));
        statusText = l10n.analysisStatusWaiting;
      case AudioFileStatus.processing:
        statusColor = const Color(0xFF00BCD4);
        trailing = const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
              strokeWidth: 2, color: Color(0xFF00BCD4)),
        );
        statusText = l10n.analysisStatusProcessing;
      case AudioFileStatus.done:
        statusColor = const Color(0xFF4CAF50);
        trailing = const Icon(Icons.check_circle_outline,
            size: 20, color: Color(0xFF4CAF50));
        statusText =
            l10n.analysisStatusDone(file.detectionCount);
      case AudioFileStatus.error:
        statusColor = const Color(0xFFF85149);
        trailing = const Icon(Icons.error_outline,
            size: 20, color: Color(0xFFF85149));
        statusText = l10n.analysisStatusError(
            file.errorMessage ?? 'Unknown error');
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      file.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  trailing,
                ],
              ),
              const SizedBox(height: 6),
              Text(
                statusText,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: statusColor,
                    ),
              ),
              if (result != null && result!.hasDetections) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: result!.topDetections(3).map((d) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: const Color(0xFF4CAF50).withOpacity(0.3)),
                      ),
                      child: Text(
                        '${d.commonName} ${d.confidencePercent}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF4CAF50),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
