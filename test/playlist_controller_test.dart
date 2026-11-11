import 'package:flutter_test/flutter_test.dart';

import 'package:dn_audio/modules/library/models/song.dart';
import 'package:dn_audio/modules/playlist/controllers/playlist_controller.dart';
import 'package:dn_audio/modules/playlist/models/playlist.dart';
import 'package:dn_audio/modules/playlist/models/playlist_song.dart';
import 'package:dn_audio/modules/playlist/services/playlist_repository.dart';

void main() {
  group('PlaylistController', () {
    test('loads playlists on initialization', () async {
      final repository = _FakePlaylistRepository();
      final controller = PlaylistController(repository: repository);

      await Future<void>.delayed(Duration.zero);

      expect(repository.loadCalls, 1);
      expect(controller.playlists, hasLength(1));
      expect(controller.playlists.first.name, 'Favorites');
      controller.onClose();
    });

    test('creates playlist and reloads the list', () async {
      final repository = _FakePlaylistRepository();
      final controller = PlaylistController(repository: repository);

      await Future<void>.delayed(Duration.zero);
      final result = await controller.createPlaylist('Road Trip');

      expect(result, isTrue);
      expect(repository.createdNames, ['Road Trip']);
      expect(repository.loadCalls, 2);
      controller.onClose();
    });

    test('shows validation error for duplicate playlist names', () async {
      final repository = _FakePlaylistRepository()
        ..createError = const PlaylistAlreadyExistsException();
      final controller = PlaylistController(repository: repository);

      await Future<void>.delayed(Duration.zero);
      final result = await controller.createPlaylist('Favorites');

      expect(result, isFalse);
      expect(
        controller.errorMessage.value,
        'A playlist with this name already exists.',
      );
      controller.onClose();
    });

    test('adds a song to the selected playlist', () async {
      final repository = _FakePlaylistRepository();
      final controller = PlaylistController(repository: repository);
      const song = Song(
        id: 'song-1',
        title: 'Test Track',
        artist: 'Test Artist',
        album: 'Test Album',
        durationMs: 180000,
        contentUri: 'content://media/audio/1',
        albumArtUri: null,
        sizeBytes: 1000,
        dateAdded: 1,
      );

      await Future<void>.delayed(Duration.zero);
      final result = await controller.addSongToPlaylist(1, song);

      expect(result, isTrue);
      expect(repository.addedSong, (1, song));
      expect(repository.loadCalls, 2);
      controller.onClose();
    });

    test('shows an error when a song is already in the playlist', () async {
      final repository = _FakePlaylistRepository()
        ..addSongError = const PlaylistSongAlreadyExistsException();
      final controller = PlaylistController(repository: repository);
      const song = Song(
        id: 'song-1',
        title: 'Test Track',
        artist: 'Test Artist',
        album: 'Test Album',
        durationMs: 180000,
        contentUri: 'content://media/audio/1',
        albumArtUri: null,
        sizeBytes: 1000,
        dateAdded: 1,
      );

      await Future<void>.delayed(Duration.zero);
      final result = await controller.addSongToPlaylist(1, song);

      expect(result, isFalse);
      expect(
        controller.errorMessage.value,
        'This song is already in the playlist.',
      );
      controller.onClose();
    });

    test('loads songs for a playlist', () async {
      final repository = _FakePlaylistRepository();
      final controller = PlaylistController(repository: repository);
      await Future<void>.delayed(Duration.zero);
      final songs = await controller.loadPlaylistSongs(1);
      expect(songs, hasLength(1));
      expect(controller.playlistSongs[1], hasLength(1));
      controller.onClose();
    });

    test('propagates playlist song loading errors', () async {
      final repository = _FakePlaylistRepository()
        ..playlistSongsError = Exception('Database unavailable');
      final controller = PlaylistController(repository: repository);

      await Future<void>.delayed(Duration.zero);
      await expectLater(
        controller.loadPlaylistSongs(1),
        throwsA(isA<Exception>()),
      );

      expect(
        controller.errorMessage.value,
        'Unable to load songs in this playlist.',
      );
      controller.onClose();
    });

    test('removes a song and refreshes playlist songs', () async {
      final repository = _FakePlaylistRepository();
      final controller = PlaylistController(repository: repository);
      await Future<void>.delayed(Duration.zero);
      final result = await controller.removeSongFromPlaylist(1, 'content://media/audio/1');
      expect(result, isTrue);
      expect(repository.removedSong, (1, 'content://media/audio/1'));
      controller.onClose();
    });

    test('renames and deletes selected playlist', () async {
      final repository = _FakePlaylistRepository();
      final controller = PlaylistController(repository: repository);

      await Future<void>.delayed(Duration.zero);
      expect(await controller.renamePlaylist(1, 'Chill'), isTrue);
      expect(repository.renamed, (1, 'Chill'));
      expect(await controller.deletePlaylist(1), isTrue);
      expect(repository.deletedId, 1);
      controller.onClose();
    });
  });
}

class _FakePlaylistRepository extends PlaylistRepository {
  int loadCalls = 0;
  final createdNames = <String>[];
  (int, String)? renamed;
  (int, Song)? addedSong;
  (int, String)? removedSong;
  int? deletedId;
  Exception? createError;
  Exception? addSongError;
  Exception? playlistSongsError;
  final testSong = const Song(id: 'song-1', title: 'Test Track', artist: 'Test Artist', album: 'Test Album', durationMs: 180000, contentUri: 'content://media/audio/1', albumArtUri: null, sizeBytes: 1000, dateAdded: 1);

  @override
  Future<List<Playlist>> getPlaylists() async {
    loadCalls++;
    return const [
      Playlist(
        id: 1,
        name: 'Favorites',
        createdAt: 1,
        updatedAt: 1,
        songCount: 0,
      ),
    ];
  }

  @override
  Future<List<PlaylistSong>> getPlaylistSongs(int playlistId) async {
    if (playlistSongsError != null) throw playlistSongsError!;
    return [
      PlaylistSong(playlistId: playlistId, song: testSong, position: 0),
    ];
  }

  @override
  Future<int> createPlaylist(String name) async {
    if (createError != null) throw createError!;
    createdNames.add(name);
    return 2;
  }

  @override
  Future<void> addSongToPlaylist(int playlistId, Song song) async {
    if (addSongError != null) throw addSongError!;
    addedSong = (playlistId, song);
  }

  @override
  Future<void> removeSongFromPlaylist(int playlistId, String contentUri) async {
    removedSong = (playlistId, contentUri);
  }

  @override
  Future<void> renamePlaylist(int id, String name) async {
    renamed = (id, name);
  }

  @override
  Future<void> deletePlaylist(int id) async {
    deletedId = id;
  }
}
