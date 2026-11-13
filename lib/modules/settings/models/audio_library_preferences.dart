class AudioLibraryPreferences {
  AudioLibraryPreferences({Set<String>? enabledExtensions})
      : enabledExtensions = Set.unmodifiable(
          normalizeExtensions(enabledExtensions ?? defaultExtensions),
        );

  static const List<String> supportedExtensions = [
    'mp3',
    'flac',
    'wav',
    'm4a',
    'aac',
    'ogg',
    'opus',
  ];

  static const Set<String> defaultExtensions = {
    'mp3',
    'flac',
    'wav',
    'm4a',
    'aac',
    'ogg',
    'opus',
  };

  final Set<String> enabledExtensions;

  static Set<String> normalizeExtensions(Iterable<String> extensions) {
    final normalized = extensions
        .map((extension) => extension.trim().toLowerCase().replaceFirst('.', ''))
        .where((extension) => supportedExtensions.contains(extension))
        .toSet();
    return normalized;
  }

  bool isEnabled(String extension) {
    final normalized = extension.trim().toLowerCase().replaceFirst('.', '');
    return enabledExtensions.contains(normalized);
  }

  AudioLibraryPreferences copyWith({Set<String>? enabledExtensions}) {
    return AudioLibraryPreferences(
      enabledExtensions: enabledExtensions ?? this.enabledExtensions,
    );
  }

  Map<String, dynamic> toMap() => {
        'enabledExtensions': supportedExtensions
            .where(enabledExtensions.contains)
            .toList(growable: false),
      };

  factory AudioLibraryPreferences.fromMap(Map<String, dynamic> map) {
    final rawExtensions = map['enabledExtensions'];
    if (rawExtensions is! List) {
      return AudioLibraryPreferences();
    }

    return AudioLibraryPreferences(
      enabledExtensions: rawExtensions.whereType<String>().toSet(),
    );
  }
}
