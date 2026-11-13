import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
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
        color: AppColors.surface,
        child: InkWell(
          onTap: () => showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            showDragHandle: true,
            backgroundColor: AppColors.background,
            builder: (_) => const NowPlayingView(),
          ),
          child: Container(
            height: 76,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.border),
              ),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: 44,
                    height: 44,
                    child: SongArtwork(song: song, iconSize: 22),
                  ),
                ),
                const SizedBox(width: 12),
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
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            song.artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                _MiniPlayerControl(
                  tooltip: 'Previous',
                  onPressed: controller.skipPrevious,
                  icon: Icons.skip_previous_rounded,
                ),
                Obx(
                  () => _MiniPlayerControl(
                    tooltip: controller.isPlaying.value ? 'Pause' : 'Play',
                    onPressed: controller.togglePlayPause,
                    icon: controller.isPlaying.value
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    emphasized: true,
                  ),
                ),
                _MiniPlayerControl(
                  tooltip: 'Next',
                  onPressed: controller.skipNext,
                  icon: Icons.skip_next_rounded,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _MiniPlayerControl extends StatelessWidget {
  const _MiniPlayerControl({
    required this.tooltip,
    required this.onPressed,
    required this.icon,
    this.emphasized = false,
  });

  final String tooltip;
  final VoidCallback onPressed;
  final IconData icon;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints.tightFor(width: 44, height: 48),
      padding: EdgeInsets.zero,
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        child: Icon(
          icon,
          key: ValueKey(icon),
          size: emphasized ? 28 : 23,
          color: emphasized ? AppColors.textPrimary : AppColors.textSecondary,
        ),
      ),
    );
  }
}
