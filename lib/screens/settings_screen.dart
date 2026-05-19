import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:batch_audio_birding/l10n/app_localizations.dart';

import '../models/filter_settings.dart';
import '../models/spectrogram_color_theme.dart';
import '../providers/settings_provider.dart';
import '../services/update_service.dart';
import '../widgets/location_species_preview_modal.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _latCtrl;
  late TextEditingController _lonCtrl;
  late TextEditingController _weekCtrl;
  late TextEditingController _thresholdCtrl;
  late TextEditingController _updateUrlCtrl;
  bool _controllersInitialized = false;

  @override
  void initState() {
    super.initState();
    _latCtrl = TextEditingController();
    _lonCtrl = TextEditingController();
    _weekCtrl = TextEditingController();
    _thresholdCtrl = TextEditingController();
    _updateUrlCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _latCtrl.dispose();
    _lonCtrl.dispose();
    _weekCtrl.dispose();
    _thresholdCtrl.dispose();
    _updateUrlCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settingsAsync = ref.watch(settingsProvider);
    final settings = settingsAsync.valueOrNull ?? const AppSettings();

    // Sync text controllers ONCE when settings are first loaded
    if (settingsAsync.hasValue && !_controllersInitialized) {
      if (settings.filter.latitude != null) {
        _latCtrl.text = settings.filter.latitude!.toStringAsFixed(4);
      }
      if (settings.filter.longitude != null) {
        _lonCtrl.text = settings.filter.longitude!.toStringAsFixed(4);
      }
      if (settings.filter.week != null) {
        _weekCtrl.text = settings.filter.week!.toString();
      }
      _thresholdCtrl.text = settings.filter.locationThreshold.toString();
      _updateUrlCtrl.text = settings.updateUrl;
      _controllersInitialized = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settingsTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Language ───────────────────────────────────────────────────
          _SectionHeader(l10n.settingsLanguage),
          _LanguageSelector(
            current: settings.languageCode,
            onChanged: (code) => ref
                .read(settingsProvider.notifier)
                .setLanguage(code),
          ),

          const SizedBox(height: 24),

          // ── ThemeMode ──────────────────────────────────────────────────
          _SectionHeader(l10n.settingsThemeMode),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: SegmentedButton<String>(
                          segments: [
                            ButtonSegment<String>(
                              value: 'system',
                              icon: const Icon(Icons.settings_suggest_rounded),
                              label: Text(l10n.settingsThemeSystem),
                            ),
                            ButtonSegment<String>(
                              value: 'light',
                              icon: const Icon(Icons.light_mode_rounded, color: Colors.orange),
                              label: Text(l10n.settingsThemeLight),
                            ),
                            ButtonSegment<String>(
                              value: 'dark',
                              icon: const Icon(Icons.dark_mode_rounded, color: Color(0xFF4CAF50)),
                              label: Text(l10n.settingsThemeDark),
                            ),
                          ],
                          selected: {settings.themeMode},
                          onSelectionChanged: (newSelection) {
                            if (newSelection.isNotEmpty) {
                              ref
                                  .read(settingsProvider.notifier)
                                  .setThemeMode(newSelection.first);
                            }
                          },
                          style: SegmentedButton.styleFrom(
                            selectedBackgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                            selectedForegroundColor: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(l10n.settingsThemeModeHelp,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF8B949E),
                          )),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ── Threshold ──────────────────────────────────────────────────
          _SectionHeader(l10n.settingsThreshold),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: settings.threshold,
                          min: 0.05,
                          max: 0.95,
                          divisions: 18,
                          label: '${(settings.threshold * 100).round()}%',
                          onChanged: (v) => ref
                              .read(settingsProvider.notifier)
                              .updateSettings(settings.copyWith(threshold: v)),
                        ),
                      ),
                      Text('${(settings.threshold * 100).round()}%',
                          style: const TextStyle(
                              color: Color(0xFF4CAF50),
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                  Text(l10n.settingsThresholdHelp,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF8B949E),
                          )),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ── Overlap ────────────────────────────────────────────────────
          _SectionHeader(l10n.settingsOverlap),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: settings.overlapSeconds,
                          min: 0.0,
                          max: 2.9,
                          divisions: 29,
                          label: '${settings.overlapSeconds.toStringAsFixed(1)}s',
                          onChanged: (v) => ref
                              .read(settingsProvider.notifier)
                              .updateSettings(settings.copyWith(overlapSeconds: v)),
                        ),
                      ),
                      Text(
                          '${settings.overlapSeconds.toStringAsFixed(1)}s',
                          style: const TextStyle(
                              color: Color(0xFF4CAF50),
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                  Text(l10n.settingsOverlapHelp,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF8B949E),
                          )),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ── Sensitivity ────────────────────────────────────────────────
          _SectionHeader(l10n.settingsSensitivity),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Slider(
                          value: settings.sensitivity,
                          min: 0.5,
                          max: 1.5,
                          divisions: 10,
                          label: settings.sensitivity.toStringAsFixed(1),
                          onChanged: (v) => ref
                              .read(settingsProvider.notifier)
                              .updateSettings(settings.copyWith(sensitivity: v)),
                        ),
                      ),
                      Text(
                          settings.sensitivity.toStringAsFixed(1),
                          style: const TextStyle(
                              color: Color(0xFF4CAF50),
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                  Text(l10n.settingsSensitivityHelp,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF8B949E),
                          )),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ── Spectrogram color scheme ───────────────────────────────────
          _SectionHeader(l10n.settingsSpectrogramTheme),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: SegmentedButton<SpectrogramColorTheme>(
                          segments: [
                            ButtonSegment<SpectrogramColorTheme>(
                              value: SpectrogramColorTheme.grayscale,
                              icon: const Icon(Icons.lens_blur_rounded),
                              label: Text(l10n.settingsSpectrogramThemeGrayscale),
                            ),
                            ButtonSegment<SpectrogramColorTheme>(
                              value: SpectrogramColorTheme.colored,
                              icon: const Icon(Icons.palette_rounded, color: Color(0xFF00BCD4)),
                              label: Text(l10n.settingsSpectrogramThemeColored),
                            ),
                          ],
                          selected: {settings.spectrogramTheme},
                          onSelectionChanged: (newSelection) {
                            if (newSelection.isNotEmpty) {
                              ref
                                  .read(settingsProvider.notifier)
                                  .updateSettings(settings.copyWith(
                                      spectrogramTheme: newSelection.first));
                            }
                          },
                          style: SegmentedButton.styleFrom(
                            selectedBackgroundColor: const Color(0xFF00BCD4).withOpacity(0.15),
                            selectedForegroundColor: const Color(0xFF00BCD4),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(l10n.settingsSpectrogramThemeHelp,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF8B949E),
                          )),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ── Species filter ─────────────────────────────────────────────
          _SectionHeader(l10n.settingsFilterMode),
          _FilterModeSelector(
            settings: settings,
            latCtrl: _latCtrl,
            lonCtrl: _lonCtrl,
            weekCtrl: _weekCtrl,
            thresholdCtrl: _thresholdCtrl,
            onChanged: (newFilter) => ref
                .read(settingsProvider.notifier)
                .updateSettings(settings.copyWith(filter: newFilter)),
            onUseGps: () => _useGps(context, settings),
            onManageSpeciesLists: () => _manageSpeciesLists(context),
            onPreviewSpecies: () => _showSpeciesPreviewModal(context, settings.filter),
          ),

          const SizedBox(height: 24),

          // ── Updates ────────────────────────────────────────────────────
          _SectionHeader(l10n.settingsUpdateSectionTitle),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FutureBuilder<PackageInfo>(
                    future: PackageInfo.fromPlatform(),
                    builder: (context, snapshot) {
                      final versionStr = snapshot.hasData
                          ? 'v${snapshot.data!.version} (Build ${snapshot.data!.buildNumber})'
                          : '...';
                      return Text(
                        '${l10n.settingsUpdateCurrentVersion}: $versionStr',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _updateUrlCtrl,
                    decoration: InputDecoration(
                      labelText: l10n.settingsUpdateUrlLabel,
                      labelStyle: const TextStyle(fontSize: 13),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    style: const TextStyle(fontSize: 13),
                    onChanged: (v) => ref
                        .read(settingsProvider.notifier)
                        .setUpdateUrl(v),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => UpdateService.checkForUpdates(
                      context,
                      settings.updateUrl,
                      showNoUpdateMessage: true,
                    ),
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: Text(l10n.settingsUpdateCheckButton),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      minimumSize: const Size.fromHeight(44),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _showSpeciesPreviewModal(BuildContext context, FilterSettings filter) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LocationSpeciesPreviewModal(filter: filter),
    );
  }

  Future<void> _useGps(BuildContext context, AppSettings settings) async {
    final l10n = AppLocalizations.of(context)!;
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.errorPermissionLocation)));
      }
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.errorPermissionLocation)));
        }
        return;
      }
    }

    final pos = await Geolocator.getCurrentPosition();
    final now = DateTime.now();
    final week = ((now.difference(DateTime(now.year, 1, 1)).inDays) / 7)
            .round()
            .clamp(1, 48);

    _latCtrl.text = pos.latitude.toStringAsFixed(4);
    _lonCtrl.text = pos.longitude.toStringAsFixed(4);
    _weekCtrl.text = week.toString();

    final newFilter = settings.filter.copyWith(
      latitude: pos.latitude,
      longitude: pos.longitude,
      week: week,
    );
    ref
        .read(settingsProvider.notifier)
        .updateSettings(settings.copyWith(filter: newFilter));
  }

  void _manageSpeciesLists(BuildContext context) {
    Navigator.pushNamed(context, '/custom_species_lists');
  }
}

