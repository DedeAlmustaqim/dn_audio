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
                  children: [
                    Expanded(
                      child: _LabeledPlayerControl(
                        tooltip: 'Acak',
                        label: 'Acak',
                        icon: Icons.shuffle_rounded,
                        isActive: controller.isShuffleEnabled.value,
                        onPressed: () async {
                          await controller.toggleShuffle();
                          Get.rawSnackbar(
                            message: controller.isShuffleEnabled.value
                                ? 'Acak diaktifkan'
                                : 'Acak dinonaktifkan',
                            duration: const Duration(milliseconds: 1500),
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: AppColors.surfaceElevated,
                            colorText: AppColors.textPrimary,
                            borderRadius: 14,
                            margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: _LabeledPlayerControl(
                        tooltip: 'Lagu sebelumnya',
                        label: 'Sebelum',
                        icon: Icons.skip_previous_rounded,
                        iconSize: 30,
                        onPressed: controller.skipPrevious,
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              tooltip: controller.isPlaying.value ? 'Jeda' : 'Putar',
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
                                      size: 34,
                                      color: AppColors.background,
                                    ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            controller.isPlaying.value ? 'Jeda' : 'Putar',
                            maxLines: 1,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: _LabeledPlayerControl(
                        tooltip: 'Lagu berikutnya',
                        label: 'Berikutnya',
                        icon: Icons.skip_next_rounded,
                        iconSize: 30,
                        onPressed: controller.skipNext,
                      ),
                    ),
                    Expanded(
                      child: _LabeledPlayerControl(
                        tooltip: 'Mode pengulangan',
                        label: switch (controller.loopMode.value) {
                          LoopMode.off => 'Ulangi',
                          LoopMode.all => 'Semua',
                          LoopMode.one => 'Satu lagu',
                        },
                        icon: controller.loopMode.value == LoopMode.one
                            ? Icons.repeat_one_rounded
                            : Icons.repeat_rounded,
                        isActive: controller.loopMode.value != LoopMode.off,
                        onPressed: () async {
                          await controller.cycleLoopMode();
                          final message = switch (controller.loopMode.value) {
                            LoopMode.off => 'Pengulangan dimatikan',
                            LoopMode.all => 'Ulangi semua lagu',
                            LoopMode.one => 'Ulangi satu lagu',
                          };
                          Get.rawSnackbar(
                            message: message,
                            duration: const Duration(milliseconds: 1500),
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: AppColors.surfaceElevated,
                            colorText: AppColors.textPrimary,
                            borderRadius: 14,
                            margin: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                          );
                        },
                      ),
                    ),
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


class _LabeledPlayerControl extends StatelessWidget {
  const _LabeledPlayerControl({
    required this.tooltip,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isActive = false,
    this.iconSize = 24,
  });

  final String tooltip;
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isActive;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.primary : AppColors.textSecondary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: tooltip,
          onPressed: onPressed,
          icon: Icon(icon, size: iconSize, color: color),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            color: color,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
