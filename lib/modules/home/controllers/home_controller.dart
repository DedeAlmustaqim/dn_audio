import 'package:get/get.dart';

import '../../library/controllers/library_controller.dart';

class HomeController extends GetxController {
  final selectedTab = 0.obs;

  void selectTab(int index) {
    selectedTab.value = index;

    if (index == 1) {
      Get.find<LibraryController>().ensureLoaded();
    }
  }
}
