import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

import '../../library/models/song.dart';
import '../services/dn_audio_handler.dart';

class PlayerController extends GetxController {
  DnAudioHandler? _audioHandler;
  AudioPlayer? _player;

  final currentSong = Rxn<Song>();
  final currentArtworkUri = Rxn<Uri>();
  final isPlaying = false.obs;
  final isBuffering = false.obs;
  final position = Duration.zero.obs;
  final duration = Duration.zero.obs;
  final playbackError = RxnString();
  final isShuffleEnabled = false.obs;
  final loopMode = LoopMode.off.obs;

  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration?>? _durationSubscription;
  StreamSubscription<SequenceState>? _sequenceSubscription;
  StreamSubscription<bool>? _shuffleSubscription;
  StreamSubscription<LoopMode>? _loopSubscription;
  StreamSubscription<PlayerException>? _errorSubscription;
  StreamSubscription<MediaItem?>? _mediaItemSubscription;

  void _initializePlayer() {
    if (_player != null) return;

    final handler = Get.find<DnAudioHandler>();
    final player = handler.player;
    _audioHandler = handler;
    _player = player;

    _playerStateSubscription = player.playerStateStream.listen((state) {
      isPlaying.value = state.playing;
      isBuffering.value = state.processingState == ProcessingState.loading ||
          state.processingState == ProcessingState.buffering;
      if (state.processingState == ProcessingState.completed) {
        position.value = duration.value;
      }
    });
    _positionSubscription = player.positionStream.listen((value) {
      position.value = value;
    });
    _durationSubscription = player.durationStream.listen((value) {
      duration.value = value ?? Duration.zero;
    });
    _sequenceSubscription = player.sequenceStateStream.listen((state) {
      final tag = state.currentSource?.tag;
      if (tag is Song && currentSong.value?.id != tag.id) {
        currentSong.value = tag;
        currentArtworkUri.value = null;
      }
    });
    _mediaItemSubscription = handler.mediaItem.listen((item) {
      final song = currentSong.value;
      if (item == null || song == null || item.id != song.contentUri) return;
      currentArtworkUri.value = item.artUri;
    });
    _shuffleSubscription = player.shuffleModeEnabledStream.listen((value) {
      isShuffleEnabled.value = value;
    });
    _loopSubscription = player.loopModeStream.listen((value) {
      loopMode.value = value;
    });
    _errorSubscription = player.errorStream.listen(_setPlaybackError);
  }

  void _setPlaybackError(Object error) {
    playbackError.value = error is PlayerException
        ? (error.message ?? 'Unable to play this audio file.')
        : error.toString();
    isPlaying.value = false;
    isBuffering.value = false;
  }

  Future<void> _playSafely(DnAudioHandler handler) async {
    try {
      await handler.play();
    } catch (error) {
      _setPlaybackError(error);
    }
  }

  Future<void> playSong(Song song, List<Song> songs) async {
    if (songs.isEmpty) return;
    final selectedIndex = songs.indexWhere((item) => item.id == song.id);
    if (selectedIndex < 0) return;

    _initializePlayer();
    final player = _player!;
    final handler = _audioHandler!;
    playbackError.value = null;
    position.value = Duration.zero;
    currentSong.value = song;

    try {
      await handler.loadPlaylist(songs, selectedIndex);
      unawaited(_playSafely(handler));
    } catch (error) {
      _setPlaybackError('Could not play this song: $error');
    }
  }

  Future<void> togglePlayPause() async {
    final player = _player;
    final handler = _audioHandler;
    if (currentSong.value == null || player == null || handler == null) {
      return;
    }

    try {
      if (player.playing) {
        await handler.pause();
      } else {
        if (player.processingState == ProcessingState.completed) {
          await handler.seek(Duration.zero);
        }
        unawaited(_playSafely(handler));
      }
    } catch (error) {
      _setPlaybackError(error);
    }
  }

  Future<void> _runPlayerAction(Future<void> Function() action) async {
    try {
      await action();
    } catch (error) {
      _setPlaybackError(error);
    }
  }

  Future<void> seek(Duration value) async {
    final handler = _audioHandler;
    if (handler == null) return;
    await _runPlayerAction(() => handler.seek(value));
  }

  Future<void> skipNext() async {
    final handler = _audioHandler;
    final player = _player;
    if (handler == null || player == null || !player.hasNext) return;
    await _runPlayerAction(handler.skipToNext);
  }

  Future<void> skipPrevious() async {
    final handler = _audioHandler;
    if (handler == null) return;
    await _runPlayerAction(handler.skipToPrevious);
  }

  Future<void> toggleShuffle() async {
    final handler = _audioHandler;
    final player = _player;
    if (handler == null || player == null) return;

    await _runPlayerAction(
      () => handler.setShuffleMode(
        player.shuffleModeEnabled
            ? AudioServiceShuffleMode.none
            : AudioServiceShuffleMode.all,
      ),
    );
  }

  Future<void> cycleLoopMode() async {
    final handler = _audioHandler;
    final player = _player;
    if (handler == null || player == null) return;

    final next = switch (player.loopMode) {
      LoopMode.off => AudioServiceRepeatMode.all,
      LoopMode.all => AudioServiceRepeatMode.one,
      LoopMode.one => AudioServiceRepeatMode.none,
    };
    await _runPlayerAction(() => handler.setRepeatMode(next));
  }

  String formatDuration(Duration value) {
    final minutes = value.inMinutes;
    final seconds = value.inSeconds.remainder(60);
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void onClose() {
    _playerStateSubscription?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _sequenceSubscription?.cancel();
    _shuffleSubscription?.cancel();
    _loopSubscription?.cancel();
    _errorSubscription?.cancel();
    _mediaItemSubscription?.cancel();
    _player = null;
    _audioHandler = null;
    super.onClose();
  }
}
