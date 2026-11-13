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
            'levelMillibels': 250,
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
    expect(capabilities.equalizer.bands.first.levelMillibels, 250);
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

  test('sends equalizer enable and band level commands and refreshes state', () async {
    final calls = <MethodCall>[];
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      final capabilities = {
          'available': true,
          'sessionId': 505,
          'equalizer': {
            'supported': true,
            'enabled': call.method == 'setEqualizerEnabled'
                ? call.arguments['enabled']
                : true,
            'bandCount': 1,
            'minLevelMillibels': -1000,
            'maxLevelMillibels': 1000,
            'bands': [
              {
                'index': 0,
                'centerFrequencyHz': 1000,
                'minFrequencyHz': 800,
                'maxFrequencyHz': 1200,
                'levelMillibels': call.method == 'setBandLevel'
                    ? call.arguments['levelMillibels']
                    : 0,
              }
            ],
          },
          'bassBoost': {'supported': false},
          'virtualizer': {'supported': false},
        };
      if (call.method == 'attachSession') return capabilities;
      return {'success': true, 'capabilities': capabilities};
    });

    final service = AudioEffectsService(channel: channel);
    final sessionIds = StreamController<int?>();
    service.bindSessionStream(sessionIds.stream);
    sessionIds.add(505);
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(await service.setEqualizerEnabled(true), isTrue);
    expect(await service.setBandLevel(0, 350), isTrue);
    expect(calls.map((call) => call.method).toList(), [
      'attachSession',
      'setEqualizerEnabled',
      'setBandLevel',
    ]);
    expect(calls[1].arguments, {'enabled': true});
    expect(calls[2].arguments, {'bandIndex': 0, 'levelMillibels': 350});
    expect(service.capabilities.equalizer.bands.first.levelMillibels, 350);

    await service.dispose();
    await sessionIds.close();
  });

  test('rejects out-of-range band levels without calling native channel', () async {
    final calls = <MethodCall>[];
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      if (call.method == 'attachSession') {
        return {
          'available': true,
          'sessionId': 606,
          'equalizer': {
            'supported': true,
            'minLevelMillibels': -500,
            'maxLevelMillibels': 500,
            'bands': [],
          },
        };
      }
      return null;
    });

    final service = AudioEffectsService(channel: channel);
    final sessionIds = StreamController<int?>();
    service.bindSessionStream(sessionIds.stream);
    sessionIds.add(606);
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(await service.setBandLevel(0, 700), isFalse);
    expect(calls.map((call) => call.method).toList(), ['attachSession']);

    await service.dispose();
    await sessionIds.close();
  });

  test('sends BassBoost and Virtualizer commands and refreshes capability state', () async {
    final calls = <MethodCall>[];
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      if (call.method == 'attachSession') {
        return {
          'available': true,
          'sessionId': 707,
          'equalizer': {'supported': false},
          'bassBoost': {
            'supported': true,
            'enabled': false,
            'strengthSupported': true,
            'minStrength': 0,
            'maxStrength': 1000,
            'strength': 400,
          },
          'virtualizer': {
            'supported': true,
            'enabled': false,
            'strengthSupported': true,
            'minStrength': 0,
            'maxStrength': 1000,
            'strength': 250,
          },
        };
      }
      final bassEnabled = call.method == 'setBassBoost'
          ? call.arguments['enabled'] == true
          : false;
      final virtualEnabled = call.method == 'setVirtualizer'
          ? call.arguments['enabled'] == true
          : false;
      return {
        'success': true,
        'capabilities': {
          'available': true,
          'sessionId': 707,
          'equalizer': {'supported': false},
          'bassBoost': {
            'supported': true,
            'enabled': bassEnabled,
            'strengthSupported': true,
            'minStrength': 0,
            'maxStrength': 1000,
            'strength': call.method == 'setBassBoost'
                ? call.arguments['strength']
                : 400,
          },
          'virtualizer': {
            'supported': true,
            'enabled': virtualEnabled,
            'strengthSupported': true,
            'minStrength': 0,
            'maxStrength': 1000,
            'strength': call.method == 'setVirtualizer'
                ? call.arguments['strength']
                : 250,
          },
        },
      };
    });

    final service = AudioEffectsService(channel: channel);
    final sessionIds = StreamController<int?>();
    service.bindSessionStream(sessionIds.stream);
    sessionIds.add(707);
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(
      await service.setBassBoost(enabled: true, strength: 650),
      isTrue,
    );
    expect(
      await service.setVirtualizer(enabled: true, strength: 300),
      isTrue,
    );
    expect(calls.map((call) => call.method).toList(), [
      'attachSession',
      'setBassBoost',
      'setVirtualizer',
    ]);
    expect(calls[1].arguments, {'enabled': true, 'strength': 650});
    expect(calls[2].arguments, {'enabled': true, 'strength': 300});
    expect(service.capabilities.bassBoost.enabled, isFalse);
    expect(service.capabilities.virtualizer.enabled, isTrue);
    expect(service.capabilities.virtualizer.strength, 300);

    await service.dispose();
    await sessionIds.close();
  });

  test('rejects unsupported optional effects and out-of-range strengths', () async {
    final calls = <MethodCall>[];
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      if (call.method == 'attachSession') {
        return {
          'available': true,
          'sessionId': 808,
          'equalizer': {'supported': false},
          'bassBoost': {
            'supported': true,
            'strengthSupported': true,
            'minStrength': 0,
            'maxStrength': 1000,
          },
          'virtualizer': {'supported': false},
        };
      }
      return {
        'success': true,
        'capabilities': {
          'available': true,
          'sessionId': 808,
          'equalizer': {'supported': false},
          'bassBoost': {
            'supported': true,
            'strengthSupported': true,
            'minStrength': 0,
            'maxStrength': 1000,
          },
          'virtualizer': {'supported': false},
        },
      };
    });

    final service = AudioEffectsService(channel: channel);
    final sessionIds = StreamController<int?>();
    service.bindSessionStream(sessionIds.stream);
    sessionIds.add(808);
    await Future<void>.delayed(const Duration(milliseconds: 10));

    expect(
      await service.setBassBoost(enabled: true, strength: 1200),
      isFalse,
    );
    expect(
      await service.setVirtualizer(enabled: true, strength: 500),
      isFalse,
    );
    expect(calls.map((call) => call.method).toList(), ['attachSession']);

    await service.dispose();
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
