import 'dart:async';

import 'package:flutter/foundation.dart';
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
  int? _restoringSessionId;
  int? _pendingSessionId;
  bool _isReady = false;
  bool _isDisposed = false;
  Future<void>? _restoreTask;

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
    } catch (error, stackTrace) {
      debugPrint('DN Audio: unable to load audio effect preferences: $error');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      _isReady = true;
      _handleCapabilities(_handler.audioEffectsService.capabilities);
    }
  }

  void _handleCapabilities(AudioEffectsCapabilities capabilities) {
    if (_isDisposed || !_isReady || !capabilities.available) return;
    final sessionId = capabilities.sessionId;
    if (sessionId == null ||
        sessionId == _lastRestoredSessionId ||
        sessionId == _restoringSessionId) {
      return;
    }

    _pendingSessionId = sessionId;
    _startRestoreLoop();
  }

  void _startRestoreLoop() {
    if (_isDisposed || _restoreTask != null || _pendingSessionId == null) {
      return;
    }
    _restoreTask = _drainPendingRestores().whenComplete(() {
      _restoreTask = null;
      if (!_isDisposed && _pendingSessionId != null) {
        _startRestoreLoop();
      }
    });
  }

  Future<void> _drainPendingRestores() async {
    while (!_isDisposed && _pendingSessionId != null) {
      final sessionId = _pendingSessionId!;
      _pendingSessionId = null;
      final capabilities = _handler.audioEffectsService.capabilities;
      if (!capabilities.available || capabilities.sessionId != sessionId) {
        continue;
      }

      _restoringSessionId = sessionId;
      isRestoring.value = true;
      try {
        final restored = await _restoreForSession(sessionId, capabilities);
        if (restored && _isSessionCurrent(sessionId)) {
          _lastRestoredSessionId = sessionId;
        } else if (!restored) {
          debugPrint(
            'DN Audio: preferences were not fully restored for session $sessionId.',
          );
        }
      } catch (error, stackTrace) {
        debugPrint('DN Audio: audio preference restoration failed: $error');
        debugPrintStack(stackTrace: stackTrace);
      } finally {
        _restoringSessionId = null;
        isRestoring.value = false;
      }
    }
  }

  Future<bool> _restoreForSession(
    int sessionId,
    AudioEffectsCapabilities initialCapabilities,
  ) async {
    final service = _handler.audioEffectsService;
    var capabilities = initialCapabilities;

    bool ensureCurrentSession() {
      return !_isDisposed &&
          service.attachedSessionId == sessionId &&
          service.capabilities.available &&
          service.capabilities.sessionId == sessionId;
    }

    if (!ensureCurrentSession()) return false;

    final equalizer = capabilities.equalizer;
    if (equalizer.supported) {
      if (!await service.setEqualizerEnabled(_settings.equalizerEnabled) ||
          !ensureCurrentSession()) {
        return false;
      }

      final validBandIndices =
          equalizer.bands.map((band) => band.index).toSet();
      for (final entry in _settings.bandLevels.entries) {
        if (!validBandIndices.contains(entry.key)) continue;
        if (!await service.setBandLevel(entry.key, entry.value) ||
            !ensureCurrentSession()) {
          return false;
        }
      }
    }

    capabilities = service.capabilities;
    final bass = capabilities.bassBoost;
    if (bass.supported) {
      final strength = _clampStrength(_settings.bassBoostStrength, bass);
      if (!await service.setBassBoost(
            enabled: _settings.bassBoostEnabled,
            strength: strength,
          ) ||
          !ensureCurrentSession()) {
        return false;
      }
    }

    capabilities = service.capabilities;
    final virtualizer = capabilities.virtualizer;
    if (virtualizer.supported) {
      final strength =
          _clampStrength(_settings.virtualizerStrength, virtualizer);
      if (!await service.setVirtualizer(
            enabled: _settings.virtualizerEnabled,
            strength: strength,
          ) ||
          !ensureCurrentSession()) {
        return false;
      }
    }

    return ensureCurrentSession();
  }

  int _clampStrength(int value, AudioEffectCapability capability) {
    final min = capability.minStrength ?? 0;
    final max = capability.maxStrength ?? 1000;
    return value.clamp(min, max).toInt();
  }

  Future<void> retryRestoreForCurrentSession() async {
    if (_isDisposed || !_isReady) return;
    final capabilities = _handler.audioEffectsService.capabilities;
    final sessionId = capabilities.sessionId;
    if (!capabilities.available ||
        sessionId == null ||
        sessionId == _lastRestoredSessionId) {
      return;
    }
    _pendingSessionId = sessionId;
    _startRestoreLoop();
    await _restoreTask;
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
    _isDisposed = true;
    _pendingSessionId = null;
    _capabilitySubscription?.cancel();
    _repository.close();
    super.onClose();
  }
}