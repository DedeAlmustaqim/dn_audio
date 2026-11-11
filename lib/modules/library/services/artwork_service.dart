import 'package:flutter/services.dart';

import '../models/song.dart';

class ArtworkService {
  ArtworkService._();

  static const MethodChannel _channel = MethodChannel('dn_audio/audio_library');
  static final Map<String, Future<Uri?>> _cache = {};

  static Future<Uri?> resolve(Song song) {
    final cached = _cache[song.id];
    if (cached != null) return cached;

    final request = _resolve(song);
    _cache[song.id] = request;
    return request;
  }

  static Future<Uri?> _resolve(Song song) async {
    try {
      final value = await _channel.invokeMethod<String>(
        'resolveArtwork',
        {'contentUri': song.contentUri, 'songId': song.id},
      );
      if (value == null || value.isEmpty) return null;
      final uri = Uri.tryParse(value);
      return uri != null && uri.hasScheme ? uri : null;
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }
}
