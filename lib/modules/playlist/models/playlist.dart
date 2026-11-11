class Playlist {
  const Playlist({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.songCount = 0,
  });

  final int id;
  final String name;
  final int createdAt;
  final int updatedAt;
  final int songCount;

  factory Playlist.fromMap(Map<String, Object?> map) {
    return Playlist(
      id: (map['id'] as num).toInt(),
      name: map['name'] as String,
      createdAt: (map['created_at'] as num).toInt(),
      updatedAt: (map['updated_at'] as num).toInt(),
      songCount: ((map['song_count'] as num?) ?? 0).toInt(),
    );
  }
}
