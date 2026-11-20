import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/localization/app_locale.dart';
import '../../../core/localization/locale_controller.dart';
import '../../../core/routes/app_routes.dart';
import '../../player/services/dn_audio_handler.dart';
import '../../settings/services/settings_repository.dart';
import '../services/update_checker_service.dart';

class SplashController extends GetxController {
  final isInitializing = true.obs;
  final hasError = false.obs;

  DnAudioHandler? _handler;
  final updateInfo = Rxn<AppUpdateInfo>();
  final UpdateCheckerService _updateChecker = UpdateCheckerService();
  bool _updatePromptShown = false;

  @override
  void onReady() {
    super.onReady();
    unawaited(initialize());
  }

  Future<void> _checkForUpdate() async {
    if (_updatePromptShown) return;
    final result = await _updateChecker.checkForUpdate();
    if (result == null || !result.isUpdateAvailable) return;

    updateInfo.value = result;
      _updatePromptShown = true;
      await Future<void>.delayed(const Duration(milliseconds: 500));
      if (Get.isDialogOpen != true) {
        await Get.dialog<void>(
          AlertDialog(
            title: Text('update_available_title'.tr),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'update_available_version'.trParams({
                    'version': result.latestVersion,
                  }),
                ),
                const SizedBox(height: 12),
                Text(result.releaseNotes),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back<void>(),
                child: Text('update_later'.tr),
              ),
              FilledButton(
                onPressed: () async {
                  final uri = Uri.parse(result.playStoreUrl);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                child: Text('update_now'.tr),
              ),
            ],
          ),
          barrierDismissible: false,
        );
      }
  }

  Future<void> initialize() async {
    if (isInitializing.value && _handler != null) return;

    isInitializing.value = true;
    hasError.value = false;

    try {
      _handler ??= await AudioService.init(
        builder: DnAudioHandler.new,
        config: const AudioServiceConfig(
          androidNotificationChannelId:
              'com.digitalnative.dn_audio.channel.audio',
          androidNotificationChannelName: 'DN Audio Playback',
          androidNotificationChannelDescription:
              'Playback controls and current track information for DN Audio.',
          androidNotificationIcon: 'drawable/ic_stat_music_note',
          androidNotificationOngoing: true,
        ),
      );

      final handler = _handler!;
      await handler.configureAudioSession();

      final settingsRepository = SettingsRepository();
      final deviceLanguage =
          WidgetsBinding.instance.platformDispatcher.locale.languageCode;
      var initialLocale = AppLocale.fromLanguageCode(deviceLanguage);

      try {
        final savedLanguage = await settingsRepository.loadLanguageCode();
        if (savedLanguage != null) {
          initialLocale = AppLocale.fromLanguageCode(savedLanguage);
        }

        final playbackPreferences =
            await settingsRepository.loadPlaybackPreferences();
        await handler.setPlaybackSpeed(playbackPreferences.speed);
      } catch (error, stackTrace) {
        debugPrint('DN Audio: unable to restore startup preferences: $error');
        debugPrintStack(stackTrace: stackTrace);
      } finally {
        await settingsRepository.close();
      }

      if (!Get.isRegistered<DnAudioHandler>()) {
        Get.put<DnAudioHandler>(handler, permanent: true);
      }
      if (!Get.isRegistered<LocaleController>()) {
        Get.put<LocaleController>(
          LocaleController(initialLocale: initialLocale),
          permanent: true,
        );
      }
      Get.updateLocale(initialLocale);
      Get.offAllNamed(AppRoutes.home);
      unawaited(_checkForUpdate());
    } catch (error, stackTrace) {
      debugPrint('DN Audio: startup initialization failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      hasError.value = true;
      isInitializing.value = false;
    }
  }
}
