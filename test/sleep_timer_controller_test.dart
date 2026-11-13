import 'package:flutter_test/flutter_test.dart';
import 'package:dn_audio/modules/player/controllers/sleep_timer_controller.dart';

void main() {
  group('SleepTimerController', () {
    final controller = SleepTimerController();

    test('formats minutes and seconds', () {
      expect(
        controller.formatRemaining(const Duration(minutes: 5, seconds: 9)),
        '05:09',
      );
    });

    test('formats hours, minutes, and seconds', () {
      expect(
        controller.formatRemaining(
          const Duration(hours: 2, minutes: 4, seconds: 7),
        ),
        '02:04:07',
      );
    });

    test('formats zero duration', () {
      expect(controller.formatRemaining(Duration.zero), '00:00');
    });
  });
}
