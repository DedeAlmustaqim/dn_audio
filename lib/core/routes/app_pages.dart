import 'package:get/get.dart';

import '../../modules/home/controllers/home_controller.dart';
import '../../modules/home/views/home_view.dart';
import '../../modules/library/controllers/library_controller.dart';
import '../../modules/player/controllers/player_controller.dart';
import '../../modules/player/controllers/equalizer_controller.dart';
import '../../modules/player/controllers/sleep_timer_controller.dart';
import '../../modules/playlist/controllers/playlist_controller.dart';
import 'app_routes.dart';

abstract final class AppPages {
  static final pages = <GetPage<dynamic>>[
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<HomeController>(HomeController.new);
        Get.lazyPut<LibraryController>(LibraryController.new);
        Get.lazyPut<PlaylistController>(PlaylistController.new);
        Get.put<PlayerController>(PlayerController(), permanent: true);
        Get.put<EqualizerController>(EqualizerController(), permanent: true);
        Get.put<SleepTimerController>(SleepTimerController(), permanent: true);
      }),
    ),
  ];
}
