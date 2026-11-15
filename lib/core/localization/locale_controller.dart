import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../modules/settings/services/settings_repository.dart';

class LocaleController extends GetxController {
  LocaleController({
    required this.initialLocale,
    SettingsRepository? repository,
  }) : _repository = repository ?? SettingsRepository();

  final Locale initialLocale;
  final SettingsRepository _repository;
  final currentLocale = const Locale('en', 'US').obs;

  @override
  void onInit() {
    super.onInit();
    currentLocale.value = initialLocale;
  }

  Future<void> changeLocale(String languageCode) async {
    final locale = languageCode == 'id'
        ? const Locale('id', 'ID')
        : const Locale('en', 'US');
    if (currentLocale.value == locale) return;

    await _repository.saveLanguageCode(languageCode);
    currentLocale.value = locale;
    Get.updateLocale(locale);
  }

  @override
  void onClose() {
    _repository.close();
    super.onClose();
  }
}
