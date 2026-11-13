import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
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
              return const Center(
                child: Text(
                  'Nothing playing',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              );
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
                  340.0,
                  math.min(
                    math.max(160.0, constraints.maxHeight * 0.40),
                    constraints.maxWidth - (AppSpacing.screenHorizontal * 2),
                  ),
                );

                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.screenHorizontal,
                        AppSpacing.sm,
                        AppSpacing.screenHorizontal,
                        AppSpacing.xxl,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildHeader(context),
                          const SizedBox(height: AppSpacing.xxl),
                          _buildArtwork(song, artworkSize),
                          const SizedBox(height: AppSpacing.xxxl),
                          _buildTrackInformation(context, song),
                          const SizedBox(height: AppSpacing.xxl),
                          _buildProgress(context, totalMs, sliderMax, sliderValue),
                          const SizedBox(height: AppSpacing.lg),
                          _buildTransportControls(),
                          const SizedBox(height: AppSpacing.sm),
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

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 38,
          height: 4,
          decoration: BoxDecoration(
            color: AppColors.border,
            borderRadius: AppRadius.pillShape,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            _HeaderIconButton(
              tooltip: 'Close player',
              icon: Icons.keyboard_arrow_down_rounded,
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            const Spacer(),
            Column(
              children: [
                Text(
                  'NOW PLAYING',
                  style: AppTypography.eyebrow.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 1.8,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  'YOUR MUSIC, YOUR MOMENT',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 9,
                        letterSpacing: 0.8,
                      ),
                ),
              ],
            ),
            const Spacer(),
            Obx(() {
              final active = Get.find<SleepTimerController>().isActive.value;
              return _HeaderIconButton(
                tooltip: active ? 'Sleep Timer Active' : 'Sleep Timer',
                icon: Icons.bedtime_outlined,
                isActive: active,
                onPressed: () => SleepTimerSheet.show(context),
              );
            }),
            _HeaderIconButton(
              tooltip: 'Equalizer',
              icon: Icons.tune_rounded,
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                backgroundColor: AppColors.surface,
                builder: (_) => const EqualizerView(compact: true),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildArtwork(dynamic song, double artworkSize) {
    return Center(
      child: Container(
        width: artworkSize,
        height: artworkSize,
        constraints: const BoxConstraints(maxWidth: 340, maxHeight: 340),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.artworkShape,
          border: Border.all(color: AppColors.borderSubtle),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.38),
              blurRadius: 36,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: SongArtwork(song: song),
      ),
    );
  }

  Widget _buildTrackInformation(BuildContext context, dynamic song) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          song.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: AppTypography.editorialTitle.copyWith(
            color: AppColors.textPrimary,
            fontSize: 28,
            height: 1.12,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          song.artist,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 0.15,
              ),
        ),
        if (controller.playbackError.value != null) ...[
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.10),
              borderRadius: AppRadius.small,
              border: Border.all(
                color: AppColors.error.withValues(alpha: 0.28),
              ),
            ),
            child: Text(
              controller.playbackError.value!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.error,
                  ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildProgress(
    BuildContext context,
    int totalMs,
    double sliderMax,
    double sliderValue,
  ) {
    return Column(
      children: [
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.textPrimary,
            inactiveTrackColor: AppColors.border,
            thumbColor: AppColors.textPrimary,
            overlayColor: AppColors.textPrimary.withValues(alpha: 0.12),
            trackHeight: 3,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
          ),
          child: Slider(
            min: 0,
            max: sliderMax,
            value: sliderValue,
            onChanged: totalMs <= 0
                ? null
                : (value) => controller.seek(
                      Duration(milliseconds: value.round()),
                    ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                controller.formatDuration(controller.position.value),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
              ),
              Text(
                controller.formatDuration(controller.duration.value),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTransportControls() {
    return Row(
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
          width: 70,
          height: 70,
          decoration: const BoxDecoration(
            color: AppColors.textPrimary,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            tooltip: controller.isPlaying.value ? 'Pause' : 'Play',
            onPressed: controller.togglePlayPause,
            icon: controller.isBuffering.value
                ? const SizedBox(
                    width: 25,
                    height: 25,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.background,
                    ),
                  )
                : Icon(
                    controller.isPlaying.value
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    size: 38,
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
          isActive: controller.loopMode.value != LoopMode.off,
          onPressed: controller.cycleLoopMode,
        ),
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.isActive = false,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
      constraints: const BoxConstraints.tightFor(width: 44, height: 48),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
      icon: Icon(icon),
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
