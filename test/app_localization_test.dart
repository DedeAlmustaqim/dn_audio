import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dn_audio/core/localization/app_locale.dart';
import 'package:dn_audio/core/localization/app_translations.dart';

void main() {
  group('AppLocale', () {
    test('uses Indonesian when the device language is Indonesian', () {
      expect(AppLocale.fromLanguageCode('id'), const Locale('id', 'ID'));
    });

    test('falls back to English for unsupported device languages', () {
      expect(AppLocale.fromLanguageCode('ja'), const Locale('en', 'US'));
      expect(AppLocale.fromLanguageCode(null), const Locale('en', 'US'));
    });

    test('normalizes supported locale language codes', () {
      expect(AppLocale.languageCodeFor(const Locale('id', 'ID')), 'id');
      expect(AppLocale.languageCodeFor(const Locale('en', 'US')), 'en');
    });
  });

  test('provides English and Indonesian translations for core navigation', () {
    final translations = AppTranslations().keys;
    expect(translations['en_US']?['nav_home'], 'Home');
    expect(translations['id_ID']?['nav_home'], 'Beranda');
    expect(translations['en_US']?['settings_title'], 'Settings');
    expect(translations['id_ID']?['settings_title'], 'Pengaturan');
  });
}
