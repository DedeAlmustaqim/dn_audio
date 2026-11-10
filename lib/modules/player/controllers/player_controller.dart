import 'dart:async';

import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

import '../../library/models/song.dart';

class PlayerController extends GetxController {
  AudioPlayer? _player;

  final currentSong = Rxn<Song>();
  final isPlaying = false.obs;
  final isBuffering = false.obs;
  final position = Duration.zero.obs;
  final duration = Duration.zero.obs;
  final playbackError = RxnString();
  final isShuffleEnabled = false.obs;
  final loopMode = LoopMode.off.obs;

  List<Song> _queue = <Song>[];
  StreamSubscription<PlayerState>? _playerStateSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration?>? _durationSubscription;
  StreamSubscription<SequenceState>? _sequenceSubscription;
  StreamSubscription<bool>? _shuffleSubscription;
  StreamSubscription<LoopMode>? _loopSubscription;
  StreamSubscription<PlayerException>? _errorSubscription;

  void _initializePlayer() {
    if (_player != null) return;

    final player = AudioPlayer();
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
      if (tag is Song) currentSong.value = tag;
    });
    _shuffleSubscription = player.shuffleModeEnabledStream.listen((value) {
      isShuffleEnabled.value = value;
    });
    _loopSubscription = player.loopModeStream.listen((value) {
      loopMode.value = value;
    });
    _errorSubscription = player.errorStream.listen((error) {
      _setPlaybackError(error);
    });
  }

  void _setPlaybackError(Object error) {
    playbackError.value = error is PlayerException
        ? (error.message ?? 'Unable to play this audio file.')
        : error.toString();
    isPlaying.value = false;
    isBuffering.value = false;
  }

  Future<void> _playSafely(AudioPlayer player) async {
    try {
      await player.play();
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
    _queue = List<Song>.unmodifiable(songs);
    playbackError.value = null;
    position.value = Duration.zero;
    currentSong.value = song;

    try {
      await player.setAudioSources(
        _queue
            .map((item) => AudioSource.uri(Uri.parse(item.contentUri), tag: item))
            .toList(growable: false),
        initialIndex: selectedIndex,
        initialPosition: Duration.zero,
      );
      unawaited(_playSafely(player));
    } catch (error) {
      _setPlaybackError('Could not play this song: $error');
    }
  }

  Future<void> togglePlayPause() async {
    final player = _player;
    if (currentSong.value == null || player == null) return;

    try {
      if (player.playing) {
        await player.pause();
      } else {
        if (player.processingState == ProcessingState.completed) {
          await player.seek(Duration.zero);
        }
        unawaited(_playSafely(player));
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
    final player = _player;
    if (player == null) return;
    await _runPlayerAction(() => player.seek(value));
  }

  Future<void> skipNext() async {
    final player = _player;
    if (player == null || !player.hasNext) return;
    await _runPlayerAction(player.seekToNext);
  }

  Future<void> skipPrevious() async {
    final player = _player;
    if (player == null) return;

    await _runPlayerAction(() async {
      if (player.hasPrevious && player.position > const Duration(seconds: 3)) {
        await player.seek(Duration.zero);
      } else if (player.hasPrevious) {
        await player.seekToPrevious();
      } else {
        await player.seek(Duration.zero);
      }
    });
  }

  Future<void> toggleShuffle() async {
    final player = _player;
    if (player == null) return;

    await _runPlayerAction(
      () => player.setShuffleModeEnabled(!player.shuffleModeEnabled),
    );
  }

  Future<void> cycleLoopMode() async {
    final player = _player;
    if (player == null) return;
    final next = switch (player.loopMode) {
      LoopMode.off => LoopMode.all,
      LoopMode.all => LoopMode.one,
      LoopMode.one => LoopMode.off,
    };
    await _runPlayerAction(() => player.setLoopMode(next));
  }

  String formatDuration(Duration value) {
    final minutes = value.inMinutes;
    final seconds = value.inSeconds.remainder(60);
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
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
    _player?.dispose();
    super.onClose();
  }
}
