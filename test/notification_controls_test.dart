import 'package:audio_service/audio_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dn_audio/modules/player/services/dn_audio_handler.dart';

void main() {
  group('DN Audio notification controls', () {
    test('includes explicit close custom action while playing', () {
      final controls = DnAudioHandler.notificationControls(isPlaying: true);

      expect(controls, hasLength(4));
      expect(controls[1].action, MediaAction.pause);
      expect(controls.last.action, MediaAction.custom);
      expect(
        controls.last.customAction?.name,
        DnAudioHandler.notificationCloseAction,
      );
      expect(controls.last.label, 'Close');
      expect(controls.last.androidIcon, 'drawable/ic_action_close');
    });

    test('keeps close custom action while paused', () {
      final controls = DnAudioHandler.notificationControls(isPlaying: false);

      expect(controls[1].action, MediaAction.play);
      expect(controls.last.action, MediaAction.custom);
      expect(
        controls.last.customAction?.name,
        DnAudioHandler.notificationCloseAction,
      );
    });
  });
}
