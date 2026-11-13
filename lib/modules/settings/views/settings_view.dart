import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../controllers/settings_controller.dart';
import '../models/audio_library_preferences.dart';
import '../models/playback_preferences.dart';
import '../../library/controllers/library_controller.dart';
import '../../library/services/artwork_service.dart';
import '../../player/views/equalizer_view.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  static const _formatLabels = <String, String>{
    'mp3': 'MP3',
    'flac': 'FLAC',
    'wav': 'WAV',
    'm4a': 'M4A',
    'aac': 'AAC',
    'ogg': 'OGG',
    'opus': 'OPUS',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          tooltip: 'Back',
          onPressed: Get.back,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: const const EdgeInsets.fromLTRB(AppSpacing.screenHorizontal, AppSpacing.md, AppSpacing.screenHorizontal, AppSpacing.xxxl),
          children: [
            const _SettingsIntro(),
            const SizedBox(height: AppSpacing.xxxl),
            const _SectionHeading(
              title: 'Playback',
              subtitle: 'Choose the playback speed used for your music.',
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.medium,
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Playback speed',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        SizedBox(height: AppSpacing.xxs),
                        Text(
                          'Adjust how fast your music plays.',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  DropdownButton<double>(
                    value: controller.playbackPreferences.value.speed,
                    underline: const SizedBox.shrink(),
                    borderRadius: AppRadius.small,
                    dropdownColor: AppColors.surfaceElevated,
                    onChanged: controller.isSaving.value
                        ? null
                        : (speed) {
                            if (speed != null) controller.setPlaybackSpeed(speed);
                          },
                    items: PlaybackPreferences.supportedSpeeds
                        .map(
                          (speed) => DropdownMenuItem<double>(
                            value: speed,
                            child: Text(
                              '$speed×',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        )
                        .toList(growable: false),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxxl),
            const _SectionHeading(
              title: 'Audio Experience',
              subtitle: 'Shape the sound with your device-supported audio effects.',
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadius.medium,
                border: Border.all(color: AppColors.border),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 6,
                ),
                leading: const Icon(
                  Icons.equalizer_rounded,
                  color: AppColors.primary,
                ),
                title: const Text(
                  'Equalizer & effects',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                subtitle: const Text(
                  'Presets, band levels, Bass Boost and Virtualizer',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Get.bottomSheet<void>(
                  const EqualizerView(isBottomSheet: true),
                  isScrollControlled: true,
                  backgroundColor: AppColors.background,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxxl),
            const _SectionHeading(
              title: 'Audio Library',
              subtitle: 'Choose which audio formats DN Audio can include in your library.',
            ),
            const SizedBox(height: AppSpacing.md),
            _FormatPanel(
              enabledExtensions: controller.preferences.value.enabledExtensions,
              isSaving: controller.isSaving.value,
              onChanged: controller.toggleExtension,
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${controller.preferences.value.enabledExtensions.length} of ${AudioLibraryPreferences.supportedExtensions.length} formats enabled',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: controller.isSaving.value
                      ? null
                      : controller.resetFormats,
                  icon: const Icon(Icons.restart_alt_rounded, size: 17),
                  label: const Text('Reset defaults'),
                ),
              ],
            ),
            if (controller.preferences.value.enabledExtensions.isEmpty)
              const _InlineNotice(
                message: 'No formats are enabled. Your music library will be empty after format filtering is applied.',
                icon: Icons.info_outline_rounded,
              ),
            if (controller.isSaving.value) ...[
              const SizedBox(height: AppSpacing.sm),
              const LinearProgressIndicator(minHeight: 2),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                'Saving and applying your changes…',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
            if (controller.errorMessage.value != null) ...[
              const SizedBox(height: AppSpacing.md),
              _InlineNotice(
                message: controller.errorMessage.value!,
                icon: Icons.error_outline_rounded,
                isError: true,
              ),
            ],
            const SizedBox(height: AppSpacing.xxxl),
            const _SectionHeading(
              title: 'Storage & Maintenance',
              subtitle: 'Review your offline library and refresh its contents.',
            ),
            const SizedBox(height: AppSpacing.md),
            const _LibraryOverviewPanel(),
            const SizedBox(height: AppSpacing.md),
            const _ArtworkCachePanel(),
            const SizedBox(height: 32),
            const _SectionHeading(
              title: 'About',
              subtitle: 'A focused offline music experience.',
            ),
            const SizedBox(height: AppSpacing.md),
            const _AboutPanel(),
          ],
        );
      }),
    );
  }
}

class _SettingsIntro extends StatelessWidget {
  const _SettingsIntro();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.large,
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        children: [
          Icon(Icons.tune_rounded, color: AppColors.primary, size: 30),
          SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Make it yours.',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: AppSpacing.xxs),
                Text(
                  'Personalize how your music is organized.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: AppSpacing.xs),
        Text(
          subtitle,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
        ),
      ],
    );
  }
}

