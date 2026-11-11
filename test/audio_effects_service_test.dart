import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dn_audio/modules/player/models/audio_effects_capabilities.dart';
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
  test('parses device-reported equalizer bands and optional effect support', () {
    final capabilities = AudioEffectsCapabilities.fromMap({
      'available': true,
      'sessionId': 77,
      'equalizer': {
        'supported': true,
        'enabled': false,
        'bandCount': 2,
        'minLevelMillibels': -1500,
        'maxLevelMillibels': 1500,
        'presetCount': 4,
        'bands': [
          {
            'index': 0,
            'centerFrequencyHz': 100,
            'minFrequencyHz': 80,
            'maxFrequencyHz': 120,
          },
          {
            'index': 1,
            'centerFrequencyHz': 1000,
            'minFrequencyHz': 800,
            'maxFrequencyHz': 1200,
          },
        ],
      },
      'bassBoost': {'supported': false, 'error': 'UnsupportedOperationException'},
      'virtualizer': {
        'supported': true,
        'enabled': false,
        'strengthSupported': true,
        'minStrength': 0,
        'maxStrength': 1000,
      },
    });

    expect(capabilities.available, isTrue);
    expect(capabilities.sessionId, 77);
    expect(capabilities.equalizer.bandCount, 2);
    expect(capabilities.equalizer.bands, hasLength(2));
    expect(capabilities.equalizer.bands.first.centerFrequencyHz, 100);
    expect(capabilities.bassBoost.supported, isFalse);
    expect(capabilities.bassBoost.error, 'UnsupportedOperationException');
    expect(capabilities.virtualizer.supported, isTrue);
    expect(capabilities.virtualizer.strengthSupported, isTrue);
  });

  test('publishes capability response after session attachment', () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'attachSession') {
        return {
          'available': true,
          'sessionId': 404,
          'equalizer': {'supported': true, 'bandCount': 3, 'bands': []},
          'bassBoost': {'supported': false},
          'virtualizer': {'supported': false},
        };
      }
      return null;
    });

    final service = AudioEffectsService(channel: channel);
    final sessionIds = StreamController<int?>();
    final emitted = <AudioEffectsCapabilities>[];
    final subscription = service.capabilitiesStream.listen(emitted.add);

    service.bindSessionStream(sessionIds.stream);
    sessionIds.add(404);
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(service.capabilities.available, isTrue);
    expect(service.capabilities.sessionId, 404);
    expect(service.capabilities.equalizer.bandCount, 3);
    expect(emitted, hasLength(1));

    await service.dispose();
    await subscription.cancel();
    await sessionIds.close();
  });

  test('reports channel failures as unavailable without throwing', () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      throw PlatformException(code: 'effect_channel_error');
    });

    final service = AudioEffectsService(channel: channel);
    final capabilities = await service.getCapabilities();

    expect(capabilities.available, isFalse);
    expect(capabilities.error, 'effect_channel_error');
    await service.dispose();
  });

}
