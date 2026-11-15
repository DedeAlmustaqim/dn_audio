import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../library/widgets/song_artwork.dart';
import '../../library/controllers/library_controller.dart';
import '../../library/views/library_view.dart';
import '../../player/controllers/player_controller.dart';
import '../../player/views/now_playing_view.dart';
import '../../player/views/player_mini_bar.dart';
import '../../player/views/equalizer_view.dart';
import '../../player/views/sleep_timer_sheet.dart';
import '../../player/controllers/sleep_timer_controller.dart';
import '../../playlist/views/playlist_view.dart';
import '../../playlist/controllers/playlist_controller.dart';
import '../../playlist/models/playlist.dart';
import '../../playlist/views/playlist_detail_view.dart';
import '../../../core/routes/app_routes.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final index = controller.selectedTab.value;

      return Scaffold(
        body: SafeArea(
          child: IndexedStack(
            index: index,
            children: [
              _HomeTab(controller: controller),
              const LibraryView(),
              const PlaylistView(),
              const _EqualizerTab(),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          color: AppColors.surface,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const PlayerMiniBar(),
              NavigationBar(
                selectedIndex: index,
                onDestinationSelected: controller.selectTab,
                destinations: [
                  NavigationDestination(
                    icon: Icon(Icons.home_outlined),
                    selectedIcon: Icon(Icons.home_rounded),
                    label: 'nav_home'.tr,
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.library_music_outlined),
                    selectedIcon: Icon(Icons.library_music_rounded),
                    label: 'nav_library'.tr,
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.queue_music_outlined),
                    selectedIcon: Icon(Icons.queue_music_rounded),
                    label: 'nav_playlists'.tr,
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.equalizer_rounded),
                    label: 'nav_equalizer'.tr,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.screenHorizontal, AppSpacing.lg, AppSpacing.screenHorizontal, AppSpacing.xxxl),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const _BrandHeader(),
              const SizedBox(height: AppSpacing.xxxl),
              Text(
                'home_tagline'.tr,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                      letterSpacing: 2.0,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'home_headline'.tr,
                style: AppTypography.editorialTitle.copyWith(fontSize: 30),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'home_description'.tr,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.45,
                    ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              _SearchField(
                textController: controller.searchTextController,
                onSubmitted: controller.submitSearch,
              ),
              const SizedBox(height: AppSpacing.xxxl),
              const _NowPlayingSection(),
              const SizedBox(height: AppSpacing.xxxl),
              _RecentlyAddedSection(onSeeAll: () => controller.openLibrary(section: 'songs')),
              const SizedBox(height: AppSpacing.xxxl),
              _HomePlaylistsSection(onSeeAll: () => controller.selectTab(2)),
              const SizedBox(height: AppSpacing.xxxl),
              _SectionHeader(title: 'your_library'.tr),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _LibraryShortcut(
                      icon: Icons.music_note_rounded,
                      title: 'songs'.tr,
                      subtitle: 'your_collection'.tr,
                      onTap: () => controller.openLibrary(section: 'songs'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _LibraryShortcut(
                      icon: Icons.album_rounded,
                      title: 'albums'.tr,
                      subtitle: 'browse_albums'.tr,
                      onTap: () => controller.openLibrary(section: 'albums'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _LibraryShortcut(
                      icon: Icons.person_rounded,
                      title: 'artists'.tr,
                      subtitle: 'explore_artists'.tr,
                      onTap: () => controller.openLibrary(section: 'artists'),
                    ),
                  ),
                ],
              ),

            ]),
          ),
        ),
      ],
    );
  }
}

class _RecentlyAddedSection extends StatelessWidget {
  const _RecentlyAddedSection({required this.onSeeAll});

  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final library = Get.find<LibraryController>();
    return Obx(() {
      final songs = [...library.songs]
        ..sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
      final recent = songs.take(8).toList(growable: false);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: 'recently_added'.tr,
            actionLabel: 'see_all'.tr,
            onAction: onSeeAll,
          ),
          const SizedBox(height: AppSpacing.md),
          if (library.isLoading.value && recent.isEmpty)
            const SizedBox(
              height: 150,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (recent.isEmpty)
            _HomeSectionEmpty(
              icon: Icons.library_music_outlined,
              message: 'recent_empty'.tr,
            )
          else
            SizedBox(
              height: 174,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: recent.length,
                separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
                itemBuilder: (context, index) {
                  final song = recent[index];
                  return SizedBox(
                    width: 116,
                    child: InkWell(
                      onTap: () => Get.find<PlayerController>().playSong(song, recent),
                      borderRadius: AppRadius.medium,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: AppRadius.small,
                            child: SizedBox(
                              width: 116,
                              height: 116,
                              child: SongArtwork(song: song, iconSize: 30),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            song.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            song.artist,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      );
    });
  }
}

class _HomePlaylistsSection extends StatelessWidget {
  const _HomePlaylistsSection({required this.onSeeAll});

  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final playlists = Get.find<PlaylistController>();
    return Obx(() {
      final items = [...playlists.playlists]
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      final visible = items.take(3).toList(growable: false);

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: 'your_playlists'.tr,
            actionLabel: 'see_all'.tr,
            onAction: onSeeAll,
          ),
          const SizedBox(height: AppSpacing.md),
          if (playlists.isLoading.value && visible.isEmpty)
            const SizedBox(
              height: 76,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (visible.isEmpty)
            _HomeSectionEmpty(
              icon: Icons.queue_music_rounded,
              message: 'playlist_empty_home'.tr,
              actionLabel: 'create_playlist'.tr,
              onAction: onSeeAll,
            )
          else
            ...visible.map(
              (playlist) => _HomePlaylistTile(playlist: playlist),
            ),
        ],
      );
    });
  }
}

