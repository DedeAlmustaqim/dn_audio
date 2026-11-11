import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../models/song.dart';
import '../services/artwork_service.dart';

class SongArtwork extends StatefulWidget {
  const SongArtwork({
    super.key,
    required this.song,
    this.iconSize = 28,
  });

  final Song song;
  final double iconSize;

  @override
  State<SongArtwork> createState() => _SongArtworkState();
}

class _SongArtworkState extends State<SongArtwork> {
  late Future<Uri?> _artworkFuture;

  @override
  void initState() {
    super.initState();
    _artworkFuture = ArtworkService.resolve(widget.song);
  }

  @override
  void didUpdateWidget(covariant SongArtwork oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.song.id != widget.song.id) {
      _artworkFuture = ArtworkService.resolve(widget.song);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uri?>(
      future: _artworkFuture,
      builder: (context, snapshot) {
        final uri = snapshot.data;
        if (uri != null && uri.scheme == 'file') {
          return Image.file(
            File(uri.toFilePath()),
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (_, _, _) => _placeholder(),
          );
        }
        return _placeholder();
      },
    );
  }

  Widget _placeholder() => Container(
        color: AppColors.surfaceElevated,
        alignment: Alignment.center,
        child: Icon(
          Icons.graphic_eq_rounded,
          size: widget.iconSize,
          color: AppColors.primary,
        ),
      );
}
