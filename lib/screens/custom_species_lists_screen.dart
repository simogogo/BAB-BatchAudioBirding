import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:batch_audio_birding/l10n/app_localizations.dart';

import '../models/custom_species_list.dart';
import '../providers/settings_provider.dart';
import '../providers/species_lists_provider.dart';
import '../services/species_list_exporter.dart';

class CustomSpeciesListsScreen extends ConsumerStatefulWidget {
  const CustomSpeciesListsScreen({super.key});

  @override
  ConsumerState<CustomSpeciesListsScreen> createState() =>
      _CustomSpeciesListsScreenState();
}

class _CustomSpeciesListsScreenState extends ConsumerState<CustomSpeciesListsScreen> {
  Color get _orangeColor {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFFFF9800) : const Color(0xFFE65100);
  }

  int? _editingListId;
  String? _editingListName;
  final TextEditingController _listNameCtrl = TextEditingController();

  // Species checklist search and selections
  List<String> _allLabels = [];
  List<String> _filteredLabels = [];
  final Set<String> _selectedSpecies = {};
  bool _isLoadingLabels = false;
  final TextEditingController _searchCtrl = TextEditingController();
  bool _showOnlySelected = false;

  @override
  void dispose() {
    _listNameCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  // ─── Vocabulary & Selection Loader ────────────────────────────────────────

  Future<void> _loadLabelsAndItems(int listId, String name) async {
    setState(() {
      _isLoadingLabels = true;
      _editingListId = listId;
      _editingListName = name;
      _listNameCtrl.text = name;
      _selectedSpecies.clear();
      _searchCtrl.clear();
      _filteredLabels.clear();
      _showOnlySelected = false;
    });

    try {
      // 1. Load active localized labels
      final settings = ref.read(settingsProvider).valueOrNull ?? const AppSettings();
      final langCode = settings.languageCode;
      String labelsPath = 'assets/labels/labels_$langCode.txt';

      List<String> labels;
      try {
        final content = await rootBundle.loadString(labelsPath);
        labels = content.split('\n').where((l) => l.trim().isNotEmpty).toList();
      } catch (_) {
        // Fallback to English
        final content = await rootBundle.loadString('assets/labels/labels_en.txt');
        labels = content.split('\n').where((l) => l.trim().isNotEmpty).toList();
      }

      // 2. Load checked items from SQLite (scientific names)
      final items = await ref
          .read(speciesListsProvider.notifier)
          .getListItems(listId);

      // Create a map from scientific name to localized full label from active asset
      final Map<String, String> scientificToFull = {};
      for (var label in labels) {
        final parts = label.split('_');
        if (parts.isNotEmpty) {
          scientificToFull[parts[0].trim().toLowerCase()] = label;
        }
      }

      final Set<String> localizedSelected = {};
      for (var scientific in items) {
        final fullLabel = scientificToFull[scientific.trim().toLowerCase()];
        if (fullLabel != null) {
          localizedSelected.add(fullLabel);
        } else {
          // Fallback if not found in active labels
          localizedSelected.add(scientific);
        }
      }

      if (mounted) {
        setState(() {
          _allLabels = labels;
          _filteredLabels = labels;
          _selectedSpecies.addAll(localizedSelected);
          _isLoadingLabels = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingLabels = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load species: $e')),
        );
      }
    }
  }

  void _filterSpecies(String query) {
    final q = query.toLowerCase().trim();
    setState(() {
      _filteredLabels = _allLabels.where((label) {
        if (_showOnlySelected && !_selectedSpecies.contains(label)) {
          return false;
        }
        if (q.isEmpty) return true;
        final parts = label.split('_');
        final scientific = parts.isNotEmpty ? parts[0].toLowerCase() : '';
        final common = parts.length > 1 ? parts.sublist(1).join(' ').toLowerCase() : '';
        return scientific.contains(q) || common.contains(q);
      }).toList();
    });
  }

  // ─── SQLite Actions ────────────────────────────────────────────────────────

  Future<void> _handleCreateList(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final nameCtrl = TextEditingController();

    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.customListsCreate),
        content: TextField(
          controller: nameCtrl,
          decoration: InputDecoration(
            hintText: l10n.customListsNameLabel,
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: _orangeColor),
            ),
          ),
          autofocus: true,
          textCapitalization: TextCapitalization.words,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.commonCancel, style: const TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, nameCtrl.text),
            child: Text(l10n.commonOk, style: TextStyle(color: _orangeColor)),
          ),
        ],
      ),
    );

    if (name == null || name.trim().isEmpty) return;

    try {
      final id = await ref
          .read(speciesListsProvider.notifier)
          .createList(name.trim());
      await _loadLabelsAndItems(id, name.trim());
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating list: $e')),
        );
      }
    }
  }

  Future<void> _handleImportList(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final nameCtrl = TextEditingController();

    // 1. Enter list name
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.customListsImport),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.customListsImportHint,
              style: const TextStyle(fontSize: 13, color: Color(0xFF8B949E)),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameCtrl,
              decoration: InputDecoration(
                hintText: l10n.customListsNameLabel,
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: _orangeColor),
                ),
              ),
              autofocus: true,
              textCapitalization: TextCapitalization.words,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.commonCancel, style: const TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, nameCtrl.text),
            child: Text(l10n.commonOk, style: TextStyle(color: _orangeColor)),
          ),
        ],
      ),
    );

    if (name == null || name.trim().isEmpty) return;

    // 2. Pick TXT File
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['txt'],
    );
    if (result == null || result.files.single.path == null) return;

    try {
      final path = result.files.single.path!;
      final lines = await File(path).readAsLines();
      final species = lines
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty && !l.startsWith('#'))
          .toList();

      final id = await ref
          .read(speciesListsProvider.notifier)
          .importList(name.trim(), species);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.customListsImportSuccess(species.length),
            ),
            backgroundColor: const Color(0xFF4CAF50),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error importing file: $e')),
        );
      }
    }
  }

  Future<void> _handleDeleteList(
      BuildContext context, CustomSpeciesList list) async {
    final l10n = AppLocalizations.of(context)!;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.customListsDelete),
        content: Text('${l10n.customListsDeleteConfirm}\n\n"${list.name}"'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel, style: const TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.customListsDelete, style: const TextStyle(color: Color(0xFFF85149))),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      // If the deleted list is the active filter, clean up settings filter
      final settings = ref.read(settingsProvider).valueOrNull;
      if (settings != null && settings.filter.speciesListId == list.id) {
        final newFilter = settings.filter.copyWith(
          speciesList: [],
          speciesListId: null,
          speciesListName: null,
        );
        await ref
            .read(settingsProvider.notifier)
            .updateSettings(settings.copyWith(filter: newFilter));
      }

      await ref.read(speciesListsProvider.notifier).deleteList(list.id);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting list: $e')),
        );
      }
    }
  }

  Future<void> _handleSaveList() async {
    if (_editingListId == null) return;
    final id = _editingListId!;
    final name = _listNameCtrl.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.customListsNameError)),
      );
      return;
    }

    try {
      // 1. Update list rename in DB
      if (name != _editingListName) {
        await ref.read(speciesListsProvider.notifier).renameList(id, name);
      }

      // 2. Save items in DB (extract scientific names)
      final items = _selectedSpecies.toList();
      final scientificItems = items.map((s) => s.split('_')[0].trim()).toList();
      await ref
          .read(speciesListsProvider.notifier)
          .updateListItems(id, scientificItems);

      // 3. If this list is currently the active analysis filter, sync settings state!
      final settings = ref.read(settingsProvider).valueOrNull;
      if (settings != null && settings.filter.speciesListId == id) {
        final newFilter = settings.filter.copyWith(
          speciesList: scientificItems,
          speciesListName: name,
        );
        await ref
            .read(settingsProvider.notifier)
            .updateSettings(settings.copyWith(filter: newFilter));
      }

      if (mounted) {
        setState(() {
          _editingListId = null;
          _editingListName = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Salvataggio completato!'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore nel salvataggio: $e')),
        );
      }
    }
  }

  Future<void> _handleSelectFilter(CustomSpeciesList list) async {
    try {
      final items = await ref
          .read(speciesListsProvider.notifier)
          .getListItems(list.id);

      final settings = ref.read(settingsProvider).valueOrNull;
      if (settings != null) {
        final newFilter = settings.filter.copyWith(
          speciesList: items,
          speciesListId: list.id,
          speciesListName: list.name,
        );
        await ref
            .read(settingsProvider.notifier)
            .updateSettings(settings.copyWith(filter: newFilter));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lista "${list.name}" impostata come filtro attivo!'),
              backgroundColor: const Color(0xFF4CAF50),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore nella selezione: $e')),
        );
      }
    }
  }

  Future<void> _handleExportList(BuildContext context, int listId, String listName) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      final items = await ref
          .read(speciesListsProvider.notifier)
          .getListItems(listId);

      if (items.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.customListsExportEmptyError),
              backgroundColor: const Color(0xFFF85149),
            ),
          );
        }
        return;
      }

      final path = await SpeciesListExporter.exportList(listName, items);
      final sanitizedName = listName.replaceAll(RegExp(r'[^\w\s\-]'), '').replaceAll(RegExp(r'\s+'), '_');
      final success = await SpeciesListExporter.save(path, '${sanitizedName}_species_list.txt');
      
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.customListsExportSuccess),
            backgroundColor: const Color(0xFF4CAF50),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.customListsExportError}: $e')),
        );
      }
    }
  }

  Future<void> _handleExportCurrentList(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final name = _listNameCtrl.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.customListsNameError)),
      );
      return;
    }

    final items = _selectedSpecies.toList();
    final scientificItems = items.map((s) => s.split('_')[0].trim()).toList();

    if (scientificItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.customListsExportEmptyError),
          backgroundColor: const Color(0xFFF85149),
        ),
      );
      return;
    }

    try {
      final path = await SpeciesListExporter.exportList(name, scientificItems);
      final sanitizedName = name.replaceAll(RegExp(r'[^\w\s\-]'), '').replaceAll(RegExp(r'\s+'), '_');
      final success = await SpeciesListExporter.save(path, '${sanitizedName}_species_list.txt');
      
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.customListsExportSuccess),
            backgroundColor: const Color(0xFF4CAF50),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.customListsExportError}: $e')),
        );
      }
    }
  }

  // ─── Build Methods ─────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_editingListId != null) {
      return _buildDetailView(context);
    }

    return _buildMasterView(context);
  }

  // ─── Master Dashboard View ──────────────────────────────────────────────────

  Widget _buildMasterView(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final listsAsync = ref.watch(speciesListsProvider);
    final settings = ref.watch(settingsProvider).valueOrNull ?? const AppSettings();
    final activeListId = settings.filter.speciesListId;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.customListsTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file_rounded),
            tooltip: l10n.customListsImport,
            onPressed: () => _handleImportList(context),
          ),
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: l10n.customListsCreate,
            onPressed: () => _handleCreateList(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: listsAsync.when(
        data: (lists) {
          if (lists.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.playlist_add_check_rounded,
                    size: 64,
                    color: _orangeColor.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.customListsNoLists,
                    style: const TextStyle(color: Color(0xFF8B949E), fontSize: 15),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _handleCreateList(context),
                    icon: const Icon(Icons.add_rounded),
                    label: Text(l10n.customListsCreate),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _orangeColor,
                      foregroundColor: isDark ? Colors.black : Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: lists.length,
            itemBuilder: (context, index) {
              final list = lists[index];
              final isActive = list.id == activeListId;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        list.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (isActive) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF4CAF50).withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: const Color(0xFF4CAF50).withOpacity(0.3),
                                          ),
                                        ),
                                        child: Text(
                                          l10n.customListsActive,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF4CAF50),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${list.speciesCount} specie',
                                  style: const TextStyle(
                                    color: Color(0xFF8B949E),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.download_rounded,
                              color: _orangeColor,
                              size: 22,
                            ),
                            tooltip: l10n.customListsExport,
                            onPressed: () => _handleExportList(context, list.id, list.name),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline_rounded,
                              color: Color(0xFFF85149),
                              size: 22,
                            ),
                            onPressed: () => _handleDeleteList(context, list),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () => _loadLabelsAndItems(list.id, list.name),
                            icon: const Icon(Icons.edit_rounded, size: 16),
                            label: Text(l10n.customListsAddSpecies),
                            style: TextButton.styleFrom(
                              foregroundColor: _orangeColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (!isActive)
                            FilledButton.icon(
                              onPressed: () => _handleSelectFilter(list),
                              icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
                              label: Text(l10n.customListsUseAsFilter),
                              style: FilledButton.styleFrom(
                                backgroundColor: const Color(0xFF4CAF50),
                                foregroundColor: Colors.black,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Errore: $err')),
      ),
    );
  }

  // ─── Detail Editing View ────────────────────────────────────────────────────

  Widget _buildDetailView(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            setState(() {
              _editingListId = null;
              _editingListName = null;
            });
          },
        ),
        title: Text(l10n.customListsEdit),
        actions: [
          IconButton(
            icon: Icon(Icons.download_rounded, color: _orangeColor),
            tooltip: l10n.customListsExport,
            onPressed: () => _handleExportCurrentList(context),
          ),
          const SizedBox(width: 4),
          TextButton.icon(
            onPressed: _handleSaveList,
            icon: const Icon(Icons.save_rounded, size: 20, color: Color(0xFF4CAF50)),
            label: const Text(
              'Salva',
              style: TextStyle(
                color: Color(0xFF4CAF50),
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoadingLabels
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Caricamento elenco specie...')
                ],
              ),
            )
          : Column(
              children: [
                // 1. List Name Field
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: TextField(
                    controller: _listNameCtrl,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      labelText: l10n.customListsNameLabel,
                      labelStyle: TextStyle(color: _orangeColor, fontSize: 14),
                      prefixIcon: Icon(Icons.edit_rounded, color: _orangeColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF30363D)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: _orangeColor, width: 1.5),
                      ),
                    ),
                  ),
                ),

                // 2. Search Field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: _filterSpecies,
                    decoration: InputDecoration(
                      hintText: l10n.customListsSearchPlaceholder,
                      prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, color: Colors.grey),
                              onPressed: () {
                                _searchCtrl.clear();
                                _filterSpecies('');
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF30363D)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: _orangeColor, width: 1.5),
                      ),
                    ),
                  ),
                ),

                // 3. Selection Summary Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: _showOnlySelected,
                            activeColor: _orangeColor,
                            checkColor: Colors.black,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            onChanged: (bool? checked) {
                              setState(() {
                                _showOnlySelected = checked ?? false;
                                _filterSpecies(_searchCtrl.text);
                              });
                            },
                          ),
                          Text(
                            '${l10n.customListsOnlySelected} (${_selectedSpecies.length})',
                            style: TextStyle(
                              color: _orangeColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: Text(
                          'Risultati: ${_filteredLabels.length}',
                          style: const TextStyle(color: Color(0xFF8B949E), fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // 4. Checklist
                Expanded(
                  child: _filteredLabels.isEmpty
                      ? const Center(
                          child: Text(
                            'Nessuna specie trovata',
                            style: TextStyle(color: Color(0xFF8B949E)),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: _filteredLabels.length,
                          itemBuilder: (context, index) {
                            final label = _filteredLabels[index];
                            final isChecked = _selectedSpecies.contains(label);

                            // Parse scientific & common names from standard BirdNET labels
                            final parts = label.split('_');
                            final scientific = parts.isNotEmpty ? parts[0].trim() : label;
                            final common = parts.length > 1
                                ? parts.sublist(1).join(' ').trim()
                                : '';

                            return CheckboxListTile(
                              value: isChecked,
                              activeColor: _orangeColor,
                              checkColor: Colors.black,
                              title: Text(
                                common.isNotEmpty ? common : scientific,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              subtitle: common.isNotEmpty
                                  ? Text(
                                      scientific,
                                      style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        fontSize: 13,
                                        color: const Color(0xFF4CAF50).withOpacity(0.8),
                                      ),
                                    )
                                  : null,
                              onChanged: (bool? checked) {
                                setState(() {
                                  if (checked == true) {
                                    _selectedSpecies.add(label);
                                  } else {
                                    _selectedSpecies.remove(label);
                                  }
                                  if (_showOnlySelected) {
                                    _filterSpecies(_searchCtrl.text);
                                  }
                                });
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
