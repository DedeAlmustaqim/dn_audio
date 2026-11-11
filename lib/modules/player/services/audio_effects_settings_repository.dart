import 'dart:convert';

import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class AudioEffectsSettings {
  const AudioEffectsSettings({
    this.equalizerEnabled = false,
    this.selectedPresetId = 'flat',
    this.bandLevels = const {},
    this.bassBoostEnabled = false,
    this.bassBoostStrength = 0,
    this.virtualizerEnabled = false,
    this.virtualizerStrength = 0,
  });

  final bool equalizerEnabled;
  final String selectedPresetId;
  final Map<int, int> bandLevels;
  final bool bassBoostEnabled;
  final int bassBoostStrength;
  final bool virtualizerEnabled;
  final int virtualizerStrength;

  Map<String, dynamic> toMap() => {
        'equalizerEnabled': equalizerEnabled,
        'selectedPresetId': selectedPresetId,
        'bandLevels': {
          for (final entry in bandLevels.entries)
            entry.key.toString(): entry.value,
        },
        'bassBoostEnabled': bassBoostEnabled,
        'bassBoostStrength': bassBoostStrength,
        'virtualizerEnabled': virtualizerEnabled,
        'virtualizerStrength': virtualizerStrength,
      };

  factory AudioEffectsSettings.fromMap(Map<String, dynamic> map) {
    final rawBands = map['bandLevels'];
    final bands = <int, int>{};
    if (rawBands is Map) {
      for (final entry in rawBands.entries) {
        final index = int.tryParse(entry.key.toString());
        final value = entry.value;
        if (index != null && value is num) bands[index] = value.toInt();
      }
    }

    return AudioEffectsSettings(
      equalizerEnabled: map['equalizerEnabled'] == true,
      selectedPresetId: map['selectedPresetId']?.toString() ?? 'flat',
      bandLevels: bands,
      bassBoostEnabled: map['bassBoostEnabled'] == true,
      bassBoostStrength: (map['bassBoostStrength'] as num?)?.toInt() ?? 0,
      virtualizerEnabled: map['virtualizerEnabled'] == true,
      virtualizerStrength: (map['virtualizerStrength'] as num?)?.toInt() ?? 0,
    );
  }
}

class AudioEffectsSettingsRepository {
  AudioEffectsSettingsRepository();

  static const _databaseName = 'dn_audio_effects.db';
  static const _databaseVersion = 1;
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
          CREATE TABLE audio_effects_settings (
            id INTEGER PRIMARY KEY CHECK (id = 1),
            payload TEXT NOT NULL
          )
        ''');
      },
    );
    return _database!;
  }

  Future<AudioEffectsSettings> load() async {
    final db = await _db;
    final rows = await db.query(
      'audio_effects_settings',
      columns: ['payload'],
      where: 'id = 1',
      limit: 1,
    );
    if (rows.isEmpty) return const AudioEffectsSettings();

    try {
      final decoded = jsonDecode(rows.first['payload'] as String);
      if (decoded is Map<String, dynamic>) {
        return AudioEffectsSettings.fromMap(decoded);
      }
    } catch (_) {
      // Corrupt preferences fall back to safe defaults.
    }
    return const AudioEffectsSettings();
  }

  Future<void> save(AudioEffectsSettings settings) async {
    final db = await _db;
    await db.insert(
      'audio_effects_settings',
      {'id': 1, 'payload': jsonEncode(settings.toMap())},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> close() async {
    final current = _database;
    _database = null;
    if (current != null && current.isOpen) await current.close();
  }
}
