import 'package:flutter_test/flutter_test.dart';

import 'package:dn_audio/modules/library/controllers/library_controller.dart';
import 'package:dn_audio/modules/library/models/song.dart';
import 'package:dn_audio/modules/library/services/audio_library_service.dart';

void main() {
  group('LibraryController', () {
    test('does not request permission until the library is opened', () async {
      final service = _FakeAudioLibraryService();
      final controller = LibraryController(service: service);

      expect(service.permissionChecks, 0);
      expect(service.permissionRequests, 0);
      expect(service.scanRequests, 0);

      await controller.ensureLoaded();

      expect(service.permissionChecks, 1);
      expect(service.permissionRequests, 1);
      expect(service.scanRequests, 1);
      expect(controller.hasPermission.value, isTrue);
    });

    test('loads the library only once through ensureLoaded', () async {
      final service = _FakeAudioLibraryService();
      final controller = LibraryController(service: service);

      await controller.ensureLoaded();
      await controller.ensureLoaded();

      expect(service.permissionChecks, 1);
      expect(service.permissionRequests, 1);
      expect(service.scanRequests, 1);
    });

    test('concurrent load requests share one scan operation', () async {
      final service = _FakeAudioLibraryService();
      final controller = LibraryController(service: service);

      final firstLoad = controller.ensureLoaded();
      final secondLoad = controller.ensureLoaded();

      expect(service.permissionChecks, 1);
      expect(service.permissionRequests, 0);
      expect(controller.isLoading.value, isTrue);

      await Future.wait([firstLoad, secondLoad]);

      expect(service.permissionChecks, 1);
      expect(service.permissionRequests, 1);
      expect(service.scanRequests, 1);
      expect(controller.isLoading.value, isFalse);
    });

    test('groups songs into albums and artists using MediaStore IDs', () async {
      final controller = LibraryController(service: _CollectionAudioLibraryService());

      await controller.ensureLoaded();

      expect(controller.albums, hasLength(2));
      expect(controller.artists, hasLength(2));
      expect(controller.albums.firstWhere((album) => album.id == 'album:10').songCount, 2);
      expect(controller.artists.firstWhere((artist) => artist.id == 'artist:20').songCount, 2);
      expect(controller.artists.firstWhere((artist) => artist.id == 'artist:20').albumCount, 1);
    });

    test('uses normalized album and artist labels when IDs are unavailable', () async {
      final controller = LibraryController(service: _FallbackCollectionAudioLibraryService());

      await controller.ensureLoaded();

      expect(controller.albums, hasLength(1));
      expect(controller.artists, hasLength(1));
    });

  });
}

class _CollectionAudioLibraryService extends AudioLibraryService {
  @override
  Future<bool> hasPermission() async => true;

  @override
  Future<List<Song>> getSongs() async => [
        _song('1', 'Track One', 'Artist One', 'Album One', 10, 20),
        _song('2', 'Track Two', 'Artist One', 'Album One', 10, 20),
        _song('3', 'Track Three', 'Artist Two', 'Album Two', 11, 21),
      ];
}

class _FallbackCollectionAudioLibraryService extends AudioLibraryService {
  @override
  Future<bool> hasPermission() async => true;

  @override
  Future<List<Song>> getSongs() async => [
        _song('1', 'Track One', 'Artist One', 'Album One', null, null),
        _song('2', 'Track Two', ' artist one ', ' album one ', null, null),
      ];
}

Song _song(
  String id,
  String title,
  String artist,
  String album,
  int? albumId,
  int? artistId,
) =>
    Song(
      id: id,
      title: title,
      artist: artist,
      album: album,
      durationMs: 60000,
      contentUri: 'content://media/$id',
      albumArtUri: null,
      sizeBytes: 1024,
      dateAdded: 1,
      albumId: albumId,
      artistId: artistId,
    );

class _FakeAudioLibraryService extends AudioLibraryService {
  int permissionChecks = 0;
  int permissionRequests = 0;
  int scanRequests = 0;

  @override
  Future<bool> hasPermission() async {
    permissionChecks++;
    return false;
  }

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    return true;
  }

  @override
  Future<List<Song>> getSongs() async {
    scanRequests++;
    return const [];
  }
}
