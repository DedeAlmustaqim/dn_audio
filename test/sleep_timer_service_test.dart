import 'package:flutter_test/flutter_test.dart';
import 'package:dn_audio/modules/player/services/sleep_timer_service.dart';

void main() {
  group('SleepTimerService', () {
    test('starts with the requested remaining duration', () async {
      final service = SleepTimerService(
        onExpired: () async {},
        tickInterval: const Duration(milliseconds: 5),
      );
      addTearDown(service.dispose);

      service.start(const Duration(seconds: 30));

      expect(service.isActive, isTrue);
      expect(service.remainingTime, const Duration(seconds: 30));
    });

    test('cancel stops countdown and clears remaining time', () async {
      var expired = false;
      final service = SleepTimerService(
        onExpired: () async {
          expired = true;
        },
        tickInterval: const Duration(milliseconds: 5),
      );
      addTearDown(service.dispose);

      service.start(const Duration(milliseconds: 20));
      service.cancel();
      await Future<void>.delayed(const Duration(milliseconds: 30));

      expect(service.isActive, isFalse);
      expect(service.remainingTime, isNull);
      expect(expired, isFalse);
    });

    test('replacing a timer uses the new duration', () async {
      var expirationCount = 0;
      final service = SleepTimerService(
        onExpired: () async {
          expirationCount++;
        },
        tickInterval: const Duration(milliseconds: 5),
      );
      addTearDown(service.dispose);

      service.start(const Duration(milliseconds: 15));
      service.start(const Duration(seconds: 30));

      await Future<void>.delayed(const Duration(milliseconds: 25));

      expect(service.isActive, isTrue);
      expect(service.remainingTime, isNotNull);
      expect(expirationCount, 0);
    });

    test('expires once and publishes zero remaining time', () async {
      var expirationCount = 0;
      final service = SleepTimerService(
        onExpired: () async => expirationCount++,
        tickInterval: const Duration(milliseconds: 5),
      );
      addTearDown(service.dispose);

      service.start(const Duration(milliseconds: 15));
      await Future<void>.delayed(const Duration(milliseconds: 40));

      expect(service.isActive, isFalse);
      expect(service.remainingTime, Duration.zero);
      expect(expirationCount, 1);
    });


    test('publishes countdown updates and zero on expiry', () async {
      final values = <Duration?>[];
      final service = SleepTimerService(
        onExpired: () async {},
        tickInterval: const Duration(milliseconds: 5),
      );
      addTearDown(service.dispose);
      final subscription = service.remainingTimeStream.listen(values.add);
      addTearDown(subscription.cancel);

      service.start(const Duration(milliseconds: 20));
      await Future<void>.delayed(const Duration(milliseconds: 45));

      expect(values, contains(Duration.zero));
      expect(values.where((value) => value == Duration.zero), hasLength(1));
    });

    test('disposing an active timer cancels expiry', () async {
      var expired = false;
      final service = SleepTimerService(
        onExpired: () async {
          expired = true;
        },
        tickInterval: const Duration(milliseconds: 5),
      );

      service.start(const Duration(milliseconds: 30));
      await service.dispose();
      await Future<void>.delayed(const Duration(milliseconds: 45));

      expect(service.isActive, isFalse);
      expect(expired, isFalse);
    });

    test('cancel publishes null after an active countdown', () async {
      final values = <Duration?>[];
      final service = SleepTimerService(
        onExpired: () async {},
        tickInterval: const Duration(milliseconds: 5),
      );
      addTearDown(service.dispose);
      final subscription = service.remainingTimeStream.listen(values.add);
      addTearDown(subscription.cancel);

      service.start(const Duration(seconds: 1));
      await Future<void>.delayed(const Duration(milliseconds: 12));
      service.cancel();
      await Future<void>.delayed(const Duration(milliseconds: 1));

      expect(values, contains(null));
      expect(service.remainingTime, isNull);
      expect(service.isActive, isFalse);
    });

    test('rejects a zero or negative duration', () async {
      final service = SleepTimerService(onExpired: () async {});
      addTearDown(service.dispose);

      expect(
        () => service.start(Duration.zero),
        throwsArgumentError,
      );
      expect(
        () => service.start(const Duration(seconds: -1)),
        throwsArgumentError,
      );
    });

    test('does not continue after disposal', () async {
      final service = SleepTimerService(onExpired: () async {});
      await service.dispose();

      expect(
        () => service.start(const Duration(seconds: 10)),
        throwsStateError,
      );
    });
  });
}
