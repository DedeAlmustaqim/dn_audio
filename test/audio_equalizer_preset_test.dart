import 'package:flutter_test/flutter_test.dart';

import 'package:dn_audio/modules/player/models/audio_effects_capabilities.dart';
import 'package:dn_audio/modules/player/models/audio_equalizer_preset.dart';

void main() {
  const bands = [
    AudioEffectBandCapability(
      index: 0,
      centerFrequencyHz: 60,
      minFrequencyHz: 50,
      maxFrequencyHz: 80,
    ),
    AudioEffectBandCapability(
      index: 1,
      centerFrequencyHz: 250,
      minFrequencyHz: 200,
      maxFrequencyHz: 300,
    ),
    AudioEffectBandCapability(
      index: 2,
      centerFrequencyHz: 1000,
      minFrequencyHz: 800,
      maxFrequencyHz: 1200,
    ),
    AudioEffectBandCapability(
      index: 3,
      centerFrequencyHz: 4000,
      minFrequencyHz: 3500,
      maxFrequencyHz: 4500,
    ),
    AudioEffectBandCapability(
      index: 4,
      centerFrequencyHz: 12000,
      minFrequencyHz: 10000,
      maxFrequencyHz: 14000,
    ),
  ];

  test('Flat preset maps every device band to zero millibels', () {
    final levels = AudioEqualizerPreset.presets.first.levelsForBands(
      bands,
      minLevelMillibels: -1500,
      maxLevelMillibels: 1500,
    );

    expect(levels, {0: 0, 1: 0, 2: 0, 3: 0, 4: 0});
  });

  test('Bass preset maps its curve to device-reported band frequencies', () {
    final preset = AudioEqualizerPreset.findById('bass')!;
    final levels = preset.levelsForBands(
      bands,
      minLevelMillibels: -1500,
      maxLevelMillibels: 1500,
    );

    expect(levels, {0: 500, 1: 400, 2: 0, 3: -100, 4: -100});
  });

  test('preset values are clamped to device-reported level range', () {
    final preset = AudioEqualizerPreset.findById('treble')!;
    final levels = preset.levelsForBands(
      bands,
      minLevelMillibels: -300,
      maxLevelMillibels: 300,
    );

    expect(levels.values, everyElement(inInclusiveRange(-300, 300)));
    expect(levels[4], 300);
  });

  test('unknown preset id returns null', () {
    expect(AudioEqualizerPreset.findById('unknown'), isNull);
  });
}
