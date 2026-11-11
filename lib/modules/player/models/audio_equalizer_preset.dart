import 'dart:math' as math;

import 'audio_effects_capabilities.dart';

class AudioEqualizerPreset {
  const AudioEqualizerPreset({
    required this.id,
    required this.name,
    required this.description,
    required this.anchorGainsDb,
  });

  final String id;
  final String name;
  final String description;

  /// Gains at 60 Hz, 250 Hz, 1 kHz, 4 kHz and 12 kHz.
  final List<double> anchorGainsDb;

  static const _anchorFrequencies = <double>[
    60,
    250,
    1000,
    4000,
    12000,
  ];

  static const presets = <AudioEqualizerPreset>[
    AudioEqualizerPreset(
      id: 'flat',
      name: 'Flat',
      description: 'Neutral response',
      anchorGainsDb: [0, 0, 0, 0, 0],
    ),
    AudioEqualizerPreset(
      id: 'bass',
      name: 'Bass',
      description: 'Deeper low frequencies',
      anchorGainsDb: [5, 4, 0, -1, -1],
    ),
    AudioEqualizerPreset(
      id: 'vocal',
      name: 'Vocal',
      description: 'Clearer voice presence',
      anchorGainsDb: [-2, -1, 2, 3, 1],
    ),
    AudioEqualizerPreset(
      id: 'treble',
      name: 'Treble',
      description: 'Brighter high frequencies',
      anchorGainsDb: [-2, -1, 0, 3, 5],
    ),
    AudioEqualizerPreset(
      id: 'rock',
      name: 'Rock',
      description: 'Punchy lows and highs',
      anchorGainsDb: [4, 2, -1, 2, 4],
    ),
  ];

  static AudioEqualizerPreset? findById(String? id) {
    for (final preset in presets) {
      if (preset.id == id) return preset;
    }
    return null;
  }

  /// Maps a five-point DN Audio curve onto the bands reported by the device.
  /// Interpolation uses logarithmic frequency spacing, then clamps to the
  /// active device's millibel range.
  Map<int, int> levelsForBands(
    List<AudioEffectBandCapability> bands, {
    required int minLevelMillibels,
    required int maxLevelMillibels,
  }) {
    return {
      for (final band in bands)
        band.index: _levelForFrequency(
          band.centerFrequencyHz,
          minLevelMillibels,
          maxLevelMillibels,
        ),
    };
  }

  int _levelForFrequency(int frequencyHz, int minLevel, int maxLevel) {
    if (frequencyHz <= 0) return 0.clamp(minLevel, maxLevel).toInt();

    final frequency = frequencyHz.toDouble();
    if (frequency <= _anchorFrequencies.first) {
      return _toMillibels(anchorGainsDb.first, minLevel, maxLevel);
    }
    if (frequency >= _anchorFrequencies.last) {
      return _toMillibels(anchorGainsDb.last, minLevel, maxLevel);
    }

    for (var index = 0; index < _anchorFrequencies.length - 1; index++) {
      final lowerFrequency = _anchorFrequencies[index];
      final upperFrequency = _anchorFrequencies[index + 1];
      if (frequency < lowerFrequency || frequency > upperFrequency) continue;

      final position = (math.log(frequency) - math.log(lowerFrequency)) /
          (math.log(upperFrequency) - math.log(lowerFrequency));
      final lowerGain = anchorGainsDb[index];
      final upperGain = anchorGainsDb[index + 1];
      final gain = lowerGain + (upperGain - lowerGain) * position;
      return _toMillibels(gain, minLevel, maxLevel);
    }

    return 0.clamp(minLevel, maxLevel).toInt();
  }

  int _toMillibels(double gainDb, int minLevel, int maxLevel) {
    final millibels = (gainDb * 100).round();
    return millibels.clamp(minLevel, maxLevel).toInt();
  }
}
