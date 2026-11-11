import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/audio_effects_capabilities.dart';

class AudioEffectsService {
  AudioEffectsService({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel('dn_audio/audio_effects');

  final MethodChannel _channel;
  final StreamController<AudioEffectsCapabilities> _capabilitiesController =
      StreamController<AudioEffectsCapabilities>.broadcast();

  AudioEffectsCapabilities _capabilities =
      const AudioEffectsCapabilities(available: false);

  AudioEffectsCapabilities get capabilities => _capabilities;
  Stream<AudioEffectsCapabilities> get capabilitiesStream =>
      _capabilitiesController.stream;

  void _publishCapabilities(AudioEffectsCapabilities value) {
    _capabilities = value;
    if (!_capabilitiesController.isClosed) {
      _capabilitiesController.add(value);
    }
  }

  StreamSubscription<int?>? _sessionSubscription;
  Future<void> _pendingOperation = Future<void>.value();
  int? _attachedSessionId;
  int? _requestedSessionId;
  bool _isDisposed = false;

  int? get attachedSessionId => _attachedSessionId;

  void bindSessionStream(Stream<int?> sessionIdStream) {
    if (_isDisposed) return;

    unawaited(_sessionSubscription?.cancel());
    _sessionSubscription = sessionIdStream.listen(
      _handleSessionId,
      onError: (Object error, StackTrace stackTrace) {
        debugPrint('DN Audio: audio session stream failed: $error');
      },
    );
  }

  void _handleSessionId(int? sessionId) {
    if (_isDisposed || sessionId == _requestedSessionId) return;
    _requestedSessionId = sessionId;

    _pendingOperation = _pendingOperation
        .then((_) => _applySession(sessionId))
        .catchError((Object error, StackTrace stackTrace) {
      debugPrint('DN Audio: audio effects session binding failed: $error');
      _publishCapabilities(
        AudioEffectsCapabilities.unavailable(_errorCode(error)),
      );
      if (_requestedSessionId == sessionId) {
        _requestedSessionId = _attachedSessionId;
      }
    });
  }

  Future<void> _applySession(int? sessionId) async {
    if (_isDisposed) return;

    if (sessionId == null || sessionId <= 0) {
      if (_attachedSessionId == null) return;
      try {
        await _channel.invokeMethod<void>('release');
      } catch (error) {
        debugPrint('DN Audio: native audio effects release failed: $error');
      }
      _attachedSessionId = null;
      _publishCapabilities(
        const AudioEffectsCapabilities(available: false),
      );
      return;
    }

    final response = await _channel.invokeMethod<Map<dynamic, dynamic>>(
      'attachSession',
      {'sessionId': sessionId},
    );
    _attachedSessionId = sessionId;
    _publishCapabilities(AudioEffectsCapabilities.fromMap(response));
  }

  Future<AudioEffectsCapabilities> getCapabilities() async {
    try {
      final response = await _channel
          .invokeMethod<Map<dynamic, dynamic>>('getCapabilities');
      final value = AudioEffectsCapabilities.fromMap(response);
      _publishCapabilities(value);
      return value;
    } catch (error) {
      final value = AudioEffectsCapabilities.unavailable(_errorCode(error));
      _publishCapabilities(value);
      debugPrint('DN Audio: capability discovery failed: $error');
      return value;
    }
  }

  Future<bool> setEqualizerEnabled(bool enabled) {
    return _runEqualizerCommand(
      'setEqualizerEnabled',
      {'enabled': enabled},
    );
  }

  Future<bool> setBandLevel(int bandIndex, int levelMillibels) {
    if (bandIndex < 0 || attachedSessionId == null) return Future.value(false);

    final equalizer = _capabilities.equalizer;
    final minLevel = equalizer.minLevelMillibels;
    final maxLevel = equalizer.maxLevelMillibels;
    if (!equalizer.supported ||
        minLevel == null ||
        maxLevel == null ||
        levelMillibels < minLevel ||
        levelMillibels > maxLevel) {
      return Future.value(false);
    }

    return _runEqualizerCommand(
      'setBandLevel',
      {
        'bandIndex': bandIndex,
        'levelMillibels': levelMillibels,
      },
    );
  }

  Future<bool> setBassBoost({
    required bool enabled,
    required int strength,
  }) {
    return _runOptionalEffectCommand(
      'setBassBoost',
      _capabilities.bassBoost,
      enabled: enabled,
      strength: strength,
    );
  }

  Future<bool> setVirtualizer({
    required bool enabled,
    required int strength,
  }) {
    return _runOptionalEffectCommand(
      'setVirtualizer',
      _capabilities.virtualizer,
      enabled: enabled,
      strength: strength,
    );
  }

  Future<bool> _runOptionalEffectCommand(
    String method,
    AudioEffectCapability capability, {
    required bool enabled,
    required int strength,
  }) async {
    final minStrength = capability.minStrength;
    final maxStrength = capability.maxStrength;
    if (_isDisposed ||
        attachedSessionId == null ||
        !capability.supported ||
        minStrength == null ||
        maxStrength == null ||
        strength < minStrength ||
        strength > maxStrength) {
      return false;
    }

    try {
      final response = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        method,
        {'enabled': enabled, 'strength': strength},
      );
      if (response == null) return false;
      final rawCapabilities = response['capabilities'];
      if (rawCapabilities is Map) {
        _publishCapabilities(
          AudioEffectsCapabilities.fromMap(rawCapabilities),
        );
      }
      return response['success'] == true;
    } catch (error) {
      debugPrint('DN Audio: optional effect command $method failed: $error');
      return false;
    }
  }

  Future<bool> _runEqualizerCommand(
    String method,
    Map<String, Object> arguments,
  ) async {
    if (_isDisposed || attachedSessionId == null ||
        !_capabilities.equalizer.supported) {
      return false;
    }

    try {
      final response = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        method,
        arguments,
      );
      if (response == null) return false;

      final rawCapabilities = response['capabilities'];
      if (rawCapabilities is Map) {
        _publishCapabilities(
          AudioEffectsCapabilities.fromMap(rawCapabilities),
        );
      }
      return response['success'] == true;
    } catch (error) {
      debugPrint('DN Audio: equalizer command $method failed: $error');
      return false;
    }
  }

  String _errorCode(Object error) {
    if (error is PlatformException) return error.code;
    if (error is MissingPluginException) return 'channel_unavailable';
    return error.runtimeType.toString();
  }

  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;

    await _sessionSubscription?.cancel();
    await _pendingOperation;

    if (_attachedSessionId != null) {
      try {
        await _channel.invokeMethod<void>('release');
      } on PlatformException catch (error) {
        debugPrint('DN Audio: unable to release native audio effects: $error');
      } on MissingPluginException catch (error) {
        debugPrint('DN Audio: native audio effects channel unavailable: $error');
      } catch (error) {
        debugPrint('DN Audio: unexpected native audio effects release error: $error');
      }
      _attachedSessionId = null;
    }
    _requestedSessionId = null;
    _publishCapabilities(const AudioEffectsCapabilities(available: false));
    await _capabilitiesController.close();
  }
}