class _FormatPanel extends StatelessWidget {
  const _FormatPanel({
    required this.enabledExtensions,
    required this.isSaving,
    required this.onChanged,
  });

  final Set<String> enabledExtensions;
  final bool isSaving;
  final Future<void> Function(String extension, bool enabled) onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.medium,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          for (var index = 0;
              index < AudioLibraryPreferences.supportedExtensions.length;
              index++) ...[
            if (index > 0)
              const Divider(height: 1, indent: 18, endIndent: 18, color: AppColors.border),
            Builder(builder: (context) {
              final extension = AudioLibraryPreferences.supportedExtensions[index];
              final selected = enabledExtensions.contains(extension);
              return SwitchListTile(
                value: selected,
                onChanged: isSaving ? null : (value) => onChanged(extension, value),
                activeThumbColor: AppColors.primary,
                title: Text(
                  SettingsView._formatLabels[extension] ?? extension.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                ),
                subtitle: Text(
                  '.$extension',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
              );
            }),
          ],
        ],
      ),
    );
  }
}

class _AboutPanel extends StatefulWidget {
  const _AboutPanel();

  @override
  State<_AboutPanel> createState() => _AboutPanelState();
}

class _AboutPanelState extends State<_AboutPanel> {
  late Future<PackageInfo> _packageInfoFuture;

  @override
  void initState() {
    super.initState();
    _packageInfoFuture = PackageInfo.fromPlatform();
  }

