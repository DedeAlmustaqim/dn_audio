import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:dn_audio/modules/library/controllers/library_controller.dart';
import 'package:dn_audio/modules/library/models/song.dart';
import 'package:dn_audio/modules/library/services/audio_library_service.dart';
import 'package:dn_audio/modules/settings/controllers/settings_controller.dart';
import 'package:dn_audio/modules/settings/models/audio_library_preferences.dart';
import 'package:dn_audio/modules/settings/models/playback_preferences.dart';
import 'package:dn_audio/modules/settings/services/settings_repository.dart';

void main() {
  group('SettingsController', () {
    tearDown(() async {
      await Get.reset();
    });

    test('loads and applies persisted playback speed', () async {
      final repository = _FakeSettingsRepository(
        initialPlayback: const PlaybackPreferences(speed: 1.5),
      );
      final appliedSpeeds = <double>[];
      final controller = SettingsController(
        repository: repository,
        applyPlaybackSpeed: (speed) async => appliedSpeeds.add(speed),
      );

      await controller.loadPreferences();

      expect(controller.playbackPreferences.value.speed, 1.5);
      expect(appliedSpeeds, [1.5]);
      controller.onClose();
    });

    test('persists and applies a supported playback speed', () async {
      final repository = _FakeSettingsRepository();
      final appliedSpeeds = <double>[];
      final controller = SettingsController(
        repository: repository,
        applyPlaybackSpeed: (speed) async => appliedSpeeds.add(speed),
      );
      await controller.loadPreferences();

      await controller.setPlaybackSpeed(1.25);

      expect(controller.playbackPreferences.value.speed, 1.25);
      expect(repository.playbackSaved?.speed, 1.25);
      expect(appliedSpeeds.last, 1.25);
      controller.onClose();
    });

    test('rejects unsupported playback speeds', () async {
      final repository = _FakeSettingsRepository();
      final appliedSpeeds = <double>[];
      final controller = SettingsController(
        repository: repository,
        applyPlaybackSpeed: (speed) async => appliedSpeeds.add(speed),
      );
      await controller.loadPreferences();
      appliedSpeeds.clear();

      await controller.setPlaybackSpeed(1.1);

      expect(controller.playbackPreferences.value.speed, 1.0);
      expect(repository.playbackSaved, isNull);
      expect(appliedSpeeds, isEmpty);
      expect(controller.errorMessage.value, isNotNull);
      controller.onClose();
    });

    test('restores previous playback speed when saving fails', () async {
      final repository = _FakeSettingsRepository()..shouldFailPlaybackSave = true;
      final appliedSpeeds = <double>[];
      final controller = SettingsController(
        repository: repository,
        applyPlaybackSpeed: (speed) async => appliedSpeeds.add(speed),
      );
      await controller.loadPreferences();

      await controller.setPlaybackSpeed(1.5);

      expect(controller.playbackPreferences.value.speed, 1.0);
      expect(appliedSpeeds, [1.0, 1.5, 1.0]);
      expect(controller.errorMessage.value, isNotNull);
      controller.onClose();
    });

    test('loads persisted audio formats', () async {
      final repository = _FakeSettingsRepository(
        initial: AudioLibraryPreferences(enabledExtensions: {'mp3', 'flac'}),
      );
      final controller = SettingsController(repository: repository);

      await controller.loadPreferences();

      expect(controller.preferences.value.enabledExtensions, {'mp3', 'flac'});
      expect(controller.isLoading.value, isFalse);
      controller.onClose();
    });

    test('persists extension changes', () async {
      final repository = _FakeSettingsRepository();
      final controller = SettingsController(repository: repository);
      await controller.loadPreferences();

      await controller.toggleExtension('mp3', false);

      expect(controller.preferences.value.isEnabled('mp3'), isFalse);
      expect(repository.saved?.isEnabled('mp3'), isFalse);
      controller.onClose();
    });

    test('refreshes an already loaded library after saving preferences', () async {
      final libraryService = _FakeLibraryService();
      final repository = _FakeSettingsRepository();
      final libraryController = LibraryController(
        service: libraryService,
        settingsRepository: repository,
      );
      await libraryController.ensureLoaded();
      Get.put<LibraryController>(libraryController);

      final controller = SettingsController(repository: repository);
      await controller.loadPreferences();

      await controller.toggleExtension('mp3', false);

      expect(libraryService.scanRequests, 2);
      expect(libraryService.receivedExtensions, isNot(contains('mp3')));
      controller.onClose();
    });

    test('does not refresh the library when saving preferences fails', () async {
      final libraryService = _FakeLibraryService();
      final libraryController = LibraryController(
        service: libraryService,
        settingsRepository: _FakeSettingsRepository(),
      );
      await libraryController.ensureLoaded();
      Get.put<LibraryController>(libraryController);

      final repository = _FakeSettingsRepository()..shouldFailSave = true;
      final controller = SettingsController(repository: repository);
      await controller.loadPreferences();

      await controller.toggleExtension('mp3', false);

      expect(libraryService.scanRequests, 1);
      controller.onClose();
    });

    test('restores previous selection when saving fails', () async {
      final repository = _FakeSettingsRepository()..shouldFailSave = true;
      final controller = SettingsController(repository: repository);
      await controller.loadPreferences();
      final before = controller.preferences.value.enabledExtensions;

      await controller.toggleExtension('mp3', false);

      expect(controller.preferences.value.enabledExtensions, before);
      expect(controller.errorMessage.value, isNotNull);
      controller.onClose();
    });

    test('reset restores and persists default formats', () async {
      final repository = _FakeSettingsRepository();
      final controller = SettingsController(repository: repository);
      await controller.loadPreferences();
      await controller.toggleExtension('mp3', false);

      await controller.resetFormats();

      expect(
        controller.preferences.value.enabledExtensions,
        AudioLibraryPreferences.defaultExtensions,
      );
      expect(
        repository.saved?.enabledExtensions,
        AudioLibraryPreferences.defaultExtensions,
      );
      controller.onClose();
    });
  });
}

class _FakeSettingsRepository extends SettingsRepository {
  _FakeSettingsRepository({
    AudioLibraryPreferences? initial,
    PlaybackPreferences? initialPlayback,
  })  : _stored = initial ?? AudioLibraryPreferences(),
        _playbackStored = initialPlayback ?? const PlaybackPreferences();

  AudioLibraryPreferences _stored;
  PlaybackPreferences _playbackStored;
  AudioLibraryPreferences? saved;
  PlaybackPreferences? playbackSaved;
  bool shouldFailSave = false;
  bool shouldFailPlaybackSave = false;

  @override
  Future<AudioLibraryPreferences> loadAudioLibraryPreferences() async => _stored;

  @override
  Future<void> saveAudioLibraryPreferences(
    AudioLibraryPreferences preferences,
  ) async {
    if (shouldFailSave) throw StateError('save failed');
    _stored = preferences;
    saved = preferences;
  }

  @override
  Future<PlaybackPreferences> loadPlaybackPreferences() async =>
      _playbackStored;

  @override
  Future<void> savePlaybackPreferences(PlaybackPreferences preferences) async {
    if (shouldFailPlaybackSave) throw StateError('playback save failed');
    _playbackStored = preferences;
    playbackSaved = preferences;
  }

  @override
  Future<void> close() async {}
}


class _FakeLibraryService extends AudioLibraryService {
  int scanRequests = 0;
  Set<String>? receivedExtensions;

  @override
  Future<bool> hasPermission() async => true;

  @override
  Future<List<Song>> getSongs({Set<String>? extensions}) async {
    scanRequests++;
    receivedExtensions = extensions;
    return const [];
  }
}
