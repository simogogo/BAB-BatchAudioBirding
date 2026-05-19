import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:developer' as dev;

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('batch_audio_birding.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    dev.log('DatabaseService: Initializing SQLite database at $path');

    return await openDatabase(
      path,
      version: 1,
      onConfigure: _onConfigure,
      onCreate: _createDB,
    );
  }

  Future<void> _onConfigure(Database db) async {
    // Enable cascading deletes on foreign key constraints
    await db.execute('PRAGMA foreign_keys = ON');
    dev.log('DatabaseService: Foreign keys enabled');
  }

  Future<void> _createDB(Database db, int version) async {
    dev.log('DatabaseService: Creating tables...');

    await db.execute('''
      CREATE TABLE species_lists (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      )
    ''');

    await db.execute('''
      CREATE TABLE species_list_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        list_id INTEGER NOT NULL,
        species_name TEXT NOT NULL,
        FOREIGN KEY (list_id) REFERENCES species_lists (id) ON DELETE CASCADE,
        UNIQUE (list_id, species_name)
      )
    ''');

    dev.log('DatabaseService: Tables created successfully');
  }

  // ─── Species Lists Operations ──────────────────────────────────────────────

  Future<List<Map<String, dynamic>>> getSpeciesLists() async {
    final db = await database;
    // Returns id, name, and species_count
    return await db.rawQuery('''
      SELECT sl.id, sl.name, COUNT(sli.id) as species_count
      FROM species_lists sl
      LEFT JOIN species_list_items sli ON sl.id = sli.list_id
      GROUP BY sl.id, sl.name
      ORDER BY sl.name ASC
    ''');
  }

  Future<int> insertSpeciesList(String name) async {
    final db = await database;
    return await db.insert('species_lists', {'name': name});
  }

  Future<void> renameSpeciesList(int id, String newName) async {
    final db = await database;
    await db.update(
      'species_lists',
      {'name': newName},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteSpeciesList(int id) async {
    final db = await database;
    await db.delete(
      'species_lists',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ─── Species List Items Operations ─────────────────────────────────────────

  Future<List<String>> getSpeciesListItems(int listId) async {
    final db = await database;
    final res = await db.query(
      'species_list_items',
      columns: ['species_name'],
      where: 'list_id = ?',
      whereArgs: [listId],
      orderBy: 'species_name ASC',
    );
    return res.map((r) => r['species_name'] as String).toList();
  }

  Future<void> addSpeciesToList(int listId, List<String> species) async {
    final db = await database;
    await db.transaction((txn) async {
      for (var s in species) {
        if (s.trim().isEmpty) continue;
        final parts = s.split('_');
        final scientificName = parts[0].trim();
        if (scientificName.isEmpty) continue;
        await txn.insert(
          'species_list_items',
          {
            'list_id': listId,
            'species_name': scientificName,
          },
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
    });
  }

  Future<void> setSpeciesListItems(int listId, List<String> species) async {
    final db = await database;
    await db.transaction((txn) async {
      // Clear existing
      await txn.delete(
        'species_list_items',
        where: 'list_id = ?',
        whereArgs: [listId],
      );
      // Insert new ones
      for (var s in species) {
        if (s.trim().isEmpty) continue;
        final parts = s.split('_');
        final scientificName = parts[0].trim();
        if (scientificName.isEmpty) continue;
        await txn.insert(
          'species_list_items',
          {
            'list_id': listId,
            'species_name': scientificName,
          },
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }
    });
  }

  Future<void> removeSpeciesFromList(int listId, String speciesName) async {
    final db = await database;
    await db.delete(
      'species_list_items',
      where: 'list_id = ? AND species_name = ?',
      whereArgs: [listId, speciesName],
    );
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
      dev.log('DatabaseService: Closed database');
    }
  }
}
