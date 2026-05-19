import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/filter_settings.dart';
import '../models/spectrogram_color_theme.dart';

// ─── App Settings ──────────────────────────────────────────────────────────

class AppSettings {
  final double threshold;
  final double overlapSeconds;
  final double sensitivity;
  final FilterSettings filter;
  final String? lastFolderPath;
  final String languageCode;
  final SpectrogramColorTheme spectrogramTheme;
  final bool hasSeenOnboarding;
  final String themeMode;
  final String updateUrl;

  const AppSettings({
    this.threshold = 0.10,
    this.overlapSeconds = 0.0,
    this.sensitivity = 1.0,
    this.filter = const FilterSettings(),
    this.lastFolderPath,
    this.languageCode = 'en',
    this.spectrogramTheme = SpectrogramColorTheme.colored,
    this.hasSeenOnboarding = false,
    this.themeMode = 'system',
    this.updateUrl = 'https://raw.githubusercontent.com/stefan/BatchAudioBirding/main/release/version.json',
  });

  AppSettings copyWith({
    double? threshold,
    double? overlapSeconds,
    double? sensitivity,
    FilterSettings? filter,
    String? lastFolderPath,
    String? languageCode,
    SpectrogramColorTheme? spectrogramTheme,
    bool? hasSeenOnboarding,
    String? themeMode,
    String? updateUrl,
  }) {
    return AppSettings(
      threshold: threshold ?? this.threshold,
      overlapSeconds: overlapSeconds ?? this.overlapSeconds,
      sensitivity: sensitivity ?? this.sensitivity,
      filter: filter ?? this.filter,
      lastFolderPath: lastFolderPath ?? this.lastFolderPath,
      languageCode: languageCode ?? this.languageCode,
      spectrogramTheme: spectrogramTheme ?? this.spectrogramTheme,
      hasSeenOnboarding: hasSeenOnboarding ?? this.hasSeenOnboarding,
      themeMode: themeMode ?? this.themeMode,
      updateUrl: updateUrl ?? this.updateUrl,
    );
  }

  Map<String, dynamic> toJson() => {
        'threshold': threshold,
        'overlapSeconds': overlapSeconds,
        'sensitivity': sensitivity,
        'filter': filter.toJson(),
        'lastFolderPath': lastFolderPath,
        'languageCode': languageCode,
        'spectrogramTheme': spectrogramTheme.name,
        'hasSeenOnboarding': hasSeenOnboarding,
        'themeMode': themeMode,
        'updateUrl': updateUrl,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        threshold: (json['threshold'] as num?)?.toDouble() ?? 0.10,
        overlapSeconds: (json['overlapSeconds'] as num?)?.toDouble() ?? 0.0,
        sensitivity: (json['sensitivity'] as num?)?.toDouble() ?? 1.0,
        filter: json['filter'] != null
            ? FilterSettings.fromJson(
                Map<String, dynamic>.from(json['filter'] as Map))
            : const FilterSettings(),
        lastFolderPath: json['lastFolderPath'] as String?,
        languageCode: json['languageCode'] as String? ?? 'en',
        spectrogramTheme: json['spectrogramTheme'] != null
            ? SpectrogramColorTheme.values.firstWhere(
                (e) => e.name == json['spectrogramTheme'] as String,
                orElse: () => SpectrogramColorTheme.colored)
            : SpectrogramColorTheme.colored,
        hasSeenOnboarding: json['hasSeenOnboarding'] as bool? ?? false,
        themeMode: json['themeMode'] as String? ?? 'system',
        updateUrl: json['updateUrl'] as String? ?? 'https://raw.githubusercontent.com/stefan/BatchAudioBirding/main/release/version.json',
      );
}

// ─── Notifier ─────────────────────────────────────────────────────────────

class SettingsNotifier extends AsyncNotifier<AppSettings> {
  static const _prefKey = 'app_settings';

  @override
  Future<AppSettings> build() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefKey);
    if (raw == null) return const AppSettings();
    try {
      return AppSettings.fromJson(
          Map<String, dynamic>.from(jsonDecode(raw) as Map));
    } catch (_) {
      return const AppSettings();
    }
  }

  Future<void> updateSettings(AppSettings settings) async {
    state = AsyncData(settings);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, jsonEncode(settings.toJson()));
  }

  Future<void> setLastFolder(String path) async {
    final current = state.valueOrNull ?? const AppSettings();
    await updateSettings(current.copyWith(lastFolderPath: path));
  }

  Future<void> setLanguage(String code) async {
    final current = state.valueOrNull ?? const AppSettings();
    await updateSettings(current.copyWith(languageCode: code));
  }

  Future<void> setHasSeenOnboarding(bool seen) async {
    final current = state.valueOrNull ?? const AppSettings();
    await updateSettings(current.copyWith(hasSeenOnboarding: seen));
  }

  Future<void> setThemeMode(String mode) async {
    final current = state.valueOrNull ?? const AppSettings();
    await updateSettings(current.copyWith(themeMode: mode));
  }

  Future<void> setUpdateUrl(String url) async {
    final current = state.valueOrNull ?? const AppSettings();
    await updateSettings(current.copyWith(updateUrl: url));
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────

final settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);
