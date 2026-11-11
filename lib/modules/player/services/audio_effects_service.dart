import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class AudioEffectsService {
  AudioEffectsService({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel('dn_audio/audio_effects');

  final MethodChannel _channel;

  StreamSubscription<int?>? _sessionSubscription;
  Future<void> _pendingOperation = Future<void>.value();
  int? _attachedSessionId;
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
    if (_isDisposed || sessionId == _attachedSessionId) return;

    _pendingOperation = _pendingOperation
        .then((_) => _applySession(sessionId))
        .catchError((Object error, StackTrace stackTrace) {
      debugPrint('DN Audio: audio effects session binding failed: $error');
    });
  }

  Future<void> _applySession(int? sessionId) async {
    if (_isDisposed) return;

    if (sessionId == null || sessionId <= 0) {
      if (_attachedSessionId == null) return;
      await _channel.invokeMethod<void>('release');
      _attachedSessionId = null;
      return;
    }

    await _channel.invokeMethod<Map<dynamic, dynamic>>(
      'attachSession',
      {'sessionId': sessionId},
    );
    _attachedSessionId = sessionId;
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
      }
      _attachedSessionId = null;
    }
  }
}
