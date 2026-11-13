import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../../core/widgets/app_search_field.dart';
import '../../player/controllers/player_controller.dart';
import '../widgets/song_artwork.dart';
import '../widgets/song_list_tile.dart';
import '../../playlist/controllers/playlist_controller.dart';
import '../controllers/library_controller.dart';
import '../models/song.dart';
import '../models/library_collection.dart';
import 'library_collection_detail_view.dart';

class LibraryView extends GetView<LibraryController> {
  const LibraryView({super.key});

  @override
  Widget build(BuildContext context) => Obx(() {
        final section = controller.librarySection.value;
        final visibleSongs = controller.filteredSongs;
        final visibleAlbums = controller.filteredAlbums;
        final visibleArtists = controller.filteredArtists;
        final hasResults = section == 'songs'
            ? visibleSongs.isNotEmpty
            : section == 'albums'
                ? visibleAlbums.isNotEmpty
                : visibleArtists.isNotEmpty;
        final collectionCount = section == 'songs'
            ? controller.songs.length
            : section == 'albums'
                ? controller.albums.length
                : controller.artists.length;
        final sectionLabel = section == 'songs'
            ? 'songs'
            : section == 'albums'
                ? 'albums'
                : 'artists';

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
                      '$collectionCount $sectionLabel on this device',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 20),
                    AppSearchField(
                      onChanged: controller.updateSearch,
                      hintText: section == 'songs'
                          ? 'Search songs, artists, albums...'
                          : section == 'albums'
                              ? 'Search albums or artists...'
                              : 'Search artists...',
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        _LibrarySectionChip(
                          label: 'Songs',
                          selected: section == 'songs',
                          onTap: () => controller.selectLibrarySection('songs'),
                        ),
                        const SizedBox(width: 8),
                        _LibrarySectionChip(
                          label: 'Albums',
                          selected: section == 'albums',
                          onTap: () => controller.selectLibrarySection('albums'),
                        ),
                        const SizedBox(width: 8),
                        _LibrarySectionChip(
                          label: 'Artists',
                          selected: section == 'artists',
                          onTap: () => controller.selectLibrarySection('artists'),
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
                child: AppEmptyState(
                  icon: Icons.error_outline_rounded,
                  title: 'Could not scan music',
                  message: controller.errorMessage.value!,
                  actionLabel: 'Try again',
                  onAction: controller.refreshLibrary,
                ),
              )
            else if (!controller.hasPermission.value)
              SliverFillRemaining(
                hasScrollBody: false,
                child: AppEmptyState(
                  icon: Icons.folder_off_outlined,
                  title: 'Music access is needed',
                  message:
                      'Allow DN Audio to access audio files so it can build your offline library.',
                  actionLabel: 'Allow access',
                  onAction: controller.refreshLibrary,
                ),
              )
            else if (controller.songs.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: AppEmptyState(
                  icon: Icons.music_off_rounded,
                  title: 'No music found',
                  message:
                      'Audio files stored on your device will appear here after scanning.',
                ),
              )
            else if (!hasResults)
              SliverFillRemaining(
                hasScrollBody: false,
                child: AppEmptyState(
                  icon: Icons.search_off_rounded,
                  title: controller.searchQuery.value.isNotEmpty
                      ? 'No matching $sectionLabel'
                      : 'No $sectionLabel yet',
                  message: controller.searchQuery.value.isNotEmpty
                      ? 'Try another search term.'
                      : section == 'albums'
                          ? 'Albums from your local music will appear here.'
                          : section == 'artists'
                              ? 'Artists from your local music will appear here.'
                              : 'Your songs will appear here.',
                ),
              )
            else if (section == 'songs')
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverList.separated(
                  itemCount: visibleSongs.length,
                  separatorBuilder: (_, _) =>
                      const Divider(height: 1, indent: 68),
                  itemBuilder: (context, index) => SongListTile(
                    song: visibleSongs[index],
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          visibleSongs[index].durationLabel,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          tooltip: 'Add to playlist',
                          onPressed: () => _showAddToPlaylistSheet(
                            context,
                            visibleSongs[index],
                          ),
                          icon: const Icon(Icons.playlist_add_rounded),
                        ),
                      ],
                    ),
                    onTap: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      Get.find<PlayerController>().playSong(
                        visibleSongs[index],
                        controller.songs.toList(),
                      );
                    },
                  ),
                ),
              )
            else if (section == 'albums')
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 18,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.76,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _AlbumCard(album: visibleAlbums[index]),
                    childCount: visibleAlbums.length,
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverList.separated(
                  itemCount: visibleArtists.length,
                  separatorBuilder: (_, _) =>
                      const Divider(height: 1, indent: 78),
                  itemBuilder: (context, index) =>
                      _ArtistTile(artist: visibleArtists[index]),
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

class _LibrarySectionChip extends StatelessWidget {
  const _LibrarySectionChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: selected ? AppColors.primary.withValues(alpha: 0.16) : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.primary : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      );
}

class _AlbumCard extends StatelessWidget {
  const _AlbumCard({required this.album});

  final AlbumCollection album;

  @override
  Widget build(BuildContext context) => Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
            Get.to(() => AlbumDetailView(album: album));
          },
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: double.infinity,
                      child: SongArtwork(song: album.artworkSong, iconSize: 42),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(album.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(album.artist, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 3),
                Text('${album.songCount} songs', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
        ),
      );
}

class _ArtistTile extends StatelessWidget {
  const _ArtistTile({required this.artist});

  final ArtistCollection artist;

  @override
  Widget build(BuildContext context) => ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
        leading: ClipOval(
          child: SizedBox(
            width: 54,
            height: 54,
            child: SongArtwork(song: artist.artworkSong, iconSize: 24),
          ),
        ),
        title: Text(
          artist.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        subtitle: Text(
          '${artist.albumCount} albums · ${artist.songCount} songs',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
          Get.to(() => ArtistDetailView(artist: artist));
        },
      );
}