// ─── Section header ───────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: const Color(0xFF4CAF50),
              letterSpacing: 0.5,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

// ─── Language selector ────────────────────────────────────────────────────

class _LanguageSelector extends StatelessWidget {
  final String current;
  final ValueChanged<String> onChanged;

  const _LanguageSelector({required this.current, required this.onChanged});

  static const _langs = [
    ('en', '🇬🇧 English'),
    ('it', '🇮🇹 Italiano'),
    ('fr', '🇫🇷 Français'),
    ('es', '🇪🇸 Español'),
    ('de', '🇩🇪 Deutsch'),
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: current,
            isExpanded: true,
            dropdownColor: Theme.of(context).colorScheme.surface,
            items: _langs
                .map((e) => DropdownMenuItem(
                    value: e.$1, child: Text(e.$2)))
                .toList(),
            onChanged: (v) => v != null ? onChanged(v) : null,
          ),
        ),
      ),
    );
  }
}

// ─── Filter mode selector ──────────────────────────────────────────────────

class _FilterModeSelector extends StatelessWidget {
  final AppSettings settings;
  final TextEditingController latCtrl;
  final TextEditingController lonCtrl;
  final TextEditingController weekCtrl;
  final TextEditingController thresholdCtrl;
  final ValueChanged<FilterSettings> onChanged;
  final VoidCallback onUseGps;
  final VoidCallback onManageSpeciesLists;
  final VoidCallback onPreviewSpecies;

