import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

import '../../../core/constants/app_colors.dart';
import '../controllers/player_controller.dart';

class NowPlayingView extends GetView<PlayerController> {
  const NowPlayingView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.88,
        child: Obx(() {
          final song = controller.currentSong.value;
          if (song == null) return const Center(child: Text('Nothing playing'));

          final totalMs = controller.duration.value.inMilliseconds;
          final currentMs = controller.position.value.inMilliseconds;
          final sliderMax = totalMs > 0 ? totalMs.toDouble() : 1.0;
          final sliderValue = currentMs.clamp(0, totalMs > 0 ? totalMs : 1).toDouble();

          return Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              children: [
                Container(width: 42, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(4))),
                const SizedBox(height: 28),
                Row(children: [
                  IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.keyboard_arrow_down_rounded)),
                  const Spacer(),
                  const Text('NOW PLAYING', style: TextStyle(fontSize: 11, letterSpacing: 2, color: AppColors.textSecondary, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  const SizedBox(width: 48),
                ]),
                const Spacer(),
                AspectRatio(
                  aspectRatio: 1,
                  child: Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxWidth: 310),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [AppColors.primary.withValues(alpha: 0.28), AppColors.surfaceElevated], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Icon(Icons.graphic_eq_rounded, size: 112, color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 34),
                Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(song.artist, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 15, color: AppColors.textSecondary)),
                if (controller.playbackError.value != null) ...[
                  const SizedBox(height: 12),
                  Text(controller.playbackError.value!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
                ],
                const SizedBox(height: 28),
                Slider(
                  min: 0,
                  max: sliderMax,
                  value: sliderValue,
                  onChanged: totalMs <= 0 ? null : (value) => controller.seek(Duration(milliseconds: value.round())),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(children: [
                    Text(controller.formatDuration(controller.position.value), style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    const Spacer(),
                    Text(controller.formatDuration(controller.duration.value), style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ]),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(onPressed: controller.toggleShuffle, icon: Icon(Icons.shuffle_rounded, color: controller.isShuffleEnabled.value ? AppColors.primary : AppColors.textSecondary)),
                    IconButton(onPressed: controller.skipPrevious, icon: const Icon(Icons.skip_previous_rounded, size: 38)),
                    Container(
                      width: 68,
                      height: 68,
                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      child: IconButton(
                        onPressed: controller.togglePlayPause,
                        icon: controller.isBuffering.value
                            ? const SizedBox(width: 25, height: 25, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.background))
                            : Icon(controller.isPlaying.value ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 36, color: AppColors.background),
                      ),
                    ),
                    IconButton(onPressed: controller.skipNext, icon: const Icon(Icons.skip_next_rounded, size: 38)),
                    IconButton(onPressed: controller.cycleLoopMode, icon: Icon(controller.loopMode.value == LoopMode.one ? Icons.repeat_one_rounded : Icons.repeat_rounded, color: controller.loopMode.value == LoopMode.off ? AppColors.textSecondary : AppColors.primary)),
                  ],
                ),
                const Spacer(),
              ],
            ),
          );
        }),
      ),
    );
  }
}
