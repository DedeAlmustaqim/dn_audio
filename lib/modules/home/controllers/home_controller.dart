import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../library/controllers/library_controller.dart';

class HomeController extends GetxController {
  final selectedTab = 0.obs;
  final searchTextController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    Get.find<LibraryController>().ensureLoaded();
  }

  void selectTab(int index) {
    selectedTab.value = index;
    if (index == 1) Get.find<LibraryController>().ensureLoaded();
  }

  void openLibrary({String section = 'songs', String query = ''}) {
    final library = Get.find<LibraryController>();
    library.selectLibrarySection(section);
    library.updateSearch(query);
    selectedTab.value = 1;
  }

  void submitSearch(String value) =>
      openLibrary(section: 'songs', query: value.trim());

  @override
  void onClose() {
    searchTextController.dispose();
    super.onClose();
  }
}