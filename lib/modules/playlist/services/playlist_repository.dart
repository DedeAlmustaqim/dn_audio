import 'package:sqflite/sqflite.dart';

import '../models/playlist.dart';
import 'playlist_database.dart';

class PlaylistRepository {
  PlaylistRepository({PlaylistDatabase? database})
      : _database = database ?? PlaylistDatabase.instance;

  final PlaylistDatabase _database;

  Future<List<Playlist>> getPlaylists() async {
    final db = await _database.database;
    final rows = await db.rawQuery('''
      SELECT
        playlists.*,
        COUNT(playlist_songs.id) AS song_count
      FROM playlists
      LEFT JOIN playlist_songs
        ON playlist_songs.playlist_id = playlists.id
      GROUP BY playlists.id
      ORDER BY playlists.updated_at DESC, playlists.id DESC
    ''');

    return rows.map(Playlist.fromMap).toList(growable: false);
  }

  Future<int> createPlaylist(String name) async {
    final normalizedName = _validateName(name);
    final db = await _database.database;

    return db.transaction((txn) async {
      final existing = await txn.query(
        'playlists',
        columns: ['id'],
        where: 'name = ? COLLATE NOCASE',
        whereArgs: [normalizedName],
        limit: 1,
      );
      if (existing.isNotEmpty) {
        throw const PlaylistAlreadyExistsException();
      }

      final now = DateTime.now().millisecondsSinceEpoch;
      return txn.insert('playlists', {
        'name': normalizedName,
        'created_at': now,
        'updated_at': now,
      });
    });
  }

  Future<void> renamePlaylist(int id, String name) async {
    final normalizedName = _validateName(name);
    final db = await _database.database;

    await db.transaction((txn) async {
      final existing = await txn.query(
        'playlists',
        columns: ['id'],
        where: 'name = ? COLLATE NOCASE AND id != ?',
        whereArgs: [normalizedName, id],
        limit: 1,
      );
      if (existing.isNotEmpty) {
        throw const PlaylistAlreadyExistsException();
      }

      final changed = await txn.update(
        'playlists',
        {
          'name': normalizedName,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
      if (changed == 0) {
        throw const PlaylistNotFoundException();
      }
    });
  }

  Future<void> deletePlaylist(int id) async {
    final db = await _database.database;
    final deleted = await db.delete(
      'playlists',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (deleted == 0) {
      throw const PlaylistNotFoundException();
    }
  }

  String _validateName(String name) {
    final normalized = name.trim();
    if (normalized.isEmpty) {
      throw const InvalidPlaylistNameException();
    }
    if (normalized.length > 50) {
      throw const InvalidPlaylistNameException(
        'Playlist name must be 50 characters or fewer.',
      );
    }
    return normalized;
  }
}

class PlaylistAlreadyExistsException implements Exception {
  const PlaylistAlreadyExistsException();
}

class PlaylistNotFoundException implements Exception {
  const PlaylistNotFoundException();
}

class InvalidPlaylistNameException implements Exception {
  const InvalidPlaylistNameException([
    this.message = 'Enter a playlist name (maximum 50 characters).',
  ]);

  final String message;
}
