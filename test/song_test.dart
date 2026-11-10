import 'package:flutter_test/flutter_test.dart';

import 'package:dn_audio/modules/library/models/song.dart';

void main() {
  group('Song.fromMap', () {
    test('parses MediaStore values into a song', () {
      final song = Song.fromMap({
        'id': 42,
        'title': 'Test Track',
        'artist': 'Test Artist',
        'album': 'Test Album',
        'duration': 125000,
        'uri': 'content://media/external/audio/media/42',
        'albumArtUri': 'content://media/external/audio/albumart/7',
        'size': 2048000,
        'dateAdded': 1730000000,
      });

      expect(song.id, '42');
      expect(song.title, 'Test Track');
      expect(song.artist, 'Test Artist');
      expect(song.album, 'Test Album');
      expect(song.durationMs, 125000);
      expect(song.contentUri, 'content://media/external/audio/media/42');
      expect(song.albumArtUri, 'content://media/external/audio/albumart/7');
      expect(song.sizeBytes, 2048000);
      expect(song.dateAdded, 1730000000);
      expect(song.durationLabel, '2:05');
    });

    test('uses safe defaults for missing and malformed metadata', () {
      final song = Song.fromMap({
        'id': null,
        'title': '  ',
        'artist': null,
        'album': '',
        'duration': 'not-a-number',
        'uri': null,
        'albumArtUri': ' ',
        'size': null,
        'dateAdded': 'invalid',
      });

      expect(song.id, isEmpty);
      expect(song.title, 'Unknown title');
      expect(song.artist, 'Unknown artist');
      expect(song.album, 'Unknown album');
      expect(song.durationMs, 0);
      expect(song.contentUri, isEmpty);
      expect(song.albumArtUri, isNull);
      expect(song.sizeBytes, 0);
      expect(song.dateAdded, 0);
      expect(song.durationLabel, '0:00');
    });

    test('parses numeric strings for integer fields', () {
      final song = Song.fromMap({
        'duration': '65000',
        'size': '1024',
        'dateAdded': '12345',
      });

      expect(song.durationMs, 65000);
      expect(song.sizeBytes, 1024);
      expect(song.dateAdded, 12345);
    });
  });
}
