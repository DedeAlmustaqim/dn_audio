import 'package:get/get.dart';

import '../../library/controllers/library_controller.dart';
import '../models/audio_library_preferences.dart';
import '../services/settings_repository.dart';

class SettingsController extends GetxController {
  SettingsController({SettingsRepository? repository})
      : _repository = repository ?? SettingsRepository();

  final SettingsRepository _repository;
  final preferences = AudioLibraryPreferences().obs;
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
    } catch (_) {
      errorMessage.value = 'Unable to load audio library preferences.';
    } finally {
      isLoading.value = false;
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
