import 'dart:async';

import 'package:get/get.dart';

import '../models/audio_effects_capabilities.dart';
import '../services/audio_effects_settings_repository.dart';
import '../services/dn_audio_handler.dart';

class EqualizerController extends GetxController {
  EqualizerController({
    AudioEffectsSettingsRepository? repository,
  }) : _repository = repository ?? AudioEffectsSettingsRepository();

  final AudioEffectsSettingsRepository _repository;
  late final DnAudioHandler _handler;
  final selectedPresetId = 'flat'.obs;
  final isRestoring = false.obs;

  AudioEffectsSettings _settings = const AudioEffectsSettings();
  StreamSubscription<AudioEffectsCapabilities>? _capabilitySubscription;
  int? _lastRestoredSessionId;
  bool _isReady = false;

  @override
  void onInit() {
    super.onInit();
    _handler = Get.find<DnAudioHandler>();
    _capabilitySubscription =
        _handler.audioEffectsService.capabilitiesStream.listen(
      _handleCapabilities,
    );
    unawaited(_loadSettings());
  }

  Future<void> _loadSettings() async {
    try {
      _settings = await _repository.load();
      selectedPresetId.value = _settings.selectedPresetId;
      _isReady = true;
      _handleCapabilities(_handler.audioEffectsService.capabilities);
    } catch (_) {
      _isReady = true;
    }
  }

  void _handleCapabilities(AudioEffectsCapabilities capabilities) {
    final sessionId = capabilities.sessionId;
    if (!_isReady ||
        !capabilities.available ||
        sessionId == null ||
        sessionId == _lastRestoredSessionId ||
        isRestoring.value) {
      return;
    }
    unawaited(_restoreForSession(capabilities));
  }

  Future<void> _restoreForSession(
    AudioEffectsCapabilities capabilities,
  ) async {
    final sessionId = capabilities.sessionId;
    if (sessionId == null || isRestoring.value) return;

    isRestoring.value = true;
    try {
      final service = _handler.audioEffectsService;
      final equalizer = capabilities.equalizer;

      if (equalizer.supported) {
        await service.setEqualizerEnabled(_settings.equalizerEnabled);

        final validBandIndices = equalizer.bands.map((band) => band.index).toSet();
        for (final entry in _settings.bandLevels.entries) {
          if (validBandIndices.contains(entry.key)) {
            await service.setBandLevel(entry.key, entry.value);
          }
        }
      }

      final bass = capabilities.bassBoost;
      if (bass.supported) {
        final strength = _clampStrength(
          _settings.bassBoostStrength,
          bass,
        );
        await service.setBassBoost(
          enabled: _settings.bassBoostEnabled,
          strength: strength,
        );
      }

      final virtualizer = capabilities.virtualizer;
      if (virtualizer.supported) {
        final strength = _clampStrength(
          _settings.virtualizerStrength,
          virtualizer,
        );
        await service.setVirtualizer(
          enabled: _settings.virtualizerEnabled,
          strength: strength,
        );
      }
      _lastRestoredSessionId = sessionId;
    } finally {
      isRestoring.value = false;
    }
  }

  int _clampStrength(int value, AudioEffectCapability capability) {
    final min = capability.minStrength ?? 0;
    final max = capability.maxStrength ?? 1000;
    return value.clamp(min, max).toInt();
  }

  Future<void> persistCurrentSettings({
    required String presetId,
  }) async {
    final capabilities = _handler.audioEffectsService.capabilities;
    final equalizer = capabilities.equalizer;
    final bass = capabilities.bassBoost;
    final virtualizer = capabilities.virtualizer;

    _settings = AudioEffectsSettings(
      equalizerEnabled: equalizer.enabled,
      selectedPresetId: presetId,
      bandLevels: {
        for (final band in equalizer.bands) band.index: band.levelMillibels,
      },
      bassBoostEnabled: bass.enabled,
      bassBoostStrength: bass.strength ?? _settings.bassBoostStrength,
      virtualizerEnabled: virtualizer.enabled,
      virtualizerStrength:
          virtualizer.strength ?? _settings.virtualizerStrength,
    );
    selectedPresetId.value = presetId;
    await _repository.save(_settings);
  }

  @override
  void onClose() {
    _capabilitySubscription?.cancel();
    _repository.close();
    super.onClose();
  }
}
