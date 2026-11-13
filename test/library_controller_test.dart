import 'package:flutter_test/flutter_test.dart';

import 'package:dn_audio/modules/library/controllers/library_controller.dart';
import 'package:dn_audio/modules/library/models/song.dart';
import 'package:dn_audio/modules/library/services/audio_library_service.dart';
import 'package:dn_audio/modules/settings/models/audio_library_preferences.dart';
import 'package:dn_audio/modules/settings/services/settings_repository.dart';

void main() {
  group('LibraryController', () {
    test('does not request permission until the library is opened', () async {
      final service = _FakeAudioLibraryService();
      final controller = LibraryController(
        service: service,
        settingsRepository: _FakeSettingsRepository(),
      );

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
      final controller = LibraryController(
        service: service,
        settingsRepository: _FakeSettingsRepository(),
      );

      await controller.ensureLoaded();
      await controller.ensureLoaded();

      expect(service.permissionChecks, 1);
      expect(service.permissionRequests, 1);
      expect(service.scanRequests, 1);
    });

    test('concurrent load requests share one scan operation', () async {
      final service = _FakeAudioLibraryService();
      final controller = LibraryController(
        service: service,
        settingsRepository: _FakeSettingsRepository(),
      );

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

    test('passes saved format preferences to the native scanner', () async {
      final service = _FakeAudioLibraryService();
      final preferences = _FakeSettingsRepository(
        preferences: AudioLibraryPreferences(
          enabledExtensions: {'mp3', 'flac'},
        ),
      );
      final controller = LibraryController(
        service: service,
        settingsRepository: preferences,
      );

      await controller.ensureLoaded();

      expect(preferences.loadCount, 1);
      expect(service.receivedExtensions, {'mp3', 'flac'});
    });

    test('passes an empty format selection without enabling defaults', () async {
      final service = _FakeAudioLibraryService();
      final controller = LibraryController(
        service: service,
        settingsRepository: _FakeSettingsRepository(
          preferences: AudioLibraryPreferences(enabledExtensions: {}),
        ),
      );

      await controller.ensureLoaded();

      expect(service.receivedExtensions, isEmpty);
    });


    test('force refresh rescans the library', () async {
      final service = _FakeAudioLibraryService();
      final controller = LibraryController(
        service: service,
        settingsRepository: _FakeSettingsRepository(),
      );

      await controller.ensureLoaded();
      await controller.refreshLibrary(force: true);

      expect(service.scanRequests, 2);
      expect(controller.isLoading.value, isFalse);
    });

    test('keeps the previous song list when a rescan fails', () async {
      final service = _FakeAudioLibraryService(
        songsToReturn: [_song('1', 'Existing Track', 'Artist', 'Album', 10, 20)],
      );
      final controller = LibraryController(
        service: service,
        settingsRepository: _FakeSettingsRepository(),
      );

      await controller.ensureLoaded();
      expect(controller.songs, hasLength(1));

      service.scanError = StateError('temporary scan failure');
      await controller.refreshLibrary(force: true);

      expect(controller.songs, hasLength(1));
      expect(controller.songs.single.title, 'Existing Track');
      expect(controller.errorMessage.value, isNotNull);
      expect(controller.isLoading.value, isFalse);
    });

    test('groups songs into albums and artists using MediaStore IDs', () async {
      final controller = LibraryController(
        service: _CollectionAudioLibraryService(),
        settingsRepository: _FakeSettingsRepository(),
      );

      await controller.ensureLoaded();

      expect(controller.albums, hasLength(2));
      expect(controller.artists, hasLength(2));
      expect(controller.albums.firstWhere((album) => album.id == 'album:10').songCount, 2);
      expect(controller.artists.firstWhere((artist) => artist.id == 'artist:20').songCount, 2);
      expect(controller.artists.firstWhere((artist) => artist.id == 'artist:20').albumCount, 1);
    });

    test('filters album and artist collections using the active search query', () async {
      final controller = LibraryController(
        service: _CollectionAudioLibraryService(),
        settingsRepository: _FakeSettingsRepository(),
      );

      await controller.ensureLoaded();
      controller.updateSearch('album one');

      expect(controller.filteredAlbums, hasLength(1));
      expect(controller.filteredAlbums.single.title, 'Album One');
      expect(controller.filteredArtists, isEmpty);

      controller.updateSearch('artist two');

      expect(controller.filteredArtists, hasLength(1));
      expect(controller.filteredArtists.single.name, 'Artist Two');
    });

    test('uses normalized album and artist labels when IDs are unavailable', () async {
      final controller = LibraryController(
        service: _FallbackCollectionAudioLibraryService(),
        settingsRepository: _FakeSettingsRepository(),
      );

      await controller.ensureLoaded();

      expect(controller.albums, hasLength(1));
      expect(controller.artists, hasLength(1));
    });
  });
}

class _FakeSettingsRepository extends SettingsRepository {
  _FakeSettingsRepository({
    AudioLibraryPreferences? preferences,
  }) : preferences = preferences ?? AudioLibraryPreferences();

  final AudioLibraryPreferences preferences;
  int loadCount = 0;

  @override
  Future<AudioLibraryPreferences> loadAudioLibraryPreferences() async {
    loadCount++;
    return preferences;
  }

  @override
  Future<void> close() async {}
}

class _CollectionAudioLibraryService extends AudioLibraryService {
  @override
  Future<bool> hasPermission() async => true;

  @override
  Future<List<Song>> getSongs({Set<String>? extensions}) async => [
        _song('1', 'Track One', 'Artist One', 'Album One', 10, 20),
        _song('2', 'Track Two', 'Artist One', 'Album One', 10, 20),
        _song('3', 'Track Three', 'Artist Two', 'Album Two', 11, 21),
      ];
}

class _FallbackCollectionAudioLibraryService extends AudioLibraryService {
  @override
  Future<bool> hasPermission() async => true;

  @override
  Future<List<Song>> getSongs({Set<String>? extensions}) async => [
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
  _FakeAudioLibraryService({this.songsToReturn = const []});

  final List<Song> songsToReturn;
  Object? scanError;
  int permissionChecks = 0;
  int permissionRequests = 0;
  int scanRequests = 0;
  Set<String>? receivedExtensions;

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
  Future<List<Song>> getSongs({Set<String>? extensions}) async {
    scanRequests++;
    receivedExtensions = extensions;
    if (scanError != null) throw scanError!;
    return songsToReturn;
  }
}
