import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dn_audio/modules/library/services/audio_library_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('dn_audio/audio_library');
  final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final service = AudioLibraryService();

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
  });

  test('passes normalized selected extensions to native scanner', () async {
    List<String>? receivedExtensions;
    messenger.setMockMethodCallHandler(channel, (call) async {
      expect(call.method, 'getSongs');
      receivedExtensions = List<String>.from(
        (call.arguments as Map)['extensions'] as List,
      );
      return <Map<String, Object?>>[];
    });

    await service.getSongs(extensions: {'.MP3', ' flac ', 'unsupported'});

    expect(receivedExtensions, ['mp3', 'flac']);
  });

  test('passes an empty selection without silently enabling formats', () async {
    List<String>? receivedExtensions;
    messenger.setMockMethodCallHandler(channel, (call) async {
      receivedExtensions = List<String>.from(
        (call.arguments as Map)['extensions'] as List,
      );
      return <Map<String, Object?>>[];
    });

    await service.getSongs(extensions: <String>{});

    expect(receivedExtensions, isEmpty);
  });

  test('uses all supported formats when no selection is supplied', () async {
    List<String>? receivedExtensions;
    messenger.setMockMethodCallHandler(channel, (call) async {
      receivedExtensions = List<String>.from(
        (call.arguments as Map)['extensions'] as List,
      );
      return <Map<String, Object?>>[];
    });

    await service.getSongs();

    expect(receivedExtensions, [
      'mp3',
      'flac',
      'wav',
      'm4a',
      'aac',
      'ogg',
      'opus',
    ]);
  });
}
