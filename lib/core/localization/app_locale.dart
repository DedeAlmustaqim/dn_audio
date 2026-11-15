import 'package:flutter/material.dart';

class AppLocale {
  AppLocale._();

  static const supportedLocales = [
    Locale('en', 'US'),
    Locale('id', 'ID'),
  ];

  static Locale fromLanguageCode(String? languageCode) {
    return languageCode == 'id'
        ? const Locale('id', 'ID')
        : const Locale('en', 'US');
  }

  static String languageCodeFor(Locale locale) =>
      locale.languageCode == 'id' ? 'id' : 'en';
}
