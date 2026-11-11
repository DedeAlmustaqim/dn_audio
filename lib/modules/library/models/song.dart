class Song {
  const Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.durationMs,
    required this.contentUri,
    required this.albumArtUri,
    required this.sizeBytes,
    required this.dateAdded,
    this.albumId,
    this.artistId,
  });

  final String id;
  final String title;
  final String artist;
  final String album;
  final String contentUri;
  final int durationMs;
  final int sizeBytes;
  final int dateAdded;
  final String? albumArtUri;
  final int? albumId;
  final int? artistId;

  factory Song.fromMap(Map<dynamic, dynamic> map) {
    String readText(String key, String fallback) {
      final value = map[key]?.toString().trim();
      if (value == null ||
          value.isEmpty ||
          value.toLowerCase() == '<unknown>') {
        return fallback;
      }
      return value;
    }

    int readInt(String key) {
      final value = map[key];
      if (value is num) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? 0;
    }

    int? readOptionalId(String key) {
      final value = readInt(key);
      return value > 0 ? value : null;
    }

    final artUri = map['albumArtUri']?.toString().trim();

    return Song(
      id: readText('id', ''),
      title: readText('title', 'Unknown title'),
      artist: readText('artist', 'Unknown artist'),
      album: readText('album', 'Unknown album'),
      durationMs: readInt('duration'),
      contentUri: readText('uri', ''),
      albumArtUri: artUri == null || artUri.isEmpty ? null : artUri,
      sizeBytes: readInt('size'),
      dateAdded: readInt('dateAdded'),
      albumId: readOptionalId('albumId'),
      artistId: readOptionalId('artistId'),
    );
  }

  String get durationLabel {
    final totalSeconds = durationMs ~/ 1000;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
