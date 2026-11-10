import 'package:get/get.dart';

import '../../modules/home/controllers/home_controller.dart';
import '../../modules/home/views/home_view.dart';
import 'app_routes.dart';

abstract final class AppPages {
  static final pages = <GetPage<dynamic>>[
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<HomeController>(HomeController.new);
      }),
    ),
  ];
}
