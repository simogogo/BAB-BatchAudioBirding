import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:batch_audio_birding/l10n/app_localizations.dart';

import '../models/filter_settings.dart';
import '../providers/analysis_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/preparation_dialog.dart';
import '../widgets/selected_files_dialog.dart';

// ─── HomeScreen as StatefulWidget ─────────────────────────────────────────
// Using ConsumerStatefulWidget gives us a proper `mounted` check, which is
// essential when calling showDialog after async gaps (e.g. after FilePicker).

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settingsAsync = ref.watch(settingsProvider);
    final settings = settingsAsync.valueOrNull ?? const AppSettings();
    final fileCount = ref.watch(analysisProvider).files.length;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/icon/app_icon.png',
              width: 32,
              height: 32,
            ),
            const SizedBox(width: 10),
            Text(l10n.homeTitle),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n.homeSettings,
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Hero card ─────────────────────────────────────────────
              _HeroCard(
                lastFolder: settings.lastFolderPath,
                fileCount: fileCount,
                onPick: _pickFiles,
                onViewList: fileCount > 0 ? _showFileList : null,
              )
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: 0.1, end: 0),

              const SizedBox(height: 20),

              // ── Quick settings ────────────────────────────────────────
              _QuickSettingsCard(settings: settings, ref: ref)
                  .animate()
                  .fadeIn(delay: 150.ms, duration: 500.ms)
                  .slideY(begin: 0.1, end: 0),

              const SizedBox(height: 20),

              // ── Filter badge ──────────────────────────────────────────
              _FilterBadge(filter: settings.filter)
                  .animate()
                  .fadeIn(delay: 250.ms, duration: 500.ms),

              const SizedBox(height: 32),

              // ── Start button ──────────────────────────────────────────
              _StartButton(
                enabled: fileCount > 0,
                onPressed: _startAnalysis,
              )
                  .animate()
                  .fadeIn(delay: 350.ms, duration: 500.ms)
                  .scale(begin: const Offset(0.95, 0.95)),
            ],
          ),
        ),
      ),
    );
  }

  void _showFileList() {
    showDialog(
      context: context,
      builder: (ctx) => const SelectedFilesDialog(),
    );
  }

  Future<void> _pickFiles() async {
    // Request permissions for Android
    if (Platform.isAndroid) {
      await [
        Permission.storage,
        Permission.audio,
        Permission.manageExternalStorage,
      ].request();
    }

    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.audio,
    );

    if (result == null || result.files.isEmpty) return;

    final paths = result.files
        .map((f) => f.path)
        .whereType<String>()
        .toList();
    if (paths.isEmpty) return;

    // Guard: widget might have been disposed while FilePicker was open
    if (!mounted) return;

    final progress = ValueNotifier<int>(0);
    bool dialogDismissed = false;

    // 1. Show the dialog — Flutter schedules this for the NEXT frame.
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (ctx) => PreparationDialog(
        total: paths.length,
        progress: progress,
      ),
    );

    // 2. Wait until the dialog has been fully painted before starting work.
    //    endOfFrame completes after all pending frames have been rendered,
    //    so the dialog is guaranteed to be visible before we start loading.
    await SchedulerBinding.instance.endOfFrame;

    try {
      await ref
          .read(settingsProvider.notifier)
          .setLastFolder(paths.first);

      await ref.read(analysisProvider.notifier).loadFiles(
            paths,
            onProgress: (curr, tot) {
              if (!dialogDismissed) progress.value = curr;
            },
          );
    } finally {
      dialogDismissed = true;
      // 3. Close the dialog only if the widget is still in the tree.
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      progress.dispose();
    }
  }

  Future<void> _startAnalysis() async {
    final state = ref.read(analysisProvider);
    if (state.files.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(AppLocalizations.of(context)!.errorNoFiles)),
        );
      }
      return;
    }

    if (mounted) {
      Navigator.pushNamed(context, '/analysis');
    }
  }
}

