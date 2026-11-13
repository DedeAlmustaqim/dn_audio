import 'package:flutter_test/flutter_test.dart';
import 'package:dn_audio/modules/settings/controllers/settings_controller.dart';
import 'package:dn_audio/modules/settings/models/audio_library_preferences.dart';
import 'package:dn_audio/modules/settings/services/settings_repository.dart';

void main() {
  group('SettingsController', () {
    test('loads persisted audio formats', () async {
      final repository = _FakeSettingsRepository(
        initial: AudioLibraryPreferences(enabledExtensions: {'mp3', 'flac'}),
      );
      final controller = SettingsController(repository: repository);

      await controller.loadPreferences();

      expect(controller.preferences.value.enabledExtensions, {'mp3', 'flac'});
      expect(controller.isLoading.value, isFalse);
      await controller.onClose();
    });

    test('persists extension changes', () async {
      final repository = _FakeSettingsRepository();
      final controller = SettingsController(repository: repository);
      await controller.loadPreferences();

      await controller.toggleExtension('mp3', false);

      expect(controller.preferences.value.isEnabled('mp3'), isFalse);
      expect(repository.saved?.isEnabled('mp3'), isFalse);
      await controller.onClose();
    });

    test('restores previous selection when saving fails', () async {
      final repository = _FakeSettingsRepository()..shouldFailSave = true;
      final controller = SettingsController(repository: repository);
      await controller.loadPreferences();
      final before = controller.preferences.value.enabledExtensions;

      await controller.toggleExtension('mp3', false);

      expect(controller.preferences.value.enabledExtensions, before);
      expect(controller.errorMessage.value, isNotNull);
      await controller.onClose();
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
      await controller.onClose();
    });
  });
}

class _FakeSettingsRepository extends SettingsRepository {
  _FakeSettingsRepository({AudioLibraryPreferences? initial})
      : _stored = initial ?? AudioLibraryPreferences();

  AudioLibraryPreferences _stored;
  AudioLibraryPreferences? saved;
  bool shouldFailSave = false;

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
  Future<void> close() async {}
}
