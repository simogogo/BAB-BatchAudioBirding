import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:batch_audio_birding/l10n/app_localizations.dart';
import '../providers/analysis_provider.dart';

class SelectedFilesDialog extends ConsumerWidget {
  const SelectedFilesDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(analysisProvider);
    final files = state.files;

    return AlertDialog(
      title: Text(l10n.selectedFilesTitle),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: const Color(0xFF0D1117),
      surfaceTintColor: Colors.transparent,
      content: SizedBox(
        width: double.maxFinite,
        child: files.isEmpty
            ? Center(
                child: Text(
                  l10n.homeNoLastFolder,
                  style: const TextStyle(color: Color(0xFF8B949E)),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                itemCount: files.length,
                itemBuilder: (context, index) {
                  final file = files[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      file.name,
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${(file.sizeBytes / 1024 / 1024).toStringAsFixed(2)} MB',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF8B949E)),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: Color(0xFFF85149)),
                      onPressed: () {
                        ref.read(analysisProvider.notifier).removeFile(index);
                      },
                      tooltip: l10n.selectedFilesRemove,
                    ),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.commonClose),
        ),
      ],
    );
  }
}
