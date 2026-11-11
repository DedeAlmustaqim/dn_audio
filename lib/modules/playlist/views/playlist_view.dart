import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../controllers/playlist_controller.dart';
import '../models/playlist.dart';
import 'playlist_detail_view.dart';

class PlaylistView extends GetView<PlaylistController> {
  const PlaylistView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 28),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Playlists',
                            style: TextStyle(
                              fontSize: 27,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.7,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Organize your music your way.',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton.filled(
                      onPressed: controller.isSaving.value
                          ? null
                          : () => _showPlaylistDialog(context),
                      icon: const Icon(Icons.add_rounded),
                      tooltip: 'Create playlist',
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                if (controller.isLoading.value)
                  const Padding(
                    padding: EdgeInsets.only(top: 70),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (controller.errorMessage.value != null &&
                    controller.playlists.isEmpty)
                  _EmptyState(
                    icon: Icons.error_outline_rounded,
                    title: 'Could not load playlists',
                    description: controller.errorMessage.value!,
                    actionLabel: 'Try again',
                    onAction: controller.loadPlaylists,
                  )
                else if (controller.playlists.isEmpty)
                  _EmptyState(
                    icon: Icons.queue_music_rounded,
                    title: 'No playlists yet',
                    description:
                        'Create your first playlist and start organizing your music.',
                    actionLabel: 'Create playlist',
                    onAction: () => _showPlaylistDialog(context),
                  )
                else ...[
                  Text(
                    '${controller.playlists.length} PLAYLISTS',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 13),
                  ...controller.playlists.map(
                    (playlist) => _PlaylistTile(
                      playlist: playlist,
                      onRename: () => _showPlaylistDialog(
                        context,
                        playlist: playlist,
                      ),
                      onDelete: () => _confirmDelete(context, playlist),
                    ),
                  ),
                ],
              ]),
            ),
          ),
        ],
      );
    });
  }

  Future<void> _showPlaylistDialog(
    BuildContext context, {
    Playlist? playlist,
  }) async {
    controller.errorMessage.value = null;
    await showDialog<void>(
      context: context,
      builder: (_) => _PlaylistNameDialog(
        controller: controller,
        playlist: playlist,
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    Playlist playlist,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete playlist?'),
        content: Text(
          '“${playlist.name}” will be deleted. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await controller.deletePlaylist(playlist.id);
    }
  }
}

class _PlaylistNameDialog extends StatefulWidget {
  const _PlaylistNameDialog({
    required this.controller,
    this.playlist,
  });

  final PlaylistController controller;
  final Playlist? playlist;

  @override
  State<_PlaylistNameDialog> createState() => _PlaylistNameDialogState();
}

class _PlaylistNameDialogState extends State<_PlaylistNameDialog> {
  late final TextEditingController _textController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(
      text: widget.playlist?.name ?? '',
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (widget.controller.isSaving.value ||
        _formKey.currentState?.validate() != true) {
      return;
    }

    final playlist = widget.playlist;
    final success = playlist == null
        ? await widget.controller.createPlaylist(_textController.text)
        : await widget.controller.renamePlaylist(
            playlist.id,
            _textController.text,
          );

    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final playlist = widget.playlist;

    return AlertDialog(
      title: Text(playlist == null ? 'Create playlist' : 'Rename playlist'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _textController,
                autofocus: true,
                maxLength: 50,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  hintText: 'Playlist name',
                  counterText: '',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Playlist name is required.';
                  }
                  if (value.trim().length > 50) {
                    return 'Maximum 50 characters.';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _submit(),
              ),
              const SizedBox(height: 8),
              Obx(() {
                final error = widget.controller.errorMessage.value;
                if (error == null) return const SizedBox.shrink();
                return Align(
                  alignment: Alignment.centerLeft,
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
        ),
      ),
      actions: [
        TextButton(
          onPressed: widget.controller.isSaving.value
              ? null
              : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        Obx(
          () => FilledButton(
            onPressed:
                widget.controller.isSaving.value ? null : _submit,
            child: Text(playlist == null ? 'Create' : 'Save'),
          ),
        ),
      ],
    );
  }
}

class _PlaylistTile extends StatelessWidget {
  const _PlaylistTile({
    required this.playlist,
    required this.onRename,
    required this.onDelete,
  });

  final Playlist playlist;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        onTap: () => Get.to(() => PlaylistDetailView(playlist: playlist)),
        contentPadding: const EdgeInsets.fromLTRB(14, 5, 5, 5),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.13),
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(
            Icons.queue_music_rounded,
            color: AppColors.primary,
          ),
        ),
        title: Text(
          playlist.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          '${playlist.songCount} songs',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'rename') onRename();
            if (value == 'delete') onDelete();
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: 'rename',
              child: Text('Rename'),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Text('Delete'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String description;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 58),
      child: Column(
        children: [
          Icon(icon, size: 55, color: AppColors.primary),
          const SizedBox(height: 17),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: onAction,
            icon: const Icon(Icons.add_rounded),
            label: Text(actionLabel),
          ),
        ],
      ),
    );
  }
}
