import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';

import 'core/localization/app_locale.dart';
import 'core/localization/app_translations.dart';
import 'core/localization/locale_controller.dart';
import 'core/routes/app_pages.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'modules/player/services/dn_audio_handler.dart';
import 'modules/settings/services/settings_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final handler = await AudioService.init(
    builder: DnAudioHandler.new,
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.digitalnative.dn_audio.channel.audio',
      androidNotificationChannelName: 'DN Audio Playback',
      androidNotificationChannelDescription:
          'Playback controls and current track information for DN Audio.',
      androidNotificationOngoing: true,
    ),
  );

  await handler.configureAudioSession();

  final settingsRepository = SettingsRepository();
  final deviceLanguage = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
  var initialLocale = AppLocale.fromLanguageCode(deviceLanguage);
  try {
    final savedLanguage = await settingsRepository.loadLanguageCode();
    if (savedLanguage != null) {
      initialLocale = AppLocale.fromLanguageCode(savedLanguage);
    }
    final playbackPreferences =
        await settingsRepository.loadPlaybackPreferences();
    await handler.setPlaybackSpeed(playbackPreferences.speed);
  } catch (error) {
    debugPrint('DN Audio: unable to restore playback preferences: $error');
  } finally {
    await settingsRepository.close();
  }

  Get.put<DnAudioHandler>(handler, permanent: true);
  Get.put<LocaleController>(LocaleController(initialLocale: initialLocale), permanent: true);
  runApp(DnAudioApp(initialLocale: initialLocale));
}

class DnAudioApp extends StatelessWidget {
  const DnAudioApp({super.key, this.initialLocale = const Locale('en', 'US')});

  final Locale initialLocale;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'DN Audio',
      translations: AppTranslations(),
      locale: initialLocale,
      fallbackLocale: const Locale('en', 'US'),
      supportedLocales: AppLocale.supportedLocales,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      initialRoute: AppRoutes.home,
      getPages: AppPages.pages,
    );
  }
}
