import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class PlaylistDatabase {
  PlaylistDatabase._();

  static final PlaylistDatabase instance = PlaylistDatabase._();

  static const String _databaseName = 'dn_audio_playlists.db';
  static const int _databaseVersion = 1;

  Database? _database;

  Future<Database> get database async {
    final current = _database;
    if (current != null && current.isOpen) return current;

    final databasesPath = await getDatabasesPath();
    final databasePath = path.join(databasesPath, _databaseName);

    _database = await openDatabase(
      databasePath,
      version: _databaseVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _createSchema,
    );

    return _database!;
  }

  Future<void> _createSchema(Database db, int version) async {
    await db.transaction((txn) async {
      await txn.execute('''
        CREATE TABLE playlists (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL COLLATE NOCASE,
          created_at INTEGER NOT NULL,
          updated_at INTEGER NOT NULL
        )
      ''');

      await txn.execute('''
        CREATE TABLE playlist_songs (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          playlist_id INTEGER NOT NULL,
          song_id TEXT NOT NULL,
          title TEXT NOT NULL,
          artist TEXT NOT NULL,
          album TEXT NOT NULL,
          duration_ms INTEGER NOT NULL DEFAULT 0,
          content_uri TEXT NOT NULL,
          album_art_uri TEXT,
          size_bytes INTEGER NOT NULL DEFAULT 0,
          date_added INTEGER NOT NULL DEFAULT 0,
          position INTEGER NOT NULL,
          FOREIGN KEY (playlist_id)
            REFERENCES playlists (id)
            ON DELETE CASCADE,
          UNIQUE (playlist_id, content_uri)
        )
      ''');

      await txn.execute(
        'CREATE INDEX idx_playlist_songs_order '
        'ON playlist_songs (playlist_id, position)',
      );
      await txn.execute(
        'CREATE INDEX idx_playlist_songs_song_id '
        'ON playlist_songs (song_id)',
      );
      await txn.execute(
        'CREATE INDEX idx_playlists_name '
        'ON playlists (name)',
      );
    });
  }

  Future<void> close() async {
    final current = _database;
    _database = null;
    if (current != null && current.isOpen) {
      await current.close();
    }
  }
}
