import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../player/controllers/player_controller.dart';
import '../../player/views/player_mini_bar.dart';
import '../models/library_collection.dart';
import '../models/song.dart';
import '../widgets/song_artwork.dart';

class AlbumDetailView extends StatelessWidget {
  const AlbumDetailView({super.key, required this.album});

  final AlbumCollection album;

  @override
  Widget build(BuildContext context) {
    final player = Get.find<PlayerController>();
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: const SafeArea(top: false, child: PlayerMiniBar()),
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Album'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.screenHorizontal, AppSpacing.md, AppSpacing.screenHorizontal, AppSpacing.xl),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: ClipRRect(
                      borderRadius: AppRadius.artworkShape,
                      child: SizedBox(
                        width: 220,
                        height: 220,
                        child: SongArtwork(song: album.artworkSong, iconSize: 54),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  Text(
                    album.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.editorialTitle,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(album.artist, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                  const SizedBox(height: AppSpacing.xs),
                  Text('${album.songCount} songs', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  const SizedBox(height: AppSpacing.xl),
                  _PlayAllButton(onPressed: () => player.playPlaylist(album.songs)),
                  const SizedBox(height: AppSpacing.lg),
                  const Divider(color: AppColors.border),
                ],
              ),
            ),
          ),
          _SongListSliver(songs: album.songs),
        ],
      ),
    );
  }
}

class ArtistDetailView extends StatelessWidget {
  const ArtistDetailView({super.key, required this.artist});

  final ArtistCollection artist;

  List<AlbumCollection> get _albums {
    final grouped = <String, List<Song>>{};
    for (final song in artist.songs) {
      grouped.putIfAbsent(albumCollectionKey(song), () => []).add(song);
    }
    final albums = grouped.entries.map((entry) {
      final songs = List<Song>.unmodifiable(entry.value);
      return AlbumCollection(
        id: entry.key,
        title: songs.first.album,
        artist: artist.name,
        songs: songs,
      );
    }).toList()
      ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    return List<AlbumCollection>.unmodifiable(albums);
  }

  @override
  Widget build(BuildContext context) {
    final player = Get.find<PlayerController>();
    final albums = _albums;
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: const SafeArea(top: false, child: PlayerMiniBar()),
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Artist'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 18),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: ClipOval(
                      child: SizedBox(
                        width: 176,
                        height: 176,
                        child: SongArtwork(song: artist.artworkSong, iconSize: 48),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    artist.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 27,
                      height: 1.12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.7,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    '${artist.albumCount} albums · ${artist.songCount} songs',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  _PlayAllButton(onPressed: () => player.playPlaylist(artist.songs)),
                  const SizedBox(height: 24),
                  const Text('Albums', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 14),
                ],
              ),
            ),
          ),
          if (albums.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: _DetailEmptyState(title: 'No albums found', message: 'Albums by this artist will appear here.'),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 18,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.78,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _ArtistAlbumCard(album: albums[index]),
                  childCount: albums.length,
                ),
              ),
            ),
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(22, 28, 22, 12),
            sliver: SliverToBoxAdapter(
              child: Text('All songs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ),
          ),
          _SongListSliver(songs: artist.songs),
        ],
      ),
    );
  }
}

class _ArtistAlbumCard extends StatelessWidget {
  const _ArtistAlbumCard({required this.album});
  final AlbumCollection album;

  @override
  Widget build(BuildContext context) => Material(
        color: AppColors.surface,
        borderRadius: AppRadius.medium,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            FocusManager.instance.primaryFocus?.unfocus();
            Get.to(() => AlbumDetailView(album: album));
          },
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: AppRadius.small,
                    child: SizedBox(
                      width: double.infinity,
                      child: SongArtwork(song: album.artworkSong, iconSize: 34),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(album.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text('${album.songCount} songs', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
              ],
            ),
          ),
        ),
      );
}

class _PlayAllButton extends StatelessWidget {
  const _PlayAllButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: onPressed,
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text('Play all'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.controlActive,
            foregroundColor: AppColors.onControlActive,
            disabledBackgroundColor: AppColors.surfaceElevated,
            disabledForegroundColor: AppColors.textMuted,
            minimumSize: const Size.fromHeight(52),
            shape: const StadiumBorder(),
            textStyle: Theme.of(context).textTheme.labelLarge
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      );
}

class _SongListSliver extends StatelessWidget {
  const _SongListSliver({required this.songs});
  final List<Song> songs;

  @override
  Widget build(BuildContext context) {
    final player = Get.find<PlayerController>();
    if (songs.isEmpty) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: _DetailEmptyState(title: 'No songs found', message: 'Songs in this collection will appear here.'),
      );
    }
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xxxl),
      sliver: SliverList.separated(
        itemCount: songs.length,
        separatorBuilder: (_, _) => const Divider(height: 1, indent: 66),
        itemBuilder: (context, index) {
          final song = songs[index];
          return ListTile(
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
              player.playPlaylist(songs, initialIndex: index);
            },
            contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            leading: ClipRRect(
              borderRadius: AppRadius.small,
              child: SizedBox(width: 46, height: 46, child: SongArtwork(song: song, iconSize: 21)),
            ),
            title: Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            subtitle: Text(song.artist, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            trailing: Text(song.durationLabel, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          );
        },
      ),
    );
  }
}

class _DetailEmptyState extends StatelessWidget {
  const _DetailEmptyState({required this.title, required this.message});
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.music_off_rounded, size: 48, color: AppColors.textSecondary),
              const SizedBox(height: 14),
              Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              const SizedBox(height: 7),
              Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
            ],
          ),
        ),
      );
}
