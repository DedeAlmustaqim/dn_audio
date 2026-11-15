import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/localization/locale_controller.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../controllers/settings_controller.dart';
import '../models/audio_library_preferences.dart';
import '../models/playback_preferences.dart';
import '../../library/controllers/library_controller.dart';
import '../../library/services/artwork_service.dart';

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
        title: Text('settings_title'.tr),
        leading: IconButton(
          tooltip: 'back'.tr,
          onPressed: Get.back,
          icon: const Icon(Icons.arrow_back_rounded),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.screenHorizontal, AppSpacing.md, AppSpacing.screenHorizontal, AppSpacing.xxxl),
          children: [
            _SettingsIntro(),
            const SizedBox(height: AppSpacing.xl),
            _LanguagePreferencePanel(),
            const SizedBox(height: AppSpacing.xxxl),
            _SectionHeading(
              title: 'playback'.tr,
              subtitle: 'playback_description'.tr,
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
                          'playback_speed'.tr,
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                        SizedBox(height: AppSpacing.xxs),
                        Text(
                          'playback_speed_description'.tr,
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
            _SectionHeading(
              title: 'audio_library'.tr,
              subtitle: 'audio_library_description'.tr,
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
                    'formats_enabled'.trParams({'enabled': '${controller.preferences.value.enabledExtensions.length}', 'total': '${AudioLibraryPreferences.supportedExtensions.length}'}),
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
                  label: Text('reset_defaults'.tr),
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
              Text(
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
            _SectionHeading(
              title: 'storage_maintenance'.tr,
              subtitle: 'storage_description'.tr,
            ),
            const SizedBox(height: AppSpacing.md),
            const _LibraryOverviewPanel(),
            const SizedBox(height: AppSpacing.md),
            const _ArtworkCachePanel(),
            const SizedBox(height: 32),
            _SectionHeading(
              title: 'about'.tr,
              subtitle: 'about_description'.tr,
            ),
            const SizedBox(height: AppSpacing.md),
            const _AboutPanel(),
          ],
        );
      }),
    );
  }
}


class _LanguagePreferencePanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final localeController = Get.find<LocaleController>();
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.medium,
        border: Border.all(color: AppColors.border),
      ),
      child: Obx(() {
        final languageCode = localeController.currentLocale.value.languageCode;
        return Row(
          children: [
            const Icon(Icons.language_rounded, color: AppColors.textSecondary),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('language'.tr, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: AppSpacing.xxs),
                  Text('language_description'.tr, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            DropdownButton<String>(
              value: languageCode,
              underline: const SizedBox.shrink(),
              borderRadius: AppRadius.small,
              dropdownColor: AppColors.surfaceElevated,
              onChanged: (value) {
                if (value != null) localeController.changeLocale(value);
              },
              items: [
                DropdownMenuItem(value: 'en', child: Text('language_english'.tr)),
                DropdownMenuItem(value: 'id', child: Text('language_indonesian'.tr)),
              ],
            ),
          ],
        );
      }),
    );
  }
}

class _SettingsIntro extends StatelessWidget {
  _SettingsIntro();

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
                  'settings_intro_title'.tr,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: AppSpacing.xxs),
                Text(
                  'settings_intro_subtitle'.tr,
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
  _SectionHeading({required this.title, required this.subtitle});

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
              ? 'version_loading'.tr
              : snapshot.hasError || packageInfo == null
                  ? 'version_unavailable'.tr
                  : 'version_build'.trParams({'version': packageInfo.version, 'build': packageInfo.buildNumber});

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DN AUDIO',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2.2,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
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
              Text(
                'developed_by'.tr,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Digital Native Dev',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                'independent_development'.tr,
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
                title: Text(
                  'open_source_licenses'.tr,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'view_third_party_licenses'.tr,
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
        _scanMessage = 'scan_complete'.trParams({'count': '$count'});
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
                      Text(
                        'music_library'.tr,
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        'songs_indexed'.trParams({'count': '$songCount'}),
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
                  label: Text(isScanning ? 'scanning'.tr : 'scan_library'.tr),
                ),
              ],
            ),
            if (isScanning) ...[
              const SizedBox(height: AppSpacing.md),
              const LinearProgressIndicator(minHeight: 2),
              const SizedBox(height: 7),
              Text(
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
        title: Text('Clear artwork cache?'),
        content: Text(
          'This removes cached album artwork stored by DN Audio. '
          'Artwork will be generated again when needed. Your music files, '
          'playlists, playback preferences, and listening data will not be affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text('cancel'.tr),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text('clear_cache'.tr),
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
        _actionMessage = 'cache_cleared'.trParams({'count': '$deletedCount'});
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
                  'artwork_cache'.tr,
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
              ),
              IconButton(
                tooltip: 'refresh_cache'.tr,
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
                        'unable_read_cache'.tr,
                        style: TextStyle(color: AppColors.error, fontSize: 12),
                      ),
                    ),
                    TextButton(onPressed: _refreshCacheInfo, child: Text('retry'.tr)),
                  ],
                );
              }

              final info = snapshot.data ??
                  const ArtworkCacheInfo(fileCount: 0, totalBytes: 0);
              return Row(
                children: [
                  Expanded(
                    child: _CacheMetric(
                      label: 'total_size'.tr,
                      value: info.formattedSize,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: _CacheMetric(
                      label: 'cached_files'.tr,
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
              label: Text(_isClearing ? 'clearing_cache'.tr : 'clear_artwork_cache'.tr),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: BorderSide(color: AppColors.error.withValues(alpha: 0.45)),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'cache_note'.tr,
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