// ─── Hero pick-folder card ────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  final String? lastFolder;
  final int fileCount;
  final VoidCallback onPick;
  final VoidCallback? onViewList;

  const _HeroCard({
    this.lastFolder,
    required this.fileCount,
    required this.onPick,
    this.onViewList,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final gradientColors = isDark
        ? [const Color(0xFF1B3A1B), const Color(0xFF0D2117)]
        : [const Color(0xFFE8F5E9), const Color(0xFFC8E6C9)];

    final primaryColor = isDark ? const Color(0xFF4CAF50) : const Color(0xFF2E7D32);
    final borderColor = primaryColor.withOpacity(isDark ? 0.4 : 0.3);
    final subtitleColor = isDark ? const Color(0xFF8B949E) : const Color(0xFF3E4F41);
    final dividerColor = isDark ? const Color(0xFF30363D) : primaryColor.withOpacity(0.15);
    final shadowColor = primaryColor.withOpacity(isDark ? 0.08 : 0.06);

    return GestureDetector(
      onTap: onPick,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 30,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.audiotrack_rounded,
                    color: primaryColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.homeSelectFolder,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: primaryColor,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        fileCount > 0
                            ? l10n.homeFilesSelected(fileCount)
                            : l10n.homeSelectFolderSubtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: subtitleColor,
                            ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right,
                    color: primaryColor, size: 24),
              ],
            ),
            if (fileCount > 0 && onViewList != null) ...[
              const SizedBox(height: 20),
              Divider(color: dividerColor),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  // Prevent the tap from bubbling up to the GestureDetector
                  onPressed: () => onViewList!(),
                  icon: const Icon(Icons.list_alt_rounded, size: 18),
                  label: Text(l10n.homeViewSelectedFiles),
                  style: TextButton.styleFrom(
                    foregroundColor: subtitleColor,
                    alignment: Alignment.centerLeft,
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Quick settings card ─────────────────────────────────────────────────

class _QuickSettingsCard extends StatelessWidget {
  final AppSettings settings;
  final WidgetRef ref;

  const _QuickSettingsCard({required this.settings, required this.ref});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.homeThreshold,
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: const Color(0xFF8B949E)),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: settings.threshold,
                    min: 0.05,
                    max: 0.95,
                    divisions: 18,
                    label: '${(settings.threshold * 100).round()}%',
                    onChanged: (v) {
                      ref.read(settingsProvider.notifier).updateSettings(
                            settings.copyWith(threshold: v),
                          );
                    },
                  ),
                ),
                SizedBox(
                  width: 48,
                  child: Text(
                    '${(settings.threshold * 100).round()}%',
                    textAlign: TextAlign.right,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF4CAF50),
                        ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Filter badge ─────────────────────────────────────────────────────────

class _FilterBadge extends StatelessWidget {
  final FilterSettings filter;

  const _FilterBadge({required this.filter});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    String label;
    IconData icon;
    Color color;

    switch (filter.mode) {
      case FilterMode.geographic:
        label = l10n.settingsFilterGeo;
        icon = Icons.location_on_outlined;
        color = const Color(0xFF00BCD4);
      case FilterMode.speciesList:
        label = filter.speciesList.isEmpty
            ? l10n.settingsFilterList
            : l10n.settingsSpeciesListSelected(filter.speciesList.length);
        icon = Icons.list_alt_rounded;
        color = (Theme.of(context).brightness == Brightness.dark)
            ? const Color(0xFFFF9800)
            : const Color(0xFFE65100);
      case FilterMode.none:
        label = l10n.settingsFilterNone;
        icon = Icons.filter_alt_off_outlined;
        color = const Color(0xFF8B949E);
    }

    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(label, style: TextStyle(color: color, fontSize: 12)),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color.withOpacity(0.3)),
    );
  }
}

// ─── Start analysis button ────────────────────────────────────────────────

class _StartButton extends StatelessWidget {
  final bool enabled;
  final VoidCallback onPressed;

  const _StartButton({required this.enabled, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: enabled ? onPressed : null,
        icon: const Icon(Icons.play_circle_outline_rounded, size: 22),
        label: Text(l10n.homeStartAnalysis),
      ),
    );
  }
}
