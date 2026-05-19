import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/custom_species_list.dart';
import '../services/database_service.dart';

class SpeciesListsNotifier extends AsyncNotifier<List<CustomSpeciesList>> {
  @override
  Future<List<CustomSpeciesList>> build() async {
    final dbLists = await DatabaseService.instance.getSpeciesLists();
    return dbLists.map((json) => CustomSpeciesList.fromJson(json)).toList();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final dbLists = await DatabaseService.instance.getSpeciesLists();
      return dbLists.map((json) => CustomSpeciesList.fromJson(json)).toList();
    });
  }

  Future<int> createList(String name) async {
    final id = await DatabaseService.instance.insertSpeciesList(name.trim());
    await refresh();
    return id;
  }

  Future<void> deleteList(int id) async {
    await DatabaseService.instance.deleteSpeciesList(id);
    await refresh();
  }

  Future<void> renameList(int id, String newName) async {
    await DatabaseService.instance.renameSpeciesList(id, newName.trim());
    await refresh();
  }

  Future<int> importList(String name, List<String> species) async {
    final id = await DatabaseService.instance.insertSpeciesList(name.trim());
    if (species.isNotEmpty) {
      await DatabaseService.instance.addSpeciesToList(id, species);
    }
    await refresh();
    return id;
  }

  Future<void> updateListItems(int listId, List<String> species) async {
    await DatabaseService.instance.setSpeciesListItems(listId, species);
    await refresh();
  }

  Future<List<String>> getListItems(int listId) async {
    return await DatabaseService.instance.getSpeciesListItems(listId);
  }
}

final speciesListsProvider =
    AsyncNotifierProvider<SpeciesListsNotifier, List<CustomSpeciesList>>(() {
  return SpeciesListsNotifier();
});
