import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../library/widgets/song_artwork.dart';
import '../../library/views/library_view.dart';
import '../../player/controllers/player_controller.dart';
import '../../player/views/now_playing_view.dart';
import '../../player/views/player_mini_bar.dart';
import '../../player/views/equalizer_view.dart';
import '../../player/views/sleep_timer_sheet.dart';
import '../../player/controllers/sleep_timer_controller.dart';
import '../../playlist/views/playlist_view.dart';
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
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const PlayerMiniBar(),
            NavigationBar(
              selectedIndex: index,
              onDestinationSelected: controller.selectTab,
              destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.library_music_outlined),
              selectedIcon: Icon(Icons.library_music_rounded),
              label: 'Library',
            ),
            NavigationDestination(
              icon: Icon(Icons.queue_music_outlined),
              selectedIcon: Icon(Icons.queue_music_rounded),
              label: 'Playlists',
            ),
            NavigationDestination(
              icon: Icon(Icons.equalizer_rounded),
              label: 'Equalizer',
            ),
              ],
            ),
          ],
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
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              const _BrandHeader(),
              const SizedBox(height: 28),
              Text(
                'YOUR MUSIC. YOUR EXPERIENCE.',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                      letterSpacing: 2.0,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 9),
              Text(
                'Music, made personal.',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 30,
                      height: 1.08,
                      letterSpacing: -1.1,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your offline collection, ready whenever you are.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.45,
                    ),
              ),
              const SizedBox(height: 24),
              _SearchField(
                textController: controller.searchTextController,
                onSubmitted: controller.submitSearch,
              ),
              const SizedBox(height: 30),
              const _NowPlayingSection(),
              const SizedBox(height: 30),
              const _SectionHeader(title: 'Your Library'),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _LibraryShortcut(
                      icon: Icons.music_note_rounded,
                      title: 'Songs',
                      subtitle: 'Your collection',
                      onTap: () => controller.openLibrary(section: 'songs'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _LibraryShortcut(
                      icon: Icons.album_rounded,
                      title: 'Albums',
                      subtitle: 'Browse albums',
                      onTap: () => controller.openLibrary(section: 'albums'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _LibraryShortcut(
                      icon: Icons.person_rounded,
                      title: 'Artists',
                      subtitle: 'Explore artists',
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
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.graphic_eq_rounded,
            color: AppColors.textPrimary,
            size: 25,
          ),
        ),
        const SizedBox(width: 12),
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
          tooltip: 'Settings',
          onPressed: () => Get.toNamed(AppRoutes.settings),
          icon: const Icon(Icons.settings_outlined, color: AppColors.textSecondary),
        ),
        Obx(() {
          final active = Get.find<SleepTimerController>().isActive.value;
          return IconButton(
            tooltip: active ? 'Sleep Timer Active' : 'Sleep Timer',
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
        borderRadius: BorderRadius.circular(17),
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
              decoration: const InputDecoration(
                hintText: 'Search songs, artists, albums...',
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Search',
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
  const _SectionHeader({required this.title});

  final String title;

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
              const SizedBox(height: 14),
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
          : (positionMs / durationMs).clamp(0.0, 1.0);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(title: 'Continue Listening'),
          const SizedBox(height: 13),
          Material(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => Get.to(() => const NowPlayingView()),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
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
                          tooltip: player.isPlaying.value ? 'Pause' : 'Play',
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
