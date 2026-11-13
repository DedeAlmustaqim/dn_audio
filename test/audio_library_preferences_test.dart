import 'package:flutter_test/flutter_test.dart';

import 'package:dn_audio/modules/settings/models/audio_library_preferences.dart';

void main() {
  group('AudioLibraryPreferences', () {
    test('uses all supported formats by default', () {
      final preferences = AudioLibraryPreferences();

      expect(
        preferences.enabledExtensions,
        AudioLibraryPreferences.defaultExtensions,
      );
    });

    test('normalizes extensions and removes unsupported values', () {
      final preferences = AudioLibraryPreferences(
        enabledExtensions: {'.MP3', ' flac ', 'unknown', '.OpUs'},
      );

      expect(preferences.enabledExtensions, {'mp3', 'flac', 'opus'});
      expect(preferences.isEnabled('.MP3'), isTrue);
      expect(preferences.isEnabled('unknown'), isFalse);
    });

    test('round trips selected extensions through map serialization', () {
      final preferences = AudioLibraryPreferences(
        enabledExtensions: {'mp3', 'flac', 'opus'},
      );

      final restored = AudioLibraryPreferences.fromMap(preferences.toMap());

      expect(restored.enabledExtensions, {'mp3', 'flac', 'opus'});
    });

    test('preserves an intentionally empty selection', () {
      final restored = AudioLibraryPreferences.fromMap({
        'enabledExtensions': <String>[],
      });

      expect(restored.enabledExtensions, isEmpty);
    });

    test('falls back to defaults when stored data is missing or invalid', () {
      expect(
        AudioLibraryPreferences.fromMap({}).enabledExtensions,
        AudioLibraryPreferences.defaultExtensions,
      );
      expect(
        AudioLibraryPreferences.fromMap({
          'enabledExtensions': 'mp3',
        }).enabledExtensions,
        AudioLibraryPreferences.defaultExtensions,
      );
    });
  });
}
