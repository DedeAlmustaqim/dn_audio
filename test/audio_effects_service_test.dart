import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dn_audio/modules/player/services/audio_effects_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('test/dn_audio/audio_effects');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
  });

  test('binds changed sessions and releases when session becomes null', () async {
    final calls = <MethodCall>[];
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      if (call.method == 'attachSession') {
        return <String, dynamic>{'available': true};
      }
      return null;
    });

    final service = AudioEffectsService(channel: channel);
    final sessionIds = StreamController<int?>();

    service.bindSessionStream(sessionIds.stream);
    sessionIds.add(101);
    sessionIds.add(101);
    sessionIds.add(202);
    sessionIds.add(null);
    await Future<void>.delayed(const Duration(milliseconds: 20));

    expect(calls.map((call) => call.method).toList(), [
      'attachSession',
      'attachSession',
      'release',
    ]);
    expect(calls[0].arguments, {'sessionId': 101});
    expect(calls[1].arguments, {'sessionId': 202});
    expect(service.attachedSessionId, isNull);

    await service.dispose();
    await sessionIds.close();
  });

  test('releases the active native session when disposed', () async {
    final calls = <MethodCall>[];
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return <String, dynamic>{'available': true};
    });

    final service = AudioEffectsService(channel: channel);
    final sessionIds = StreamController<int?>();

    service.bindSessionStream(sessionIds.stream);
    sessionIds.add(303);
    await Future<void>.delayed(const Duration(milliseconds: 10));
    await service.dispose();
    await sessionIds.close();

    expect(calls.map((call) => call.method).toList(), [
      'attachSession',
      'release',
    ]);
    expect(service.attachedSessionId, isNull);
  });
}
