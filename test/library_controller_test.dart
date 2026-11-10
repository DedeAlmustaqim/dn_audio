import 'package:flutter_test/flutter_test.dart';

import 'package:dn_audio/modules/library/controllers/library_controller.dart';
import 'package:dn_audio/modules/library/models/song.dart';
import 'package:dn_audio/modules/library/services/audio_library_service.dart';

void main() {
  group('LibraryController', () {
    test('does not request permission until the library is opened', () async {
      final service = _FakeAudioLibraryService();
      final controller = LibraryController(service: service);

      expect(service.permissionChecks, 0);
      expect(service.permissionRequests, 0);
      expect(service.scanRequests, 0);

      await controller.ensureLoaded();

      expect(service.permissionChecks, 1);
      expect(service.permissionRequests, 1);
      expect(service.scanRequests, 1);
      expect(controller.hasPermission.value, isTrue);
    });

    test('loads the library only once through ensureLoaded', () async {
      final service = _FakeAudioLibraryService();
      final controller = LibraryController(service: service);

      await controller.ensureLoaded();
      await controller.ensureLoaded();

      expect(service.permissionChecks, 1);
      expect(service.permissionRequests, 1);
      expect(service.scanRequests, 1);
    });

    test('concurrent load requests share one scan operation', () async {
      final service = _FakeAudioLibraryService();
      final controller = LibraryController(service: service);

      final firstLoad = controller.ensureLoaded();
      final secondLoad = controller.ensureLoaded();

      expect(service.permissionChecks, 1);
      expect(service.permissionRequests, 0);
      expect(controller.isLoading.value, isTrue);

      await Future.wait([firstLoad, secondLoad]);

      expect(service.permissionChecks, 1);
      expect(service.permissionRequests, 1);
      expect(service.scanRequests, 1);
      expect(controller.isLoading.value, isFalse);
    });
  });
}

class _FakeAudioLibraryService extends AudioLibraryService {
  int permissionChecks = 0;
  int permissionRequests = 0;
  int scanRequests = 0;

  @override
  Future<bool> hasPermission() async {
    permissionChecks++;
    return false;
  }

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    return true;
  }

  @override
  Future<List<Song>> getSongs() async {
    scanRequests++;
    return const [];
  }
}