  const _FilterModeSelector({
    required this.settings,
    required this.latCtrl,
    required this.lonCtrl,
    required this.weekCtrl,
    required this.thresholdCtrl,
    required this.onChanged,
    required this.onUseGps,
    required this.onManageSpeciesLists,
    required this.onPreviewSpecies,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final filter = settings.filter;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final orangeColor = isDark ? const Color(0xFFFF9800) : const Color(0xFFE65100);

    return Column(
      children: [
        // Mode radio group
        Card(
          child: Column(
            children: [
              _RadioTile(
                value: FilterMode.none,
                groupValue: filter.mode,
                title: l10n.settingsFilterNone,
                icon: Icons.filter_alt_off_outlined,
                onChanged: (v) => onChanged(filter.copyWith(mode: v)),
              ),
              const Divider(height: 1),
              _RadioTile(
                value: FilterMode.geographic,
                groupValue: filter.mode,
                title: l10n.settingsFilterGeo,
                icon: Icons.location_on_outlined,
                color: const Color(0xFF00BCD4),
                onChanged: (v) => onChanged(filter.copyWith(mode: v)),
              ),
              const Divider(height: 1),
              _RadioTile(
                value: FilterMode.speciesList,
                groupValue: filter.mode,
                title: l10n.settingsFilterList,
                icon: Icons.list_alt_rounded,
                color: orangeColor,
                onChanged: (v) => onChanged(filter.copyWith(mode: v)),
                trailing: filter.speciesList.isNotEmpty
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: orangeColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: orangeColor.withOpacity(0.3)),
                        ),
                        child: Text(
                          '${filter.speciesList.length}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: orangeColor,
                          ),
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),

        // Species List options
        if (filter.mode == FilterMode.speciesList)
          Card(
            margin: const EdgeInsets.only(top: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: orangeColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.playlist_add_check_rounded,
                          color: orangeColor,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              filter.speciesListName ?? l10n.customListsNoLists,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              filter.speciesList.isNotEmpty
                                  ? '${filter.speciesList.length} specie'
                                  : 'Nessuna specie selezionata',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: const Color(0xFF8B949E),
                                  ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: onManageSpeciesLists,
                        icon: const Icon(Icons.edit_note_rounded, size: 18),
                        label: Text(l10n.settingsSpeciesListsManage),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: orangeColor.withOpacity(0.15),
                          foregroundColor: orangeColor,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

        // Geographic options
        if (filter.mode == FilterMode.geographic)
          Card(
            margin: const EdgeInsets.only(top: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _CoordField(
                          controller: latCtrl,
                          label: l10n.settingsGeoLatitude,
                          onChanged: (v) => onChanged(filter.copyWith(
                              latitude: double.tryParse(v))),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _CoordField(
                          controller: lonCtrl,
                          label: l10n.settingsGeoLongitude,
                          onChanged: (v) => onChanged(filter.copyWith(
                              longitude: double.tryParse(v))),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _CoordField(
                    controller: weekCtrl,
                    label: l10n.settingsGeoWeek,
                    onChanged: (v) => onChanged(filter.copyWith(
                        week: int.tryParse(v)?.clamp(1, 48))),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: thresholdCtrl,
                          keyboardType: const TextInputType.numberWithOptions(
                              signed: false, decimal: true),
                          decoration: InputDecoration(
                            labelText: l10n.settingsLocationThreshold,
                            labelStyle: const TextStyle(fontSize: 13),
                            helperText: l10n.settingsLocationThresholdHelp,
                            helperStyle: const TextStyle(
                                color: Color(0xFF8B949E), fontSize: 11),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                          ),
                          style: const TextStyle(fontSize: 14),
                          onChanged: (v) {
                            final val = double.tryParse(v);
                            if (val != null && val >= 0.005 && val <= 0.99) {
                              onChanged(filter.copyWith(locationThreshold: val));
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onUseGps,
                          icon: const Icon(Icons.gps_fixed, size: 18),
                          label: Text(l10n.settingsGeoUseGps),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(44),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: filter.isGeoValid ? onPreviewSpecies : null,
                          icon: const Icon(Icons.preview_rounded, size: 18),
                          label: Text(l10n.settingsGeoPreviewAllowedSpecies),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00BCD4).withOpacity(0.15),
                            foregroundColor: const Color(0xFF00BCD4),
                            elevation: 0,
                            minimumSize: const Size.fromHeight(44),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            side: BorderSide(
                              color: const Color(0xFF00BCD4).withOpacity(filter.isGeoValid ? 0.5 : 0.1),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),


      ],
    );
  }
}

class _RadioTile extends StatelessWidget {
  final FilterMode value;
  final FilterMode groupValue;
  final String title;
  final IconData icon;
  final Color color;
  final ValueChanged<FilterMode> onChanged;
  final Widget? trailing;

  const _RadioTile({
    required this.value,
    required this.groupValue,
    required this.title,
    required this.icon,
    this.color = const Color(0xFF8B949E),
    required this.onChanged,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final selected = value == groupValue;
    return RadioListTile<FilterMode>(
      value: value,
      groupValue: groupValue,
      title: Row(
        children: [
          Icon(icon, size: 18, color: selected ? color : const Color(0xFF8B949E)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(title,
                style: TextStyle(
                    color: selected ? color : null,
                    fontWeight: selected ? FontWeight.w600 : null)),
          ),
          if (trailing != null) trailing!,
        ],
      ),
      activeColor: color,
      onChanged: (v) => v != null ? onChanged(v) : null,
    );
  }
}

class _CoordField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final ValueChanged<String> onChanged;

  const _CoordField({
    required this.controller,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(
          signed: true, decimal: true),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      style: const TextStyle(fontSize: 14),
      onChanged: onChanged,
    );
  }
}
