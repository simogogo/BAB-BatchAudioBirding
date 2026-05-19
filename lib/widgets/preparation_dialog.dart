import 'package:flutter/material.dart';
import 'package:batch_audio_birding/l10n/app_localizations.dart';

class PreparationDialog extends StatelessWidget {
  final int total;
  final ValueNotifier<int> progress;

  const PreparationDialog({
    super.key,
    required this.total,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PopScope(
      canPop: false,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFF0D1117),
        surfaceTintColor: Colors.transparent,
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: ValueListenableBuilder<int>(
            valueListenable: progress,
            builder: (context, current, _) {
              final percent = total > 0 ? current / total : 0.0;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.folder_zip_outlined,
                    size: 48,
                    color: Color(0xFF4CAF50),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.preparingFiles,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.preparingFilesProgress(current, total),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF8B949E),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percent,
                      minHeight: 8,
                      backgroundColor: const Color(0xFF30363D),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
