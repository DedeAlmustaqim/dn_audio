import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../models/song.dart';
import '../services/audio_library_service.dart';

class LibraryController extends GetxController {
  LibraryController({AudioLibraryService? service})
      : _service = service ?? AudioLibraryService();

  final AudioLibraryService _service;
  final songs = <Song>[].obs;
  final searchQuery = ''.obs;
  final isLoading = false.obs;
  final hasPermission = false.obs;
  final errorMessage = RxnString();

  bool _hasLoaded = false;
  Future<void>? _refreshFuture;

  List<Song> get filteredSongs {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return songs;

    return songs
        .where(
          (song) =>
              song.title.toLowerCase().contains(query) ||
              song.artist.toLowerCase().contains(query) ||
              song.album.toLowerCase().contains(query),
        )
        .toList(growable: false);
  }

  Future<void> ensureLoaded() {
    if (_hasLoaded) return Future<void>.value();
    return refreshLibrary();
  }

  Future<void> refreshLibrary() {
    final inFlight = _refreshFuture;
    if (inFlight != null) return inFlight;

    late final Future<void> trackedRefresh;
    trackedRefresh = _performRefresh().whenComplete(() {
      if (identical(_refreshFuture, trackedRefresh)) {
        _refreshFuture = null;
      }
    });
    _refreshFuture = trackedRefresh;
    return trackedRefresh;
  }

  Future<void> _performRefresh() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      var granted = await _service.hasPermission();
      if (!granted) {
        granted = await _service.requestPermission();
      }

      hasPermission.value = granted;
      if (!granted) {
        songs.clear();
        _hasLoaded = true;
        return;
      }

      songs.assignAll(await _service.getSongs());
      _hasLoaded = true;
    } on PlatformException catch (error) {
      errorMessage.value =
          error.message ?? 'Unable to read music on this device.';
    } catch (_) {
      errorMessage.value = 'Something went wrong while scanning your music.';
    } finally {
      isLoading.value = false;
    }
  }

  void updateSearch(String value) => searchQuery.value = value;
}
