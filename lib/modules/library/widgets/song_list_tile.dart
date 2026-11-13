import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../models/song.dart';
import 'song_artwork.dart';

class SongListTile extends StatelessWidget {
  const SongListTile({
    super.key,
    required this.song,
    required this.onTap,
    this.trailing,
    this.artworkSize = 48,
  });

  final Song song;
  final VoidCallback onTap;
  final Widget? trailing;
  final double artworkSize;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      minTileHeight: artworkSize + AppSpacing.lg,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      horizontalTitleGap: AppSpacing.md,
      leading: ClipRRect(
        borderRadius: AppRadius.small,
        child: SizedBox(
          width: artworkSize,
          height: artworkSize,
          child: SongArtwork(song: song, iconSize: artworkSize * 0.46),
        ),
      ),
      title: Text(
        song.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.xxs),
        child: Text(
          song.artist,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
