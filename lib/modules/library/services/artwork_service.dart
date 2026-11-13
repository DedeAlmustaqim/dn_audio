import 'package:flutter/services.dart';

import '../models/song.dart';

class ArtworkService {
  ArtworkService._();

  static const MethodChannel _channel = MethodChannel('dn_audio/audio_library');
  static final Map<String, Future<Uri?>> _cache = {};
  static Future<int>? _clearOperation;

  static Future<Uri?> resolve(Song song) async {
    final clearing = _clearOperation;
    if (clearing != null) await clearing;

    final cached = _cache[song.id];
    if (cached != null) return cached;

    final request = _resolve(song);
    _cache[song.id] = request;
    return request;
  }

  static Future<int> clearCache() {
    final activeOperation = _clearOperation;
    if (activeOperation != null) return activeOperation;

    final operation = _performCacheClear();
    _clearOperation = operation;
    return operation;
  }

  static Future<int> _performCacheClear() async {
    try {
      final pendingResolutions = _cache.values
          .map((future) => future.then<void>((_) {}, onError: (_) {}))
          .toList(growable: false);
      await Future.wait(pendingResolutions);

      final deletedCount = await _channel.invokeMethod<int>(
        'clearArtworkCache',
      );
      _cache.clear();
      return deletedCount ?? 0;
    } finally {
      _clearOperation = null;
    }
  }

  static Future<ArtworkCacheInfo> getCacheInfo() async {
    final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
      'getArtworkCacheInfo',
    );
    return ArtworkCacheInfo.fromMap(result ?? const {});
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


class ArtworkCacheInfo {
  const ArtworkCacheInfo({
    required this.fileCount,
    required this.totalBytes,
  });

  final int fileCount;
  final int totalBytes;

  factory ArtworkCacheInfo.fromMap(Map<dynamic, dynamic> map) {
    return ArtworkCacheInfo(
      fileCount: (map['fileCount'] as num?)?.toInt() ?? 0,
      totalBytes: (map['totalBytes'] as num?)?.toInt() ?? 0,
    );
  }

  String get formattedSize {
    if (totalBytes < 1024) return '$totalBytes B';
    if (totalBytes < 1024 * 1024) {
      return '${(totalBytes / 1024).toStringAsFixed(1)} KB';
    }
    if (totalBytes < 1024 * 1024 * 1024) {
      return '${(totalBytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
    return '${(totalBytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}
