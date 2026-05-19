import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:batch_audio_birding/l10n/app_localizations.dart';

import '../models/filter_settings.dart';
import '../services/meta_filter_service.dart';

class GeoSpeciesItem {
  final String label;
  final String scientificName;
  final String commonName;
  final double score;

  GeoSpeciesItem({
    required this.label,
    required this.scientificName,
    required this.commonName,
    required this.score,
  });
}

class LocationSpeciesPreviewModal extends StatefulWidget {
  final FilterSettings filter;

  const LocationSpeciesPreviewModal({
    super.key,
    required this.filter,
  });

  @override
  State<LocationSpeciesPreviewModal> createState() => _LocationSpeciesPreviewModalState();
}

class _LocationSpeciesPreviewModalState extends State<LocationSpeciesPreviewModal> {
  bool _loading = true;
  String _searchQuery = '';
  List<GeoSpeciesItem> _allItems = [];
  List<GeoSpeciesItem> _filteredItems = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAndCompute();
  }

  Future<void> _loadAndCompute() async {
    try {
      final langCode = Localizations.localeOf(context).languageCode;
      String labelsPath = 'assets/labels/labels_$langCode.txt';

      // 1. Load labels based on locale
      List<String> labels;
      try {
        final content = await rootBundle.loadString(labelsPath);
        labels = content.split('\n').where((l) => l.trim().isNotEmpty).toList();
      } catch (_) {
        try {
          final content = await rootBundle.loadString('assets/labels/labels_en.txt');
          labels = content.split('\n').where((l) => l.trim().isNotEmpty).toList();
        } catch (e) {
          throw Exception('Failed to load labels: $e');
        }
      }

      if (labels.isEmpty) {
        throw Exception('Labels list is empty');
      }

      // 2. Initialize MetaFilterService if not ready
      final metaFilter = MetaFilterService();
      if (!metaFilter.isReady) {
        await metaFilter.init('assets/model/BirdNET_GLOBAL_6K_V2.4_MData_Model_V2_FP16.tflite');
      }

      if (!metaFilter.isReady) {
        throw Exception('Geographic meta-model could not be initialized');
      }

      // 3. Compute geographic probabilities
      final rawScores = await metaFilter.getRawGeoScores(
        lat: widget.filter.latitude!,
        lon: widget.filter.longitude!,
        week: widget.filter.week!,
        numSpecies: labels.length,
      );

      if (rawScores == null || rawScores.length != labels.length) {
        throw Exception('Geographic scoring failed or mismatched labels size');
      }

      // 4. Parse scores and labels
      final items = <GeoSpeciesItem>[];
      for (int i = 0; i < labels.length; i++) {
        final score = rawScores[i];
        final label = labels[i];
        final parts = label.split('_');
        final scientific = parts.isNotEmpty ? parts[0] : label;
        final common = parts.length > 1 ? parts.sublist(1).join(' ') : scientific;

        items.add(GeoSpeciesItem(
          label: label,
          scientificName: scientific,
          commonName: common,
          score: score,
        ));
      }

      // 5. Filter based on locationThreshold
      final allowed = items.where((item) => item.score >= widget.filter.locationThreshold).toList();

      // 6. Sort descending by score
      allowed.sort((a, b) => b.score.compareTo(a.score));

      if (mounted) {
        setState(() {
          _allItems = allowed;
          _filteredItems = allowed;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query;
      if (query.trim().isEmpty) {
        _filteredItems = _allItems;
      } else {
        final lowerQuery = query.toLowerCase();
        _filteredItems = _allItems.where((item) {
          return item.commonName.toLowerCase().contains(lowerQuery) ||
              item.scientificName.toLowerCase().contains(lowerQuery);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final mediaQuery = MediaQuery.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    // Modal background and border/decorations
    final modalBgColor = isDark ? const Color(0xFF0D1117) : Colors.white;
    final borderColor = isDark ? const Color(0xFF30363D) : const Color(0xFFE9ECEF);
    final handleColor = isDark ? const Color(0xFF30363D) : const Color(0xFFDEE2E6);
    final titleColor = isDark ? const Color(0xFF4CAF50) : primaryColor;
    final closeIconColor = isDark ? const Color(0xFF8B949E) : const Color(0xFF495057);

    // Calculate max height (85% of screen height)
    final maxHeight = mediaQuery.size.height * 0.85;

    return Container(
      decoration: BoxDecoration(
        color: modalBgColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        border: Border(
          top: BorderSide(color: borderColor, width: 1),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: mediaQuery.viewInsets.bottom, // Prevent keyboard overlapping
      ),
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: handleColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.previewAllowedSpeciesTitle,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildMiniChip('Lat: ${widget.filter.latitude!.toStringAsFixed(2)}', isDark, borderColor),
                          const SizedBox(width: 6),
                          _buildMiniChip('Lon: ${widget.filter.longitude!.toStringAsFixed(2)}', isDark, borderColor),
                          const SizedBox(width: 6),
                          _buildMiniChip('${l10n.settingsGeoWeek.split(' ')[0]} ${widget.filter.week}', isDark, borderColor),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: closeIconColor),
                  onPressed: () => Navigator.pop(context),
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(8),
                ),
              ],
            ),
          ),

          Divider(color: borderColor, height: 1),

          // Main body
          Expanded(
            child: _buildContent(l10n, theme, isDark, borderColor),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniChip(String label, bool isDark, Color borderColor) {
    final chipBg = isDark ? const Color(0xFF21262D) : const Color(0xFFF1F3F5);
    final textColor = isDark ? const Color(0xFF8B949E) : const Color(0xFF495057);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: chipBg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: borderColor),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildContent(AppLocalizations l10n, ThemeData theme, bool isDark, Color borderColor) {
    final subtitleTextColor = isDark ? const Color(0xFF8B949E) : const Color(0xFF495057);

    if (_loading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00BCD4)),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.previewAllowedSpeciesLoading,
              style: TextStyle(color: subtitleTextColor, fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded, color: Color(0xFFF85149), size: 48),
              const SizedBox(height: 16),
              Text(
                'Error: $_error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFFF85149), fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    final searchBgColor = isDark ? const Color(0xFF161B22) : const Color(0xFFF1F3F5);
    final searchTextStyle = TextStyle(color: isDark ? Colors.white : const Color(0xFF212529), fontSize: 14);

    return Column(
      children: [
        // Search bar & Count info
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  onChanged: _onSearch,
                  decoration: InputDecoration(
                    hintText: l10n.previewAllowedSpeciesSearch,
                    hintStyle: TextStyle(color: subtitleTextColor, fontSize: 14),
                    prefixIcon: Icon(Icons.search_rounded, color: subtitleTextColor, size: 18),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear_rounded, color: subtitleTextColor, size: 18),
                            onPressed: () {
                              _onSearch('');
                              FocusScope.of(context).unfocus();
                            },
                          )
                        : null,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    fillColor: searchBgColor,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: isDark ? const Color(0xFF00BCD4) : const Color(0xFF00838F)),
                    ),
                  ),
                  style: searchTextStyle,
                ),
              ),
              const SizedBox(width: 12),
              // Allowed count pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: (isDark ? const Color(0xFF00BCD4) : const Color(0xFF00838F)).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: (isDark ? const Color(0xFF00BCD4) : const Color(0xFF00838F)).withOpacity(0.3)),
                ),
                child: Text(
                  '${_allItems.length}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? const Color(0xFF00BCD4) : const Color(0xFF00838F),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Species List
        Expanded(
          child: _filteredItems.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          color: subtitleTextColor,
                          size: 40,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.previewAllowedSpeciesEmpty,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: subtitleTextColor,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: _filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = _filteredItems[index];

                    // Beautiful color coding based on probability
                    Color badgeColor;
                    Color badgeBg;
                    if (item.score >= 0.50) {
                      badgeColor = isDark ? const Color(0xFF4CAF50) : const Color(0xFF2E7D32); // Green / Dark Green
                      badgeBg = badgeColor.withOpacity(0.12);
                    } else if (item.score >= 0.10) {
                      badgeColor = isDark ? const Color(0xFFFF9800) : const Color(0xFFE65100); // Orange / High-contrast Orange
                      badgeBg = badgeColor.withOpacity(0.12);
                    } else {
                      badgeColor = isDark ? const Color(0xFF00BCD4) : const Color(0xFF00838F); // Cyan / Dark Teal
                      badgeBg = badgeColor.withOpacity(0.12);
                    }

                    final cardBg = isDark ? const Color(0xFF161B22) : const Color(0xFFF8F9FA);
                    final cardBorder = isDark ? const Color(0xFF21262D) : const Color(0xFFE9ECEF);
                    final titleColor = isDark ? Colors.white : const Color(0xFF212529);

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: cardBg,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: cardBorder),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.commonName,
                                    style: TextStyle(
                                      color: titleColor,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.scientificName,
                                    style: TextStyle(
                                      color: subtitleTextColor,
                                      fontStyle: FontStyle.italic,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Score Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: badgeBg,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: badgeColor.withOpacity(0.3)),
                              ),
                              child: Text(
                                '${(item.score * 100).toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: badgeColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                        .animate(delay: Duration(milliseconds: (index * 15).clamp(0, 400)))
                        .fadeIn(duration: 200.ms)
                        .slideX(begin: 0.05, end: 0);
                  },
                ),
        ),
      ],
    );
  }
}
