import 'package:flutter/services.dart';

import '../../settings/models/audio_library_preferences.dart';
import '../models/song.dart';

class AudioLibraryService {
  static const MethodChannel _channel = MethodChannel('dn_audio/audio_library');

  Future<bool> hasPermission() async {
    return await _channel.invokeMethod<bool>('hasPermission') ?? false;
  }

  Future<bool> requestPermission() async {
    return await _channel.invokeMethod<bool>('requestPermission') ?? false;
  }

  Future<List<Song>> getSongs({Set<String>? extensions}) async {
    final selectedExtensions = AudioLibraryPreferences.normalizeExtensions(
      extensions ?? AudioLibraryPreferences.defaultExtensions,
    ).toList(growable: false);
    final result = await _channel.invokeMethod<List<dynamic>>(
      'getSongs',
      {'extensions': selectedExtensions},
    );
    return (result ?? const [])
        .whereType<Map<dynamic, dynamic>>()
        .map(Song.fromMap)
        .where((song) => song.id.isNotEmpty && song.contentUri.isNotEmpty)
        .toList(growable: false);
  }
}