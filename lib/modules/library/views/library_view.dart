import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../controllers/library_controller.dart';
import '../models/song.dart';
import '../../player/controllers/player_controller.dart';

class LibraryView extends GetView<LibraryController> {
  const LibraryView({super.key});

  @override
  Widget build(BuildContext context) => Obx(() {
    final visibleSongs = controller.filteredSongs;
    return CustomScrollView(slivers: [
      SliverPadding(padding: const EdgeInsets.fromLTRB(22, 22, 22, 12), sliver: SliverToBoxAdapter(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Your Library', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: -0.7)),
        const SizedBox(height: 6),
        Text('${controller.songs.length} songs on this device', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        const SizedBox(height: 20),
        _SearchField(onChanged: controller.updateSearch),
        const SizedBox(height: 18),
        Row(children: [const Text('All songs', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)), const Spacer(), IconButton(tooltip: 'Scan music again', onPressed: controller.isLoading.value ? null : controller.refreshLibrary, icon: const Icon(Icons.refresh_rounded))]),
      ]))),
      if (controller.isLoading.value)
        const SliverFillRemaining(hasScrollBody: false, child: Center(child: CircularProgressIndicator(color: AppColors.primary)))
      else if (!controller.hasPermission.value)
        SliverFillRemaining(hasScrollBody: false, child: _InfoState(icon: Icons.folder_off_outlined, title: 'Music access is needed', message: 'Allow DN Audio to access audio files so it can build your offline library.', actionLabel: 'Allow access', onPressed: controller.refreshLibrary))
      else if (controller.errorMessage.value != null)
        SliverFillRemaining(hasScrollBody: false, child: _InfoState(icon: Icons.error_outline_rounded, title: 'Could not scan music', message: controller.errorMessage.value!, actionLabel: 'Try again', onPressed: controller.refreshLibrary))
      else if (controller.songs.isEmpty)
        const SliverFillRemaining(hasScrollBody: false, child: _InfoState(icon: Icons.music_off_rounded, title: 'No music found', message: 'Audio files stored on your device will appear here after scanning.'))
      else if (visibleSongs.isEmpty)
        const SliverFillRemaining(hasScrollBody: false, child: _InfoState(icon: Icons.search_off_rounded, title: 'No matching songs', message: 'Try another song, artist, or album name.'))
      else
        SliverPadding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 24), sliver: SliverList.separated(itemCount: visibleSongs.length, separatorBuilder: (_, _) => const Divider(height: 1, indent: 68), itemBuilder: (context, index) => _SongTile(song: visibleSongs[index]))),
    ]);
  });
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.onChanged});
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) => TextField(onChanged: onChanged, style: const TextStyle(fontSize: 14), decoration: InputDecoration(
    hintText: 'Search songs, artists, albums...', prefixIcon: const Icon(Icons.search_rounded), filled: true, fillColor: AppColors.surface, contentPadding: const EdgeInsets.symmetric(vertical: 15),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.border)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.border)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.primary)),
  ));
}

class _SongTile extends StatelessWidget {
  const _SongTile({required this.song});
  final Song song;
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
    leading: Container(width: 48, height: 48, decoration: BoxDecoration(color: AppColors.surfaceElevated, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.music_note_rounded, color: AppColors.primary)),
    title: Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
    subtitle: Text(song.artist, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
    trailing: Text(song.durationLabel, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
    onTap: () => Get.find<PlayerController>().playSong(song, Get.find<LibraryController>().songs.toList()),
  );
}

class _InfoState extends StatelessWidget {
  const _InfoState({required this.icon, required this.title, required this.message, this.actionLabel, this.onPressed});
  final IconData icon;
  final String title, message;
  final String? actionLabel;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 48, color: AppColors.primary), const SizedBox(height: 16),
    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)), const SizedBox(height: 8),
    Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
    if (actionLabel != null) ...[const SizedBox(height: 20), FilledButton(onPressed: onPressed, child: Text(actionLabel!))],
  ])));
}
