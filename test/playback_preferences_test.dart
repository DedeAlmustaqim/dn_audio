import 'package:flutter_test/flutter_test.dart';
import 'package:dn_audio/modules/settings/models/playback_preferences.dart';

void main() {
  group('PlaybackPreferences', () {
    test('defaults to normal playback speed', () {
      const preferences = PlaybackPreferences();

      expect(preferences.speed, 1.0);
      expect(preferences.hasValidSpeed, isTrue);
    });

    test('serializes and restores a supported speed', () {
      const preferences = PlaybackPreferences(speed: 1.5);

      final restored = PlaybackPreferences.fromMap(preferences.toMap());

      expect(restored.speed, 1.5);
      expect(restored.hasValidSpeed, isTrue);
    });

    test('falls back to normal speed for unsupported persisted values', () {
      final restored = PlaybackPreferences.fromMap({'speed': 1.1});

      expect(restored.speed, 1.0);
    });

    test('falls back to normal speed when persisted value is missing', () {
      final restored = PlaybackPreferences.fromMap({});

      expect(restored.speed, 1.0);
    });

    test('exposes only the supported playback speed options', () {
      expect(
        PlaybackPreferences.supportedSpeeds,
        [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0],
      );
    });
  });
}
