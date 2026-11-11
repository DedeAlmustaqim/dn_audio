class AudioEffectBandCapability {
  const AudioEffectBandCapability({
    required this.index,
    required this.centerFrequencyHz,
    required this.minFrequencyHz,
    required this.maxFrequencyHz,
    this.levelMillibels = 0,
  });

  final int index;
  final int centerFrequencyHz;
  final int minFrequencyHz;
  final int maxFrequencyHz;
  final int levelMillibels;

  factory AudioEffectBandCapability.fromMap(Map<dynamic, dynamic> map) {
    return AudioEffectBandCapability(
      index: _readInt(map['index']) ?? 0,
      centerFrequencyHz: _readInt(map['centerFrequencyHz']) ?? 0,
      minFrequencyHz: _readInt(map['minFrequencyHz']) ?? 0,
      maxFrequencyHz: _readInt(map['maxFrequencyHz']) ?? 0,
      levelMillibels: _readInt(map['levelMillibels']) ?? 0,
    );
  }
}

class AudioEffectCapability {
  const AudioEffectCapability({
    required this.supported,
    this.enabled = false,
    this.error,
    this.bandCount,
    this.minLevelMillibels,
    this.maxLevelMillibels,
    this.bands = const [],
    this.presetCount,
    this.strengthSupported,
    this.minStrength,
    this.maxStrength,
  });

  final bool supported;
  final bool enabled;
  final String? error;
  final int? bandCount;
  final int? minLevelMillibels;
  final int? maxLevelMillibels;
  final List<AudioEffectBandCapability> bands;
  final int? presetCount;
  final bool? strengthSupported;
  final int? minStrength;
  final int? maxStrength;

  factory AudioEffectCapability.fromMap(Map<dynamic, dynamic>? map) {
    if (map == null) {
      return const AudioEffectCapability(supported: false, error: 'missing_capability_data');
    }

    final rawBands = map['bands'];
    final bands = rawBands is List
        ? rawBands
            .whereType<Map>()
            .map(AudioEffectBandCapability.fromMap)
            .toList(growable: false)
        : const <AudioEffectBandCapability>[];

    return AudioEffectCapability(
      supported: map['supported'] == true,
      enabled: map['enabled'] == true,
      error: map['error']?.toString(),
      bandCount: _readInt(map['bandCount']),
      minLevelMillibels: _readInt(map['minLevelMillibels']),
      maxLevelMillibels: _readInt(map['maxLevelMillibels']),
      bands: bands,
      presetCount: _readInt(map['presetCount']),
      strengthSupported: map['strengthSupported'] is bool
          ? map['strengthSupported'] as bool
          : null,
      minStrength: _readInt(map['minStrength']),
      maxStrength: _readInt(map['maxStrength']),
    );
  }
}

class AudioEffectsCapabilities {
  const AudioEffectsCapabilities({
    required this.available,
    this.sessionId,
    this.error,
    this.equalizer = const AudioEffectCapability(supported: false),
    this.bassBoost = const AudioEffectCapability(supported: false),
    this.virtualizer = const AudioEffectCapability(supported: false),
  });

  final bool available;
  final int? sessionId;
  final String? error;
  final AudioEffectCapability equalizer;
  final AudioEffectCapability bassBoost;
  final AudioEffectCapability virtualizer;

  factory AudioEffectsCapabilities.fromMap(Map<dynamic, dynamic>? map) {
    if (map == null) {
      return const AudioEffectsCapabilities(
        available: false,
        error: 'missing_capability_response',
      );
    }

    return AudioEffectsCapabilities(
      available: map['available'] == true,
      sessionId: _readInt(map['sessionId']),
      error: map['error']?.toString(),
      equalizer: AudioEffectCapability.fromMap(
        map['equalizer'] is Map ? map['equalizer'] as Map : null,
      ),
      bassBoost: AudioEffectCapability.fromMap(
        map['bassBoost'] is Map ? map['bassBoost'] as Map : null,
      ),
      virtualizer: AudioEffectCapability.fromMap(
        map['virtualizer'] is Map ? map['virtualizer'] as Map : null,
      ),
    );
  }

  factory AudioEffectsCapabilities.unavailable(String error) {
    return AudioEffectsCapabilities(available: false, error: error);
  }
}

int? _readInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return null;
}
