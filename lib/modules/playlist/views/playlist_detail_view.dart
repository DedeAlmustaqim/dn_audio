import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_loading_state.dart';
import '../../../core/widgets/app_empty_state.dart';
import '../../player/controllers/player_controller.dart';
import '../../player/views/player_mini_bar.dart';
import '../../library/widgets/song_list_tile.dart';
import '../controllers/playlist_controller.dart';
import '../models/playlist.dart';
import '../models/playlist_song.dart';

class PlaylistDetailView extends StatefulWidget {
  const PlaylistDetailView({super.key, required this.playlist});

  final Playlist playlist;

  @override
  State<PlaylistDetailView> createState() => _PlaylistDetailViewState();
}

class _PlaylistDetailViewState extends State<PlaylistDetailView> {
  late final PlaylistController _controller;
  late final PlayerController _playerController;
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<PlaylistController>();
    _playerController = Get.find<PlayerController>();
    _loadSongs();
  }

  Future<void> _loadSongs() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _loadError = null;
      });
    }

    try {
      await _controller.loadPlaylistSongs(widget.playlist.id);
      if (mounted) setState(() => _isLoading = false);
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadError = 'Unable to load songs. Please try again.';
        });
      }
    }
  }

  Future<void> _confirmRemove(PlaylistSong playlistSong) async {
    final song = playlistSong.song;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remove song?'),
        content: Text('Remove “${song.title}” from this playlist?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await _controller.removeSongFromPlaylist(
      widget.playlist.id,
      song.contentUri,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: const SafeArea(
        top: false,
        child: PlayerMiniBar(),
      ),
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Playlist'),
        actions: [
          IconButton(
            tooltip: 'Refresh playlist',
            onPressed: _isLoading ? null : _loadSongs,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Obx(() {
        final songs =
            _controller.playlistSongs[widget.playlist.id] ?? const [];
        return CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.screenHorizontal, AppSpacing.md, AppSpacing.screenHorizontal, AppSpacing.lg),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 84,
                      height: 84,
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: AppRadius.large,
                      ),
                      child: const Icon(
                        Icons.queue_music_rounded,
                        color: AppColors.textPrimary,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      'YOUR PLAYLIST',
                      style: AppTypography.eyebrow.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      widget.playlist.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.6,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '${songs.length} songs',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: songs.isEmpty
                            ? null
                            : () => _playerController.playPlaylist(
                                  songs.map((item) => item.song).toList(),
                                ),
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Play all'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(52),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const Divider(color: AppColors.border),
                  ],
                ),
              ),
            ),
            if (_isLoading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: AppLoadingState(),
              )
            else if (_loadError != null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: AppEmptyState(
                  icon: Icons.error_outline_rounded,
                  title: 'Could not load playlist',
                  message: _loadError!,
                  actionLabel: 'Try again',
                  onAction: _loadSongs,
                ),
              )
            else if (songs.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: AppEmptyState(
                  icon: Icons.music_off_rounded,
                  title: 'This playlist is empty',
                  message:
                      'Add songs from Your Library to build this playlist.',
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xxxl),
                sliver: SliverList.separated(
                  itemCount: songs.length,
                  separatorBuilder: (_, _) =>
                      const Divider(height: 1, indent: 66),
                  itemBuilder: (context, index) {
                    final item = songs[index];
                    return SongListTile(
                      song: item.song,
                      artworkSize: 46,
                      onTap: () => _playerController.playPlaylist(
                        songs.map((entry) => entry.song).toList(),
                        initialIndex: index,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.song.durationLabel,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                              fontFeatures: const [FontFeature.tabularFigures()],
                            ),
                          ),
                          PopupMenuButton<String>(
                            tooltip: 'Song options',
                            onSelected: (value) {
                              if (value == 'remove') _confirmRemove(item);
                            },
                            itemBuilder: (_) => const [
                              PopupMenuItem(
                                value: 'remove',
                                child: Text('Remove from playlist'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            if (_controller.errorMessage.value != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(22, 0, 22, 20),
                  child: Text(
                    _controller.errorMessage.value!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}

