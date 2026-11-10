import 'package:flutter/services.dart';
import '../models/song.dart';

class AudioLibraryService {
  static const MethodChannel _channel = MethodChannel('dn_audio/audio_library');
  Future<bool> hasPermission() async => await _channel.invokeMethod<bool>('hasPermission') ?? false;
  Future<bool> requestPermission() async => await _channel.invokeMethod<bool>('requestPermission') ?? false;
  Future<List<Song>> getSongs() async {
    final result = await _channel.invokeMethod<List<dynamic>>('getSongs');
    return (result ?? const []).whereType<Map<dynamic, dynamic>>().map(Song.fromMap).toList(growable: false);
  }
}
