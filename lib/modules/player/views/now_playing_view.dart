import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

import '../../../core/constants/app_colors.dart';
import '../../library/widgets/song_artwork.dart';
import '../controllers/player_controller.dart';
import '../controllers/sleep_timer_controller.dart';
import 'equalizer_view.dart';
import 'sleep_timer_sheet.dart';

class NowPlayingView extends GetView<PlayerController> {
  const NowPlayingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      child: SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.88,
          child: Obx(() {
            final song = controller.currentSong.value;
            if (song == null) {
              return const Center(child: Text('Nothing playing'));
            }

            final totalMs = controller.duration.value.inMilliseconds;
            final currentMs = controller.position.value.inMilliseconds;
            final sliderMax = totalMs > 0 ? totalMs.toDouble() : 1.0;
            final sliderValue = currentMs
                .clamp(0, totalMs > 0 ? totalMs : 1)
                .toDouble();

            return LayoutBuilder(
              builder: (context, constraints) {
                final artworkSize = math.min(
                  330.0,
                  math.min(
                    math.max(160.0, constraints.maxHeight * 0.39),
                    constraints.maxWidth - 44,
                  ),
                );

                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(22, 10, 22, 22),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Container(
                                width: 38,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: AppColors.border,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(height: 18),
                              Row(
                                children: [
                                  IconButton(
                                    tooltip: 'Close player',
                                    onPressed: () =>
                                        Navigator.of(context).maybePop(),
                                    icon: const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                    ),
                                  ),
                                  const Spacer(),
                                  Column(
                                    children: [
                                      Text(
                                        'NOW PLAYING',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                              color: AppColors.textSecondary,
                                              letterSpacing: 1.8,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        'Playing from your library',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                              color: AppColors.textMuted,
                                              fontSize: 10,
                                            ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  Obx(() {
                                    final active = Get.find<
                                            SleepTimerController>()
                                        .isActive
                                        .value;
                                    return IconButton(
                                      tooltip: active
                                          ? 'Sleep Timer Active'
                                          : 'Sleep Timer',
                                      onPressed: () =>
                                          SleepTimerSheet.show(context),
                                      icon: Icon(
                                        Icons.bedtime_outlined,
                                        color: active
                                            ? AppColors.textPrimary
                                            : AppColors.textSecondary,
                                      ),
                                    );
                                  }),
                                  IconButton(
                                    tooltip: 'Equalizer',
                                    onPressed: () =>
                                        showModalBottomSheet<void>(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: AppColors.surface,
                                      builder: (_) =>
                                          const EqualizerView(compact: true),
                                    ),
                                    icon: const Icon(Icons.tune_rounded),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),
                          Center(
                            child: Container(
                              width: artworkSize,
                              height: artworkSize,
                              constraints: const BoxConstraints(
                                maxWidth: 330,
                                maxHeight: 330,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: AppColors.border,
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 28,
                                    offset: const Offset(0, 14),
                                  ),
                                ],
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: SongArtwork(song: song),
                            ),
                          ),
                          const SizedBox(height: 25),
                          Column(
                            children: [
                              Text(
                                song.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontSize: 25,
                                      height: 1.12,
                                      letterSpacing: -0.6,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(height: 7),
                              Text(
                                song.artist,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                              ),
                              if (controller.playbackError.value != null) ...[
                                const SizedBox(height: 10),
                                Text(
                                  controller.playbackError.value!,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall
                                      ?.copyWith(color: AppColors.error),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 20),
                          Column(
                            children: [
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: AppColors.textPrimary,
                                  inactiveTrackColor: AppColors.border,
                                  thumbColor: AppColors.textPrimary,
                                  overlayColor: AppColors.textPrimary
                                      .withValues(alpha: 0.12),
                                  trackHeight: 3,
                                  thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 5,
                                  ),
                                  overlayShape:
                                      const RoundSliderOverlayShape(
                                    overlayRadius: 14,
                                  ),
                                ),
                                child: Slider(
                                  min: 0,
                                  max: sliderMax,
                                  value: sliderValue,
                                  onChanged: totalMs <= 0
                                      ? null
                                      : (value) => controller.seek(
                                            Duration(
                                              milliseconds: value.round(),
                                            ),
                                          ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      controller.formatDuration(
                                        controller.position.value,
                                      ),
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                    ),
                                    Text(
                                      controller.formatDuration(
                                        controller.duration.value,
                                      ),
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 17),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _PlayerActionButton(
                                tooltip: 'Shuffle',
                                icon: Icons.shuffle_rounded,
                                isActive: controller.isShuffleEnabled.value,
                                onPressed: controller.toggleShuffle,
                              ),
                              _PlayerActionButton(
                                tooltip: 'Previous track',
                                icon: Icons.skip_previous_rounded,
                                iconSize: 31,
                                onPressed: controller.skipPrevious,
                              ),
                              Container(
                                width: 66,
                                height: 66,
                                decoration: const BoxDecoration(
                                  color: AppColors.textPrimary,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  tooltip: controller.isPlaying.value
                                      ? 'Pause'
                                      : 'Play',
                                  onPressed: controller.togglePlayPause,
                                  icon: controller.isBuffering.value
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: AppColors.background,
                                          ),
                                        )
                                      : Icon(
                                          controller.isPlaying.value
                                              ? Icons.pause_rounded
                                              : Icons.play_arrow_rounded,
                                          size: 36,
                                          color: AppColors.background,
                                        ),
                                ),
                              ),
                              _PlayerActionButton(
                                tooltip: 'Next track',
                                icon: Icons.skip_next_rounded,
                                iconSize: 31,
                                onPressed: controller.skipNext,
                              ),
                              _PlayerActionButton(
                                tooltip: switch (controller.loopMode.value) {
                                  LoopMode.off => 'Repeat off',
                                  LoopMode.all => 'Repeat all',
                                  LoopMode.one => 'Repeat one',
                                },
                                icon: controller.loopMode.value == LoopMode.one
                                    ? Icons.repeat_one_rounded
                                    : Icons.repeat_rounded,
                                isActive:
                                    controller.loopMode.value != LoopMode.off,
                                onPressed: controller.cycleLoopMode,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }
}

class _PlayerActionButton extends StatelessWidget {
  const _PlayerActionButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.isActive = false,
    this.iconSize = 25,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isActive;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      iconSize: iconSize,
      color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
      constraints: const BoxConstraints.tightFor(width: 44, height: 48),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      icon: Icon(icon),
    );
  }
}
