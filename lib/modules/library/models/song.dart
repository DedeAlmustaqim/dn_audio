class Song {
  const Song({required this.id, required this.title, required this.artist, required this.album, required this.durationMs, required this.contentUri, required this.albumArtUri, required this.sizeBytes, required this.dateAdded});
  final String id, title, artist, album, contentUri;
  final int durationMs, sizeBytes, dateAdded;
  final String? albumArtUri;

  factory Song.fromMap(Map<dynamic, dynamic> map) => Song(
    id: map['id']?.toString() ?? '',
    title: map['title']?.toString() ?? 'Unknown title',
    artist: map['artist']?.toString() ?? 'Unknown artist',
    album: map['album']?.toString() ?? 'Unknown album',
    durationMs: (map['duration'] as num?)?.toInt() ?? 0,
    contentUri: map['uri']?.toString() ?? '',
    albumArtUri: map['albumArtUri']?.toString(),
    sizeBytes: (map['size'] as num?)?.toInt() ?? 0,
    dateAdded: (map['dateAdded'] as num?)?.toInt() ?? 0,
  );

  String get durationLabel {
    final totalSeconds = durationMs ~/ 1000;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
