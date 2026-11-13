import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../library/controllers/library_controller.dart';
import '../../library/views/library_view.dart';
import '../../player/controllers/player_controller.dart';
import '../../player/views/now_playing_view.dart';
import '../../player/views/player_mini_bar.dart';
import '../../player/views/equalizer_view.dart';
import '../../player/views/sleep_timer_sheet.dart';
import '../../player/controllers/sleep_timer_controller.dart';
import '../../playlist/views/playlist_view.dart';
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
            children: const [
              _HomeTab(controller: controller),
              LibraryView(),
              PlaylistView(),
              _EqualizerTab(),
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
              const SizedBox(height: 34),
              const Text(
                'Your Music.',
                style: TextStyle(
                  fontSize: 32,
                  height: 1.12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
              ),
              const Text(
                'Your Experience.',
                style: TextStyle(
                  fontSize: 32,
                  height: 1.12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'All your music, in one place.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 26),
              _SearchField(\n                textController: controller.searchTextController,\n                onSubmitted: controller.submitSearch,\n              ),
              const SizedBox(height: 30),
              const _NowPlayingSection(),
              const SizedBox(height: 30),
              const _SectionHeader(title: 'Your Library'),
              const SizedBox(height: 14),
              _LibraryShortcut(
                icon: Icons.music_note_rounded,
                title: 'Songs',
                subtitle: 'Your music collection',
                onTap: () => controller.openLibrary(section: 'songs'),
              ),
              _LibraryShortcut(
                icon: Icons.album_rounded,
                title: 'Albums',
                subtitle: 'Browse your albums',
                onTap: () => controller.openLibrary(section: 'albums'),
              ),
              _LibraryShortcut(
                icon: Icons.person_rounded,
                title: 'Artists',
                subtitle: 'Explore your artists',
                onTap: () => controller.openLibrary(section: 'artists'),
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
            color: AppColors.primary.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(
            Icons.graphic_eq_rounded,
            color: AppColors.primary,
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

  final TextEditingController textController;\n  final ValueChanged<String> onSubmitted;

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
              onSubmitted: onSubmitted,
              decoration: const InputDecoration(
                hintText: 'Search songs, artists, albums...',
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Search',
            onPressed: () => onSubmitted(textController.text),
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
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 23),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11,
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

class _NowPlayingSection extends StatelessWidget {
  const _NowPlayingSection();

  @override
  Widget build(BuildContext context) {
    final player = Get.find<PlayerController>();
    return Obx(() {
      final song = player.currentSong.value;
      if (song == null) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(title: 'Now Playing'),
          const SizedBox(height: 14),
          Material(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(18),
            child: ListTile(
              leading: const Icon(Icons.graphic_eq_rounded, color: AppColors.primary),
              title: Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text(song.artist, maxLines: 1, overflow: TextOverflow.ellipsis),
              trailing: const Icon(Icons.open_in_full_rounded),
              onTap: () => Get.to(() => const NowPlayingView()),
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

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Center(
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
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
