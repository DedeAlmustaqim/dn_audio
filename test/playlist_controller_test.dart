import 'package:flutter_test/flutter_test.dart';

import 'package:dn_audio/modules/playlist/controllers/playlist_controller.dart';
import 'package:dn_audio/modules/playlist/models/playlist.dart';
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
  int? deletedId;
  Exception? createError;

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
  Future<int> createPlaylist(String name) async {
    if (createError != null) throw createError!;
    createdNames.add(name);
    return 2;
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
