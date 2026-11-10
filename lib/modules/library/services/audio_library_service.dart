import 'package:flutter/services.dart';

import '../models/song.dart';

class AudioLibraryService {
  static const MethodChannel _channel = MethodChannel('dn_audio/audio_library');

  Future<bool> hasPermission() async {
    return await _channel.invokeMethod<bool>('hasPermission') ?? false;
  }

  Future<bool> requestPermission() async {
    return await _channel.invokeMethod<bool>('requestPermission') ?? false;
  }

  Future<List<Song>> getSongs() async {
    final result = await _channel.invokeMethod<List<dynamic>>('getSongs');
    return (result ?? const [])
        .whereType<Map<dynamic, dynamic>>()
        .map(Song.fromMap)
        .where((song) => song.id.isNotEmpty && song.contentUri.isNotEmpty)
        .toList(growable: false);
  }
}
