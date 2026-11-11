import 'song.dart';

class AlbumCollection {
  const AlbumCollection({
    required this.id,
    required this.title,
    required this.artist,
    required this.songs,
  });

  final String id;
  final String title;
  final String artist;
  final List<Song> songs;

  int get songCount => songs.length;
  Song get artworkSong => songs.first;
}

class ArtistCollection {
  const ArtistCollection({
    required this.id,
    required this.name,
    required this.songs,
  });

  final String id;
  final String name;
  final List<Song> songs;

  int get songCount => songs.length;

  int get albumCount => songs
      .map(_albumKey)
      .toSet()
      .length;

  Song get artworkSong => songs.first;
}

String normalizeCollectionLabel(String value) => value.trim().toLowerCase();

String albumCollectionKey(Song song) {
  final albumId = song.albumId;
  if (albumId != null && albumId > 0) return 'album:$albumId';
  return 'album-name:${normalizeCollectionLabel(song.album)}'
      '|artist:${normalizeCollectionLabel(song.artist)}';
}

String artistCollectionKey(Song song) {
  final artistId = song.artistId;
  if (artistId != null && artistId > 0) return 'artist:$artistId';
  return 'artist-name:${normalizeCollectionLabel(song.artist)}';
}

String _albumKey(Song song) => albumCollectionKey(song);
