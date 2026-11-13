import 'dart:convert';

import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

import '../models/audio_library_preferences.dart';

class SettingsRepository {
  SettingsRepository();

  static const _databaseName = 'dn_audio_settings.db';
  static const _databaseVersion = 1;
  static const _tableName = 'app_settings';
  static const audioLibraryPreferencesKey = 'audio_library_preferences';

  Database? _database;

  Future<Database> get _db async {
    final current = _database;
    if (current != null && current.isOpen) return current;

    final directory = await getDatabasesPath();
    _database = await openDatabase(
      path.join(directory, _databaseName),
      version: _databaseVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_tableName (
            setting_key TEXT PRIMARY KEY,
            payload TEXT NOT NULL
          )
        ''');
      },
    );
    return _database!;
  }

  Future<AudioLibraryPreferences> loadAudioLibraryPreferences() async {
    final db = await _db;
    final rows = await db.query(
      _tableName,
      columns: ['payload'],
      where: 'setting_key = ?',
      whereArgs: [audioLibraryPreferencesKey],
      limit: 1,
    );

    if (rows.isEmpty) return AudioLibraryPreferences();

    try {
      final decoded = jsonDecode(rows.first['payload'] as String);
      if (decoded is Map<String, dynamic>) {
        return AudioLibraryPreferences.fromMap(decoded);
      }
    } catch (_) {
      // Invalid persisted data falls back to safe defaults.
    }
    return AudioLibraryPreferences();
  }

  Future<void> saveAudioLibraryPreferences(
    AudioLibraryPreferences preferences,
  ) async {
    final db = await _db;
    await db.insert(
      _tableName,
      {
        'setting_key': audioLibraryPreferencesKey,
        'payload': jsonEncode(preferences.toMap()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> close() async {
    final current = _database;
    _database = null;
    if (current != null && current.isOpen) await current.close();
  }
}
