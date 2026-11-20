import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

class AppUpdateInfo {
  const AppUpdateInfo({
    required this.latestVersion,
    required this.releaseNotes,
    required this.playStoreUrl,
    required this.isUpdateAvailable,
  });

  final String latestVersion;
  final String releaseNotes;
  final String playStoreUrl;
  final bool isUpdateAvailable;
}

class UpdateCheckerService {
  static final Uri _manifestUri = Uri.parse(
    'https://raw.githubusercontent.com/DedeAlmustaqim/dn_audio_privacy/main/update_dn_audio.json',
  );

  Future<AppUpdateInfo?> checkForUpdate() async {
    try {
      final response = await http
          .get(
            _manifestUri,
            headers: const {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) {
        debugPrint('DN Audio update check: HTTP ${response.statusCode}');
        return null;
      }

      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! Map<String, dynamic>) return null;

      final latestVersion = decoded['latestVersion'];
      final releaseNotes = decoded['releaseNotes'];
      final playStoreUrl = decoded['playStoreUrl'];

      if (latestVersion is! String ||
          releaseNotes is! String ||
          playStoreUrl is! String ||
          latestVersion.trim().isEmpty) {
        debugPrint('DN Audio update check: invalid manifest fields');
        return null;
      }

      final storeUri = Uri.tryParse(playStoreUrl);
      if (storeUri == null ||
          storeUri.scheme != 'https' ||
          storeUri.host != 'play.google.com' ||
          storeUri.path != '/store/apps/details') {
        debugPrint('DN Audio update check: invalid Play Store URL');
        return null;
      }

      final packageInfo = await PackageInfo.fromPlatform();
      final isUpdateAvailable =
          _compareVersions(latestVersion, packageInfo.version) > 0;

      return AppUpdateInfo(
        latestVersion: latestVersion.trim(),
        releaseNotes: releaseNotes.trim(),
        playStoreUrl: storeUri.toString(),
        isUpdateAvailable: isUpdateAvailable,
      );
    } catch (error, stackTrace) {
      debugPrint('DN Audio update check failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      return null;
    }
  }

  int _compareVersions(String remote, String current) {
    final remoteParts = _parseVersion(remote);
    final currentParts = _parseVersion(current);
    if (remoteParts == null || currentParts == null) return 0;

    final length = remoteParts.length > currentParts.length
        ? remoteParts.length
        : currentParts.length;

    for (var index = 0; index < length; index++) {
      final remotePart = index < remoteParts.length ? remoteParts[index] : 0;
      final currentPart =
          index < currentParts.length ? currentParts[index] : 0;
      if (remotePart != currentPart) {
        return remotePart.compareTo(currentPart);
      }
    }
    return 0;
  }

  List<int>? _parseVersion(String version) {
    final normalized = version.trim().replaceFirst(RegExp(r'^[vV]'), '');
    final core = normalized.split('+').first.split('-').first;
    final parts = core.split('.');
    if (parts.isEmpty) return null;

    final parsed = <int>[];
    for (final part in parts) {
      final value = int.tryParse(part);
      if (value == null || value < 0) return null;
      parsed.add(value);
    }
    return parsed;
  }
}