class _HomePlaylistTile extends StatelessWidget {
  const _HomePlaylistTile({required this.playlist});

  final Playlist playlist;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: AppColors.surface,
        borderRadius: AppRadius.medium,
        child: InkWell(
          borderRadius: AppRadius.medium,
          onTap: () => Get.to(() => PlaylistDetailView(playlist: playlist)),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: AppRadius.small,
                  ),
                  child: const Icon(
                    Icons.queue_music_rounded,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        playlist.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'song_count'.trParams({'count': '${playlist.songCount}'}),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeSectionEmpty extends StatelessWidget {
  _HomeSectionEmpty({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.medium,
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 22),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ),
          if (actionLabel != null && onAction != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: AppRadius.medium,
          ),
          child: const Icon(
            Icons.graphic_eq_rounded,
            color: AppColors.textPrimary,
            size: 25,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'DN AUDIO',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'DIGITAL NATIVE DEV',
              style: TextStyle(
                fontSize: 9,
                color: AppColors.textSecondary,
                letterSpacing: 1.3,
              ),
            ),
          ],
        ),
        const Spacer(),
        IconButton(
          tooltip: 'settings'.tr,
          onPressed: () => Get.toNamed(AppRoutes.settings),
          icon: const Icon(Icons.settings_outlined, color: AppColors.textSecondary),
        ),
        Obx(() {
          final active = Get.find<SleepTimerController>().isActive.value;
          return IconButton(
            tooltip: active ? 'sleep_timer_active'.tr : 'sleep_timer'.tr,
            onPressed: () => SleepTimerSheet.show(context),
            icon: Icon(
              Icons.bedtime_outlined,
              color: active ? AppColors.primary : AppColors.textSecondary,
            ),
          );
        }),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.textController, required this.onSubmitted});

  final TextEditingController textController;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 17),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.medium,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: textController,
              textInputAction: TextInputAction.search,
              onSubmitted: (value) {
                onSubmitted(value);
                FocusScope.of(context).unfocus();
              },
              decoration: InputDecoration(
                hintText: 'search_music_hint'.tr,
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          IconButton(
            tooltip: 'search'.tr,
            onPressed: () {
              onSubmitted(textController.text);
              FocusScope.of(context).unfocus();
            },
            icon: const Icon(Icons.arrow_forward_rounded),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  _SectionHeader({
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        if (actionLabel != null && onAction != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: const Size(0, 36),
            ),
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}

class _LibraryShortcut extends StatelessWidget {
  const _LibraryShortcut({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 15, 10, 13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppColors.textPrimary, size: 21),
              const SizedBox(height: AppSpacing.md),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 9,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NowPlayingSection extends StatelessWidget {
  const _NowPlayingSection();

  @override
  Widget build(BuildContext context) {
    final player = Get.find<PlayerController>();
    return Obx(() {
      final song = player.currentSong.value;
      if (song == null) return const SizedBox.shrink();
      final durationMs = player.duration.value.inMilliseconds;
      final positionMs = player.position.value.inMilliseconds;
      final progress = durationMs <= 0
          ? 0.0
          : (positionMs / durationMs).clamp(0.0, 1.0).toDouble();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(title: 'continue_listening'.tr),
          const SizedBox(height: 13),
          Material(
            color: AppColors.surface,
            borderRadius: AppRadius.large,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => Get.to(() => const NowPlayingView()),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: AppRadius.small,
                          child: SizedBox(
                            width: 82,
                            height: 82,
                            child: SongArtwork(song: song, iconSize: 30),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                song.title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                song.artist,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 11),
                              Row(
                                children: [
                                  Icon(
                                    Icons.graphic_eq_rounded,
                                    size: 15,
                                    color: AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'NOW PLAYING',
                                    style: Theme.of(context).textTheme.labelSmall
                                        ?.copyWith(
                                          color: AppColors.textSecondary,
                                          letterSpacing: 1.1,
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          tooltip: player.isPlaying.value ? 'pause'.tr : 'play'.tr,
                          onPressed: player.togglePlayPause,
                          icon: Icon(
                            player.isPlaying.value
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 3,
                        backgroundColor: AppColors.border,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          player.formatDuration(player.position.value),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                        Text(
                          player.formatDuration(player.duration.value),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _EqualizerTab extends StatelessWidget {
  const _EqualizerTab();

  @override
  Widget build(BuildContext context) => const EqualizerView(isBottomSheet: false);
}
