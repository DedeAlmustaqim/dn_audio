class PlaybackPreferences {
  const PlaybackPreferences({this.speed = 1.0});

  static const List<double> supportedSpeeds = [
    0.5,
    0.75,
    1.0,
    1.25,
    1.5,
    1.75,
    2.0,
  ];

  final double speed;

  bool get hasValidSpeed => supportedSpeeds.contains(speed);

  PlaybackPreferences copyWith({double? speed}) {
    return PlaybackPreferences(speed: speed ?? this.speed);
  }

  Map<String, dynamic> toMap() => {'speed': speed};

  factory PlaybackPreferences.fromMap(Map<String, dynamic> map) {
    final rawSpeed = map['speed'];
    final speed = rawSpeed is num ? rawSpeed.toDouble() : 1.0;
    return PlaybackPreferences(
      speed: supportedSpeeds.contains(speed) ? speed : 1.0,
    );
  }
}
