import 'package:get/get.dart';

import '../../library/controllers/library_controller.dart';
import '../../player/services/dn_audio_handler.dart';
import '../models/audio_library_preferences.dart';
import '../models/playback_preferences.dart';
import '../services/settings_repository.dart';

class SettingsController extends GetxController {
  SettingsController({
    SettingsRepository? repository,
    Future<void> Function(double speed)? applyPlaybackSpeed,
  })  : _repository = repository ?? SettingsRepository(),
        _applyPlaybackSpeedOverride = applyPlaybackSpeed;

  final SettingsRepository _repository;
  final Future<void> Function(double speed)? _applyPlaybackSpeedOverride;
  final preferences = AudioLibraryPreferences().obs;
  final playbackPreferences = const PlaybackPreferences().obs;
  final isLoading = true.obs;
  final isSaving = false.obs;
  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadPreferences();
  }

  Future<void> loadPreferences() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      preferences.value = await _repository.loadAudioLibraryPreferences();
      playbackPreferences.value = await _repository.loadPlaybackPreferences();
      await _applyPlaybackSpeed(playbackPreferences.value.speed);
    } catch (_) {
      errorMessage.value = 'Unable to load settings preferences.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> setPlaybackSpeed(double speed) async {
    if (isSaving.value || isLoading.value) return;
    if (!PlaybackPreferences.supportedSpeeds.contains(speed)) {
      errorMessage.value = 'That playback speed is not supported.';
      return;
    }

    final previous = playbackPreferences.value;
    final next = previous.copyWith(speed: speed);
    isSaving.value = true;
    errorMessage.value = null;

    try {
      await _applyPlaybackSpeed(speed);
      await _repository.savePlaybackPreferences(next);
      playbackPreferences.value = next;
    } catch (_) {
      try {
        await _applyPlaybackSpeed(previous.speed);
      } catch (_) {
        // Keep the original save/apply error visible to the user.
      }
      errorMessage.value = 'Could not apply or save playback speed. Previous setting restored.';
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> _applyPlaybackSpeed(double speed) async {
    if (_applyPlaybackSpeedOverride != null) {
      await _applyPlaybackSpeedOverride(speed);
      return;
    }
    if (Get.isRegistered<DnAudioHandler>()) {
      await Get.find<DnAudioHandler>().setPlaybackSpeed(speed);
    }
  }

  Future<void> toggleExtension(String extension, bool enabled) async {
    if (isSaving.value || isLoading.value) return;

    final current = preferences.value.enabledExtensions;
    final updated = Set<String>.from(current);
    if (enabled) {
      updated.add(extension);
    } else {
      updated.remove(extension);
    }

    final next = AudioLibraryPreferences(enabledExtensions: updated);
    final previous = preferences.value;
    preferences.value = next;
    isSaving.value = true;
    errorMessage.value = null;

    try {
      await _repository.saveAudioLibraryPreferences(next);
      await _refreshLoadedLibrary();
    } catch (_) {
      preferences.value = previous;
      errorMessage.value = 'Could not save changes. Your previous settings were restored.';
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> resetFormats() async {
    if (isSaving.value || isLoading.value) return;

    final previous = preferences.value;
    final defaults = AudioLibraryPreferences();
    preferences.value = defaults;
    isSaving.value = true;
    errorMessage.value = null;

    try {
      await _repository.saveAudioLibraryPreferences(defaults);
      await _refreshLoadedLibrary();
    } catch (_) {
      preferences.value = previous;
      errorMessage.value = 'Could not save changes. Your previous settings were restored.';
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> _refreshLoadedLibrary() async {
    if (!Get.isRegistered<LibraryController>()) return;
    await Get.find<LibraryController>().refreshIfLoaded();
  }

  @override
  void onClose() {
    _repository.close();
    super.onClose();
  }
}
