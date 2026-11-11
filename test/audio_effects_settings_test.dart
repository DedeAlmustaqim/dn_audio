import 'package:flutter_test/flutter_test.dart';

import 'package:dn_audio/modules/player/services/audio_effects_settings_repository.dart';

void main() {
  group('AudioEffectsSettings', () {
    test('round trips effect preferences and integer band indexes', () {
      const settings = AudioEffectsSettings(
        equalizerEnabled: true,
        selectedPresetId: 'rock',
        bandLevels: {0: -250, 1: 125, 4: 600},
        bassBoostEnabled: true,
        bassBoostStrength: 720,
        virtualizerEnabled: false,
        virtualizerStrength: 300,
      );

      final restored = AudioEffectsSettings.fromMap(settings.toMap());

      expect(restored.equalizerEnabled, isTrue);
      expect(restored.selectedPresetId, 'rock');
      expect(restored.bandLevels, {0: -250, 1: 125, 4: 600});
      expect(restored.bassBoostEnabled, isTrue);
      expect(restored.bassBoostStrength, 720);
      expect(restored.virtualizerEnabled, isFalse);
      expect(restored.virtualizerStrength, 300);
    });

    test('uses safe defaults for incomplete stored data', () {
      final settings = AudioEffectsSettings.fromMap({
        'bandLevels': {'bad-index': 100, '2': 'invalid'},
      });

      expect(settings.equalizerEnabled, isFalse);
      expect(settings.selectedPresetId, 'flat');
      expect(settings.bandLevels, isEmpty);
      expect(settings.bassBoostStrength, 0);
      expect(settings.virtualizerEnabled, isFalse);
    });
  });
}
