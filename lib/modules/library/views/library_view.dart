import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../player/controllers/player_controller.dart';
import '../widgets/song_artwork.dart';
import '../../playlist/controllers/playlist_controller.dart';
import '../controllers/library_controller.dart';
import '../models/song.dart';

class LibraryView extends GetView<LibraryController> {
  const LibraryView({super.key});

  @override
  Widget build(BuildContext context) => Obx(() {
        final visibleSongs = controller.filteredSongs;
        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 12),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Library',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.7,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${controller.songs.length} songs on this device',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _SearchField(onChanged: controller.updateSearch),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        const Text(
                          'All songs',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          tooltip: 'Scan music again',
                          onPressed: controller.isLoading.value
                              ? null
                              : controller.refreshLibrary,
                          icon: const Icon(Icons.refresh_rounded),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (controller.isLoading.value)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              )
            else if (controller.errorMessage.value != null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _InfoState(
                  icon: Icons.error_outline_rounded,
                  title: 'Could not scan music',
                  message: controller.errorMessage.value!,
                  actionLabel: 'Try again',
                  onPressed: controller.refreshLibrary,
                ),
              )
            else if (!controller.hasPermission.value)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _InfoState(
                  icon: Icons.folder_off_outlined,
                  title: 'Music access is needed',
                  message:
                      'Allow DN Audio to access audio files so it can build your offline library.',
                  actionLabel: 'Allow access',
                  onPressed: controller.refreshLibrary,
                ),
              )
            else if (controller.songs.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: _InfoState(
                  icon: Icons.music_off_rounded,
                  title: 'No music found',
                  message:
                      'Audio files stored on your device will appear here after scanning.',
                ),
              )
            else if (visibleSongs.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: _InfoState(
                  icon: Icons.search_off_rounded,
                  title: 'No matching songs',
                  message: 'Try another song, artist, or album name.',
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverList.separated(
                  itemCount: visibleSongs.length,
                  separatorBuilder: (_, _) =>
                      const Divider(height: 1, indent: 68),
                  itemBuilder: (context, index) => _SongTile(
                    song: visibleSongs[index],
                    onAddToPlaylist: () =>
                        _showAddToPlaylistSheet(context, visibleSongs[index]),
                  ),
                ),
              ),
          ],
        );
      });

  Future<void> _showAddToPlaylistSheet(
    BuildContext context,
    Song song,
  ) async {
    final playlistController = Get.find<PlaylistController>();
    playlistController.errorMessage.value = null;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Obx(() {
          final playlists = playlistController.playlists;
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Add to playlist',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 5),
                Text(
                  song.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 14),
                if (playlists.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(
                      child: Text(
                        'Create a playlist first to organize this song.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: playlists.length,
                      separatorBuilder: (_, _) =>
                          const Divider(height: 1, indent: 56),
                      itemBuilder: (context, index) {
                        final playlist = playlists[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(
                            Icons.queue_music_rounded,
                            color: AppColors.primary,
                          ),
                          title: Text(playlist.name),
                          subtitle: Text('${playlist.songCount} songs'),
                          trailing: const Icon(Icons.add_rounded),
                          onTap: playlistController.isSaving.value
                              ? null
                              : () async {
                                  final added = await playlistController
                                      .addSongToPlaylist(playlist.id, song);
                                  if (added && sheetContext.mounted) {
                                    Navigator.of(sheetContext).pop();
                                  }
                                },
                        );
                      },
                    ),
                  ),
                Obx(() {
                  final error = playlistController.errorMessage.value;
                  if (error == null) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      error,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => TextField(
        onChanged: onChanged,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search songs, artists, albums...',
          prefixIcon: const Icon(Icons.search_rounded),
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.primary),
          ),
        ),
      );
}

class _SongTile extends StatelessWidget {
  const _SongTile({
    required this.song,
    required this.onAddToPlaylist,
  });

  final Song song;
  final VoidCallback onAddToPlaylist;

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 48,
            height: 48,
            child: SongArtwork(song: song, iconSize: 22),
          ),
        ),
        title: Text(
          song.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Text(
          song.artist,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              song.durationLabel,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              tooltip: 'Add to playlist',
              onPressed: onAddToPlaylist,
              icon: const Icon(Icons.playlist_add_rounded),
            ),
          ],
        ),
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
          Get.find<PlayerController>().playSong(
            song,
            Get.find<LibraryController>().songs.toList(),
          );
        },
      );
}

class _InfoState extends StatelessWidget {
  const _InfoState({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onPressed,
  });

  final IconData icon;
  final String title, message;
  final String? actionLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: AppColors.primary),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              if (actionLabel != null) ...[
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: onPressed,
                  child: Text(actionLabel!),
                ),
              ],
            ],
          ),
        ),
      );
}
