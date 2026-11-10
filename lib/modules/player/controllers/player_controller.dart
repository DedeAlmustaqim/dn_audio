import 'dart:async';

import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

import '../../library/models/song.dart';

class PlayerController extends GetxController {
  final AudioPlayer _player = AudioPlayer();

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
  StreamSubscription<int?>? _indexSubscription;
  StreamSubscription<bool>? _shuffleSubscription;
  StreamSubscription<LoopMode>? _loopSubscription;
  StreamSubscription<PlayerException>? _errorSubscription;

  AudioPlayer get audioPlayer => _player;

  @override
  void onInit() {
    super.onInit();
    _playerStateSubscription = _player.playerStateStream.listen((state) {
      isPlaying.value = state.playing;
      isBuffering.value = state.processingState == ProcessingState.loading ||
          state.processingState == ProcessingState.buffering;
      if (state.processingState == ProcessingState.completed) {
        position.value = duration.value;
      }
    });
    _positionSubscription = _player.positionStream.listen((value) {
      position.value = value;
    });
    _durationSubscription = _player.durationStream.listen((value) {
      duration.value = value ?? Duration.zero;
    });
    _indexSubscription = _player.currentIndexStream.listen((index) {
      if (index != null && index >= 0 && index < _queue.length) {
        currentSong.value = _queue[index];
      }
    });
    _shuffleSubscription = _player.shuffleModeEnabledStream.listen((value) {
      isShuffleEnabled.value = value;
    });
    _loopSubscription = _player.loopModeStream.listen((value) {
      loopMode.value = value;
    });
    _errorSubscription = _player.errorStream.listen((error) {
      playbackError.value = error.message ?? 'Unable to play this audio file.';
    });
  }

  Future<void> playSong(Song song, List<Song> songs) async {
    if (songs.isEmpty) return;
    final selectedIndex = songs.indexWhere((item) => item.id == song.id);
    if (selectedIndex < 0) return;

    _queue = List<Song>.unmodifiable(songs);
    playbackError.value = null;
    position.value = Duration.zero;
    currentSong.value = song;

    try {
      await _player.setAudioSources(
        _queue
            .map((item) => AudioSource.uri(Uri.parse(item.contentUri)))
            .toList(growable: false),
        initialIndex: selectedIndex,
        initialPosition: Duration.zero,
      );
      unawaited(_player.play());
    } catch (error) {
      playbackError.value = 'Could not play this song: $error';
    }
  }

  Future<void> togglePlayPause() async {
    if (currentSong.value == null) return;
    if (_player.playing) {
      await _player.pause();
    } else {
      if (_player.processingState == ProcessingState.completed) {
        await _player.seek(Duration.zero);
      }
      unawaited(_player.play());
    }
  }

  Future<void> seek(Duration value) => _player.seek(value);

  Future<void> skipNext() async {
    if (_player.hasNext) {
      await _player.seekToNext();
    }
  }

  Future<void> skipPrevious() async {
    if (_player.hasPrevious && _player.position > const Duration(seconds: 3)) {
      await _player.seek(Duration.zero);
    } else if (_player.hasPrevious) {
      await _player.seekToPrevious();
    } else {
      await _player.seek(Duration.zero);
    }
  }

  Future<void> toggleShuffle() async {
    await _player.setShuffleModeEnabled(!_player.shuffleModeEnabled);
  }

  Future<void> cycleLoopMode() async {
    final next = switch (_player.loopMode) {
      LoopMode.off => LoopMode.all,
      LoopMode.all => LoopMode.one,
      LoopMode.one => LoopMode.off,
    };
    await _player.setLoopMode(next);
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
    _indexSubscription?.cancel();
    _shuffleSubscription?.cancel();
    _loopSubscription?.cancel();
    _errorSubscription?.cancel();
    _player.dispose();
    super.onClose();
  }
}
