import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';

import 'core/localization/app_locale.dart';
import 'core/localization/app_translations.dart';
import 'core/routes/app_pages.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DnAudioApp());
}

class DnAudioApp extends StatelessWidget {
  const DnAudioApp({super.key, this.initialLocale, this.initialRoute = AppRoutes.splash});

  final Locale? initialLocale;
  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    final resolvedLocale = initialLocale ?? AppLocale.fromLanguageCode(
      WidgetsBinding.instance.platformDispatcher.locale.languageCode,
    );

    return GetMaterialApp(
      title: 'DN Audio',
      translations: AppTranslations(),
      locale: resolvedLocale,
      fallbackLocale: const Locale('en', 'US'),
      supportedLocales: AppLocale.supportedLocales,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      initialRoute: initialRoute,
      getPages: AppPages.pages,
    );
  }
}