  void _showOpenSourceLicenses(PackageInfo packageInfo) {
    showLicensePage(
      context: context,
      applicationName: 'DN Audio',
      applicationVersion:
          '${packageInfo.version}+${packageInfo.buildNumber}',
      applicationLegalese: 'Digital Native Dev',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.medium,
        border: Border.all(color: AppColors.border),
      ),
      child: FutureBuilder<PackageInfo>(
        future: _packageInfoFuture,
        builder: (context, snapshot) {
          final packageInfo = snapshot.data;
          final versionLabel = snapshot.connectionState == ConnectionState.waiting
              ? 'Loading version…'
              : snapshot.hasError || packageInfo == null
                  ? 'Version unavailable'
                  : 'Version ${packageInfo.version} · Build ${packageInfo.buildNumber}';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'DN AUDIO',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.2,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                'Your Music. Your Experience.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'A premium offline music player designed to keep your '
                'personal music library close, with playback controls and '
                'audio experiences shaped around your listening preferences.',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 18),
              const Divider(color: AppColors.border, height: 1),
              const SizedBox(height: AppSpacing.md),
              const Text(
                'DEVELOPED BY',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                'Digital Native Dev',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSpacing.xxs),
              const Text(
                'Independent software development',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                versionLabel,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading: const Icon(
                  Icons.article_outlined,
                  color: AppColors.primary,
                ),
                title: const Text(
                  'Open-source licenses',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                subtitle: const Text(
                  'View licenses for third-party packages',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: packageInfo == null
                    ? null
                    : () => _showOpenSourceLicenses(packageInfo),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InlineNotice extends StatelessWidget {
  const _InlineNotice({
    required this.message,
    required this.icon,
    this.isError = false,
  });

  final String message;
  final IconData icon;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: AppRadius.small,
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: isError ? AppColors.error : AppColors.textSecondary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: isError ? AppColors.error : AppColors.textSecondary,
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LibraryOverviewPanel extends StatefulWidget {
  const _LibraryOverviewPanel();

  @override
  State<_LibraryOverviewPanel> createState() => _LibraryOverviewPanelState();
}

class _LibraryOverviewPanelState extends State<_LibraryOverviewPanel> {
  String? _scanMessage;
  bool _scanWasSuccessful = false;

  Future<void> _scanLibrary() async {
    final library = Get.find<LibraryController>();
    if (library.isLoading.value) return;
    setState(() => _scanMessage = null);
    await library.refreshLibrary(force: true);
    if (!mounted) return;
    setState(() {
      if (library.errorMessage.value != null) {
        _scanWasSuccessful = false;
        _scanMessage = library.errorMessage.value;
      } else if (!library.hasPermission.value) {
        _scanWasSuccessful = false;
        _scanMessage = 'Audio access was not granted. Your library was not scanned.';
      } else {
        _scanWasSuccessful = true;
        final count = library.songs.length;
        _scanMessage = 'Scan complete. $count ${count == 1 ? 'song' : 'songs'} found.';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final library = Get.find<LibraryController>();
    return Obx(() {
      final isScanning = library.isLoading.value;
      final songCount = library.songs.length;
      return Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.medium,
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: AppRadius.small,
                  ),
                  child: const Icon(Icons.library_music_rounded, color: AppColors.primary),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Music library',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        '$songCount ${songCount == 1 ? 'song' : 'songs'} indexed',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: isScanning ? null : _scanLibrary,
                  icon: isScanning
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh_rounded, size: 17),
                  label: Text(isScanning ? 'Scanning' : 'Scan library'),
                ),
              ],
            ),
            if (isScanning) ...[
              const SizedBox(height: AppSpacing.md),
              const LinearProgressIndicator(minHeight: 2),
              const SizedBox(height: 7),
              const Text(
                'Scanning audio files on this device…',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
              ),
            ],
            if (_scanMessage != null) ...[
              const SizedBox(height: AppSpacing.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    _scanWasSuccessful
                        ? Icons.check_circle_outline_rounded
                        : Icons.error_outline_rounded,
                    size: 17,
                    color: _scanWasSuccessful
                        ? AppColors.primary
                        : AppColors.error,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      _scanMessage!,
                      style: TextStyle(
                        color: _scanWasSuccessful
                            ? AppColors.textSecondary
                            : AppColors.error,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      );
    });
  }
}

class _ArtworkCachePanel extends StatefulWidget {
  const _ArtworkCachePanel();

  @override
  State<_ArtworkCachePanel> createState() => _ArtworkCachePanelState();
}

class _ArtworkCachePanelState extends State<_ArtworkCachePanel> {
  late Future<ArtworkCacheInfo> _cacheInfoFuture;
  bool _isClearing = false;
  String? _actionMessage;
  bool _actionSucceeded = false;

  @override
  void initState() {
    super.initState();
    _loadCacheInfo();
  }

  void _loadCacheInfo() {
    _cacheInfoFuture = ArtworkService.getCacheInfo();
  }

  void _refreshCacheInfo() {
    setState(() {
      _actionMessage = null;
      _loadCacheInfo();
    });
  }

  Future<void> _clearCache() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear artwork cache?'),
        content: const Text(
          'This removes cached album artwork stored by DN Audio. '
          'Artwork will be generated again when needed. Your music files, '
          'playlists, playback preferences, and listening data will not be affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Clear cache'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() {
      _isClearing = true;
      _actionMessage = null;
    });

    try {
      final deletedCount = await ArtworkService.clearCache();
      if (!mounted) return;
      setState(() {
        _isClearing = false;
        _actionSucceeded = true;
        _actionMessage = 'Artwork cache cleared. ' +
            '$deletedCount ${deletedCount == 1 ? 'file' : 'files'} removed.';
        _loadCacheInfo();
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isClearing = false;
        _actionSucceeded = false;
        _actionMessage = 'Unable to clear artwork cache. Please try again.';
        _loadCacheInfo();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.medium,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.image_outlined, color: AppColors.primary, size: 21),
              const SizedBox(width: AppSpacing.sm),
              const Expanded(
                child: Text(
                  'Artwork cache',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
              ),
              IconButton(
                tooltip: 'Refresh cache information',
                onPressed: _isClearing ? null : _refreshCacheInfo,
                icon: const Icon(Icons.refresh_rounded, size: 19),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          FutureBuilder<ArtworkCacheInfo>(
            future: _cacheInfoFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: LinearProgressIndicator(minHeight: 2),
                );
              }
              if (snapshot.hasError) {
                return Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Unable to read artwork cache information.',
                        style: TextStyle(color: AppColors.error, fontSize: 12),
                      ),
                    ),
                    TextButton(onPressed: _refreshCacheInfo, child: const Text('Retry')),
                  ],
                );
              }

              final info = snapshot.data ??
                  const ArtworkCacheInfo(fileCount: 0, totalBytes: 0);
              return Row(
                children: [
                  Expanded(
                    child: _CacheMetric(
                      label: 'Total size',
                      value: info.formattedSize,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: _CacheMetric(
                      label: 'Cached files',
                      value: info.fileCount.toString(),
                    ),
                  ),
                ],
              );
            },
          ),
          if (_actionMessage != null) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  _actionSucceeded
                      ? Icons.check_circle_outline_rounded
                      : Icons.error_outline_rounded,
                  size: 17,
                  color: _actionSucceeded
                      ? AppColors.primary
                      : AppColors.error,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    _actionMessage!,
                    style: TextStyle(
                      color: _actionSucceeded
                          ? AppColors.textSecondary
                          : AppColors.error,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isClearing ? null : _clearCache,
              icon: _isClearing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.delete_outline_rounded, size: 18),
              label: Text(_isClearing ? 'Clearing cache…' : 'Clear artwork cache'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: BorderSide(color: AppColors.error.withValues(alpha: 0.45)),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Only DN Audio artwork cache files are removed. Artwork is recreated when needed.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _CacheMetric extends StatelessWidget {
  const _CacheMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: AppSpacing.xxs),
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
        ),
      ],
    );
  }
}
