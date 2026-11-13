import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/constants/app_colors.dart';
import '../controllers/settings_controller.dart';
import '../models/audio_library_preferences.dart';
import '../models/playback_preferences.dart';
import '../../library/controllers/library_controller.dart';
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
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            const _SettingsIntro(),
            const SizedBox(height: 28),
            const _SectionHeading(
              title: 'Playback',
              subtitle: 'Choose the playback speed used for your music.',
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
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
                        SizedBox(height: 4),
                        Text(
                          'Adjust how fast your music plays.',
                          style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  DropdownButton<double>(
                    value: controller.playbackPreferences.value.speed,
                    underline: const SizedBox.shrink(),
                    borderRadius: BorderRadius.circular(14),
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
            const SizedBox(height: 28),
            const _SectionHeading(
              title: 'Audio Experience',
              subtitle: 'Shape the sound with your device-supported audio effects.',
            ),
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
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
            const SizedBox(height: 28),
            const _SectionHeading(
              title: 'Audio Library',
              subtitle: 'Choose which audio formats DN Audio can include in your library.',
            ),
            const SizedBox(height: 14),
            _FormatPanel(
              enabledExtensions: controller.preferences.value.enabledExtensions,
              isSaving: controller.isSaving.value,
              onChanged: controller.toggleExtension,
            ),
            const SizedBox(height: 12),
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
              const SizedBox(height: 8),
              const LinearProgressIndicator(minHeight: 2),
              const SizedBox(height: 6),
              const Text(
                'Saving and applying your changes…',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
            if (controller.errorMessage.value != null) ...[
              const SizedBox(height: 12),
              _InlineNotice(
                message: controller.errorMessage.value!,
                icon: Icons.error_outline_rounded,
                isError: true,
              ),
            ],
            const SizedBox(height: 28),
            const _SectionHeading(
              title: 'Storage & Maintenance',
              subtitle: 'Review your offline library and refresh its contents.',
            ),
            const SizedBox(height: 14),
            const _LibraryOverviewPanel(),
            const SizedBox(height: 32),
            const _SectionHeading(
              title: 'About',
              subtitle: 'A focused offline music experience.',
            ),
            const SizedBox(height: 14),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        children: [
          Icon(Icons.tune_rounded, color: AppColors.primary, size: 30),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Make it yours.',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 4),
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
        const SizedBox(height: 5),
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
        borderRadius: BorderRadius.circular(18),
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
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
              );
            }),
          ],
        ],
      ),
    );
  }
}

class _AboutPanel extends StatelessWidget {
  const _AboutPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('DN AUDIO', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.8)),
          SizedBox(height: 5),
          Text(
            'Premium Offline Music Player',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          SizedBox(height: 14),
          Divider(color: AppColors.border, height: 1),
          SizedBox(height: 14),
          Text(
            'Digital Native Dev',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
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
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: isError ? Colors.redAccent : AppColors.textSecondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: isError ? Colors.redAccent : AppColors.textSecondary,
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
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
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
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(Icons.library_music_rounded, color: AppColors.primary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Music library',
                        style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
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
              const SizedBox(height: 14),
              const LinearProgressIndicator(minHeight: 2),
              const SizedBox(height: 7),
              const Text(
                'Scanning audio files on this device…',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 11),
              ),
            ],
            if (_scanMessage != null) ...[
              const SizedBox(height: 14),
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
                        : Colors.redAccent,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _scanMessage!,
                      style: TextStyle(
                        color: _scanWasSuccessful
                            ? AppColors.textSecondary
                            : Colors.redAccent,
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
