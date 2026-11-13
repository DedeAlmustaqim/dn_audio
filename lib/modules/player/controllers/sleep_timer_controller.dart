import 'dart:async';

import 'package:get/get.dart';

import '../services/dn_audio_handler.dart';

class SleepTimerController extends GetxController {
  SleepTimerController({DnAudioHandler? handler}) : _handler = handler;

  DnAudioHandler? _handler;
  StreamSubscription<Duration?>? _remainingSubscription;

  final remainingTime = Rxn<Duration>();
  final isActive = false.obs;

  @override
  void onInit() {
    super.onInit();
    _handler ??= Get.find<DnAudioHandler>();
    final timer = _handler!.sleepTimerService;
    remainingTime.value = timer.remainingTime;
    isActive.value = timer.isActive;
    _remainingSubscription = timer.remainingTimeStream.listen((value) {
      remainingTime.value = value;
      isActive.value = timer.isActive;
    });
  }

  void start(Duration duration) {
    final timer = _handler!.sleepTimerService;
    timer.start(duration);
    remainingTime.value = duration;
    isActive.value = true;
  }

  void cancel() {
    _handler!.sleepTimerService.cancel();
    remainingTime.value = null;
    isActive.value = false;
  }

  String formatRemaining(Duration value) {
    final hours = value.inHours;
    final minutes = value.inMinutes.remainder(60);
    final seconds = value.inSeconds.remainder(60);
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void onClose() {
    _remainingSubscription?.cancel();
    super.onClose();
  }
}
