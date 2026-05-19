import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:batch_audio_birding/l10n/app_localizations.dart';

class UpdateService {
  static final Dio _dio = Dio(BaseOptions(connectTimeout: const Duration(seconds: 5)));

  /// Checks for updates against the provided [updateUrl].
  ///
  /// If [showNoUpdateMessage] is true, it will display a dialog informing the user
  /// that they are already running the latest version.
  static Future<void> checkForUpdates(
    BuildContext context,
    String updateUrl, {
    bool showNoUpdateMessage = false,
  }) async {
    final l10n = AppLocalizations.of(context)!;

    // Show loading spinner if checking manually
    if (showNoUpdateMessage) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    try {
      // 1. Fetch current app metadata
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      final currentBuild = int.tryParse(packageInfo.buildNumber) ?? 1;

      // 2. Fetch remote update metadata
      final response = await _dio.get(updateUrl);
      
      // Close loading dialog if showing
      if (showNoUpdateMessage && context.mounted) {
        Navigator.pop(context);
      }

      if (response.statusCode != 200 || response.data == null) {
        throw Exception("Server returned status ${response.statusCode}");
      }

      var data = response.data;
      if (data is String) {
        try {
          data = jsonDecode(data);
        } catch (_) {
          throw Exception("Invalid JSON format in remote metadata");
        }
      }

      if (data is! Map<String, dynamic>) {
        throw Exception("Invalid update metadata format");
      }

      final remoteVersion = data['version'] as String? ?? '1.0.0';
      final remoteBuild = data['build_number'] as int? ?? 1;
      final remoteUrl = data['url'] as String? ?? '';
      final changelogMap = data['changelog'] as Map<String, dynamic>? ?? {};

      // 3. Determine if update is available
      final hasUpdate = remoteBuild > currentBuild || remoteVersion != currentVersion;

      if (!context.mounted) return;

      if (hasUpdate) {
        // Retrieve localized changelog
        final langCode = l10n.localeName; // 'en', 'it', 'fr', etc.
        final changelog = changelogMap[langCode] as String? ?? 
            changelogMap['en'] as String? ?? 
            l10n.settingsUpdateNoChangelog;

        // Display beautiful premium Update Dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            icon: CircleAvatar(
              radius: 28,
              backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
              child: Icon(
                Icons.system_update_rounded,
                size: 32,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            title: Text(
              l10n.settingsUpdateTitle,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'v$currentVersion (Build $currentBuild) ➔ v$remoteVersion (Build $remoteBuild)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    l10n.settingsUpdateChangelogHeader,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    changelog,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  l10n.settingsUpdateLater,
                  style: const TextStyle(color: Color(0xFF8B949E)),
                ),
              ),
              FilledButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  final uri = Uri.parse(remoteUrl);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                icon: const Icon(Icons.download_rounded, size: 18),
                label: Text(l10n.settingsUpdateNow),
              ),
            ],
          ),
        );
      } else if (showNoUpdateMessage) {
        // Inform user they are running the latest version
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            icon: CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFF4CAF50).withValues(alpha: 0.15),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                size: 32,
                color: Color(0xFF4CAF50),
              ),
            ),
            title: Text(
              l10n.settingsUpdateLatestTitle,
              style: const TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            content: Text(
              l10n.settingsUpdateLatestDesc,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if showing
      if (showNoUpdateMessage && context.mounted) {
        Navigator.pop(context);
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.settingsUpdateError}: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
