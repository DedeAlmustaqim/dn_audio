import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../../library/views/library_view.dart';
import '../../player/views/player_mini_bar.dart';
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
              _HomeTab(),
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
  const _HomeTab();

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
              const _SearchField(),
              const SizedBox(height: 30),
              const _SectionHeader(title: 'Recently Played'),
              const SizedBox(height: 14),
              const _EmptyRecentlyPlayed(),
              const SizedBox(height: 30),
              const _SectionHeader(title: 'Your Library'),
              const SizedBox(height: 14),
              const _LibraryShortcut(
                icon: Icons.music_note_rounded,
                title: 'Songs',
                subtitle: 'Your music collection',
              ),
              const _LibraryShortcut(
                icon: Icons.album_rounded,
                title: 'Albums',
                subtitle: 'Browse your albums',
              ),
              const _LibraryShortcut(
                icon: Icons.person_rounded,
                title: 'Artists',
                subtitle: 'Explore your artists',
              ),
              const _LibraryShortcut(
                icon: Icons.folder_rounded,
                title: 'Folders',
                subtitle: 'Browse device folders',
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
        IconButton(
          tooltip: 'Settings',
          onPressed: () {},
          icon: const Icon(
            Icons.settings_outlined,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField();

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
      child: const Row(
        children: [
          Icon(Icons.search_rounded, color: AppColors.textSecondary),
          SizedBox(width: 12),
          Text(
            'Search songs, artists, albums...',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
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
        const Text(
          'See all',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _EmptyRecentlyPlayed extends StatelessWidget {
  const _EmptyRecentlyPlayed();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 27, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.music_note_rounded,
            size: 34,
            color: AppColors.textSecondary,
          ),
          SizedBox(height: 10),
          Text(
            'Nothing playing yet',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 5),
          Text(
            'Your listening history will appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _LibraryShortcut extends StatelessWidget {
  const _LibraryShortcut({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 23),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
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
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }
}

class _PlaylistsTab extends StatelessWidget {
  const _PlaylistsTab();

  @override
  Widget build(BuildContext context) => const _PlaceholderTab(
        icon: Icons.queue_music_rounded,
        title: 'Playlists',
        description: 'Create and organize your playlists.',
      );
}

class _EqualizerTab extends StatelessWidget {
  const _EqualizerTab();

  @override
  Widget build(BuildContext context) => const _PlaceholderTab(
        icon: Icons.equalizer_rounded,
        title: 'Equalizer',
        description: 'Shape your sound with audio controls.',
      );
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
