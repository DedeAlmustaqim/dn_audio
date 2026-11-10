import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

import '../../library/models/song.dart';

class DnAudioHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  final AudioPlayer player = AudioPlayer();

  StreamSubscription<PlaybackEvent>? _playbackEventSubscription;
  StreamSubscription<SequenceState>? _sequenceStateSubscription;

  DnAudioHandler() {
    _playbackEventSubscription =
        player.playbackEventStream.listen(_broadcastPlaybackState);
    _sequenceStateSubscription =
        player.sequenceStateStream.listen(_broadcastCurrentMediaItem);
  }

  Future<void> loadPlaylist(List<Song> songs, int initialIndex) async {
    queue.add(songs.map(_toMediaItem).toList(growable: false));
    await player.setAudioSources(
      songs
          .map((song) => AudioSource.uri(
                Uri.parse(song.contentUri),
                tag: song,
              ))
          .toList(growable: false),
      initialIndex: initialIndex,
      initialPosition: Duration.zero,
    );
    _broadcastCurrentMediaItem(player.sequenceState);
    _broadcastPlaybackState(player.playbackEvent);
  }

  MediaItem _toMediaItem(Song song) => MediaItem(
        id: song.contentUri,
        title: song.title,
        artist: song.artist,
        album: song.album,
        duration: song.duration,
        extras: {'songId': song.id},
      );

  void _broadcastCurrentMediaItem(SequenceState state) {
    final tag = state.currentSource?.tag;
    if (tag is Song) mediaItem.add(_toMediaItem(tag));
  }

  void _broadcastPlaybackState(PlaybackEvent event) {
    final processingState = switch (player.processingState) {
      ProcessingState.idle => AudioProcessingState.idle,
      ProcessingState.loading => AudioProcessingState.loading,
      ProcessingState.buffering => AudioProcessingState.buffering,
      ProcessingState.ready => AudioProcessingState.ready,
      ProcessingState.completed => AudioProcessingState.completed,
    };

    playbackState.add(
      PlaybackState(
        controls: [
          MediaControl.skipToPrevious,
          if (player.playing) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
        ],
        systemActions: const {MediaAction.seek},
        androidCompactActionIndices: const [0, 1, 2],
        processingState: processingState,
        playing: player.playing,
        updatePosition: player.position,
        bufferedPosition: player.bufferedPosition,
        speed: player.speed,
        queueIndex: event.currentIndex,
        repeatMode: switch (player.loopMode) {
          LoopMode.off => AudioServiceRepeatMode.none,
          LoopMode.one => AudioServiceRepeatMode.one,
          LoopMode.all => AudioServiceRepeatMode.all,
        },
        shuffleMode: player.shuffleModeEnabled
            ? AudioServiceShuffleMode.all
            : AudioServiceShuffleMode.none,
      ),
    );
  }

  @override
  Future<void> play() => player.play();

  @override
  Future<void> pause() => player.pause();

  @override
  Future<void> seek(Duration position) => player.seek(position);

  @override
  Future<void> stop() async {
    await player.stop();
    await super.stop();
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index < 0 || index >= player.sequence.length) return;
    await player.seek(Duration.zero, index: index);
  }

  @override
  Future<void> skipToNext() async {
    if (player.hasNext) await player.seekToNext();
  }

  @override
  Future<void> skipToPrevious() async {
    if (player.hasPrevious) {
      if (player.position > const Duration(seconds: 3)) {
        await player.seek(Duration.zero);
      } else {
        await player.seekToPrevious();
      }
    } else {
      await player.seek(Duration.zero);
    }
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) {
    final mode = switch (repeatMode) {
      AudioServiceRepeatMode.none => LoopMode.off,
      AudioServiceRepeatMode.one => LoopMode.one,
      AudioServiceRepeatMode.all => LoopMode.all,
      AudioServiceRepeatMode.group => LoopMode.all,
    };
    return player.setLoopMode(mode);
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) {
    return player.setShuffleModeEnabled(
      shuffleMode != AudioServiceShuffleMode.none,
    );
  }

  Future<void> dispose() async {
    await _playbackEventSubscription?.cancel();
    await _sequenceStateSubscription?.cancel();
    await player.dispose();
  }
}
