import '../../library/models/song.dart';

class PlaylistSong {
  const PlaylistSong({
    required this.playlistId,
    required this.song,
    required this.position,
  });

  final int playlistId;
  final Song song;
  final int position;

  factory PlaylistSong.fromMap(Map<String, Object?> map) {
    return PlaylistSong(
      playlistId: (map['playlist_id'] as num).toInt(),
      position: (map['position'] as num).toInt(),
      song: Song(
        id: map['song_id'] as String,
        title: map['title'] as String,
        artist: map['artist'] as String,
        album: map['album'] as String,
        durationMs: (map['duration_ms'] as num).toInt(),
        contentUri: map['content_uri'] as String,
        albumArtUri: map['album_art_uri'] as String?,
        sizeBytes: (map['size_bytes'] as num).toInt(),
        dateAdded: (map['date_added'] as num).toInt(),
      ),
    );
  }

  Map<String, Object?> toMap() => {
        'playlist_id': playlistId,
        'song_id': song.id,
        'title': song.title,
        'artist': song.artist,
        'album': song.album,
        'duration_ms': song.durationMs,
        'content_uri': song.contentUri,
        'album_art_uri': song.albumArtUri,
        'size_bytes': song.sizeBytes,
        'date_added': song.dateAdded,
        'position': position,
      };
}
