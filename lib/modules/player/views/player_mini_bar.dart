import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../library/widgets/song_artwork.dart';
import '../controllers/player_controller.dart';
import 'now_playing_view.dart';

class PlayerMiniBar extends GetView<PlayerController> {
  const PlayerMiniBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final song = controller.currentSong.value;
      if (song == null) return const SizedBox.shrink();

      return Material(
        color: const Color(0xFFF4F3F0),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            showDragHandle: true,
            backgroundColor: AppColors.background,
            builder: (_) => const NowPlayingView(),
          ),
          child: SizedBox(
            height: 68,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: AppRadius.small,
                    child: SizedBox(
                      width: 42,
                      height: 42,
                      child: SongArtwork(song: song, iconSize: 21),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Semantics(
                      label: 'Now playing: ${song.title}, ${song.artist}',
                      child: ExcludeSemantics(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              song.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    color: const Color(0xFF171820),
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: AppSpacing.xxs),
                            Text(
                              song.artist,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: const Color(0xFF777982),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Obx(() {
                    final playing = controller.isPlaying.value;
                    return IconButton(
                      tooltip: playing ? 'Pause' : 'Play',
                      onPressed: controller.togglePlayPause,
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFF171820),
                        foregroundColor: const Color(0xFFF7F7F5),
                        minimumSize: const Size(44, 44),
                        maximumSize: const Size(44, 44),
                        shape: const CircleBorder(),
                        padding: EdgeInsets.zero,
                      ),
                      icon: AnimatedSwitcher(
                        duration: AppMotion.fast,
                        switchInCurve: AppMotion.enterCurve,
                        switchOutCurve: AppMotion.exitCurve,
                        child: Icon(
                          playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          key: ValueKey(playing),
                          size: 24,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
