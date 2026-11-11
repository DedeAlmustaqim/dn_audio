import 'package:get/get.dart';

import '../models/playlist.dart';
import '../services/playlist_repository.dart';

class PlaylistController extends GetxController {
  PlaylistController({PlaylistRepository? repository})
      : _repository = repository ?? PlaylistRepository();

  final PlaylistRepository _repository;

  final playlists = <Playlist>[].obs;
  final isLoading = false.obs;
  final isSaving = false.obs;
  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadPlaylists();
  }

  Future<void> loadPlaylists() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      playlists.assignAll(await _repository.getPlaylists());
    } catch (_) {
      errorMessage.value = 'Unable to load playlists.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createPlaylist(String name) async {
    return _runMutation(() async {
      await _repository.createPlaylist(name);
    });
  }

  Future<bool> renamePlaylist(int id, String name) async {
    return _runMutation(() async {
      await _repository.renamePlaylist(id, name);
    });
  }

  Future<bool> deletePlaylist(int id) async {
    return _runMutation(() async {
      await _repository.deletePlaylist(id);
    });
  }

  Future<bool> _runMutation(Future<void> Function() action) async {
    if (isSaving.value) return false;
    isSaving.value = true;
    errorMessage.value = null;

    try {
      await action();
      await loadPlaylists();
      return true;
    } on PlaylistAlreadyExistsException {
      errorMessage.value = 'A playlist with this name already exists.';
    } on InvalidPlaylistNameException catch (error) {
      errorMessage.value = error.message;
    } on PlaylistNotFoundException {
      errorMessage.value = 'This playlist no longer exists.';
      await loadPlaylists();
    } catch (_) {
      errorMessage.value = 'Something went wrong. Please try again.';
    } finally {
      isSaving.value = false;
    }
    return false;
  }
}
