import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'core/routes/app_pages.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'modules/player/services/dn_audio_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final audioHandler = await AudioService.init(
    builder: DnAudioHandler.new,
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.digitalnative.dn_audio.channel.audio',
      androidNotificationChannelName: 'DN Audio Playback',
      androidNotificationChannelDescription:
          'Playback controls and current track information for DN Audio.',
      androidNotificationOngoing: true,
    ),
  );

  Get.put<DnAudioHandler>(audioHandler as DnAudioHandler, permanent: true);
  runApp(const DnAudioApp());
}

class DnAudioApp extends StatelessWidget {
  const DnAudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'DN Audio',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      initialRoute: AppRoutes.home,
      getPages: AppPages.pages,
    );
  }
}
