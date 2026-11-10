import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../models/song.dart';
import '../services/audio_library_service.dart';

class LibraryController extends GetxController {
  LibraryController({AudioLibraryService? service}) : _service = service ?? AudioLibraryService();
  final AudioLibraryService _service;
  final songs = <Song>[].obs;
  final searchQuery = ''.obs;
  final isLoading = false.obs;
  final hasPermission = false.obs;
  final errorMessage = RxnString();

  List<Song> get filteredSongs {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) return songs;
    return songs.where((song) => song.title.toLowerCase().contains(query) || song.artist.toLowerCase().contains(query) || song.album.toLowerCase().contains(query)).toList(growable: false);
  }

  @override
  void onInit() {
    super.onInit();
    refreshLibrary();
  }

  Future<void> refreshLibrary() async {
    if (isLoading.value) return;
    isLoading.value = true;
    errorMessage.value = null;
    try {
      var granted = await _service.hasPermission();
      if (!granted) granted = await _service.requestPermission();
      hasPermission.value = granted;
      if (!granted) {
        songs.clear();
        return;
      }
      songs.assignAll(await _service.getSongs());
    } on PlatformException catch (error) {
      errorMessage.value = error.message ?? 'Unable to read music on this device.';
    } catch (_) {
      errorMessage.value = 'Something went wrong while scanning your music.';
    } finally {
      isLoading.value = false;
    }
  }

  void updateSearch(String value) => searchQuery.value = value;
}
