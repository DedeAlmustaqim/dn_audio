import 'package:get/get.dart';

import '../../library/models/song.dart';
import '../models/playlist.dart';
import '../models/playlist_song.dart';
import '../services/playlist_repository.dart';

class PlaylistController extends GetxController {
  PlaylistController({PlaylistRepository? repository})
      : _repository = repository ?? PlaylistRepository();

  final PlaylistRepository _repository;

  final playlists = <Playlist>[].obs;
  final playlistSongs = <int, List<PlaylistSong>>{}.obs;
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

  Future<List<PlaylistSong>> loadPlaylistSongs(int playlistId) async {
    try {
      final songs = await _repository.getPlaylistSongs(playlistId);
      playlistSongs[playlistId] = songs;
      return songs;
    } catch (_) {
      errorMessage.value = 'Unable to load songs in this playlist.';
      return const [];
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
      playlistSongs.remove(id);
    });
  }

  Future<bool> addSongToPlaylist(int playlistId, Song song) async {
    return _runMutation(() async {
      await _repository.addSongToPlaylist(playlistId, song);
    });
  }

  Future<bool> removeSongFromPlaylist(
    int playlistId,
    String contentUri,
  ) async {
    return _runMutation(() async {
      await _repository.removeSongFromPlaylist(playlistId, contentUri);
      await loadPlaylistSongs(playlistId);
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
    } on PlaylistSongAlreadyExistsException {
      errorMessage.value = 'This song is already in the playlist.';
    } on InvalidPlaylistSongException {
      errorMessage.value = 'This song cannot be added to the playlist.';
    } on PlaylistSongNotFoundException {
      errorMessage.value = 'This song is no longer in the playlist.';
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
