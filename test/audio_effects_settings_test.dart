import 'package:flutter_test/flutter_test.dart';

import 'package:dn_audio/modules/player/services/audio_effects_settings_repository.dart';

void main() {
  group('AudioEffectsSettings', () {
    test('round trips every audio preference and integer band indexes', () {
      const settings = AudioEffectsSettings(
        equalizerEnabled: true,
        selectedPresetId: 'vocal',
        bandLevels: {0: -250, 1: 125, 4: 600},
        bassBoostEnabled: true,
        bassBoostStrength: 720,
        virtualizerEnabled: false,
        virtualizerStrength: 300,
      );

      final restored = AudioEffectsSettings.fromMap(settings.toMap());

      expect(restored.equalizerEnabled, isTrue);
      expect(restored.selectedPresetId, 'vocal');
      expect(restored.bandLevels, {0: -250, 1: 125, 4: 600});
      expect(restored.bassBoostEnabled, isTrue);
      expect(restored.bassBoostStrength, 720);
      expect(restored.virtualizerEnabled, isFalse);
      expect(restored.virtualizerStrength, 300);
    });

    test('uses safe defaults for incomplete or malformed stored data', () {
      final settings = AudioEffectsSettings.fromMap({
        'bandLevels': {'bad-index': 100, '2': 'invalid'},
        'bassBoostStrength': 'invalid',
        'virtualizerStrength': null,
      });

      expect(settings.equalizerEnabled, isFalse);
      expect(settings.selectedPresetId, 'flat');
      expect(settings.bandLevels, isEmpty);
      expect(settings.bassBoostStrength, 0);
      expect(settings.virtualizerEnabled, isFalse);
      expect(settings.virtualizerStrength, 0);
    });
  });
}
