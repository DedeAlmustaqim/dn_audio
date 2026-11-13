import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:dn_audio/main.dart';
import 'package:dn_audio/modules/player/services/dn_audio_handler.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() {
    Get.put<DnAudioHandler>(DnAudioHandler(), permanent: true);
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('DN Audio home screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(const DnAudioApp());
    await tester.pump();
    expect(find.text('DN AUDIO'), findsOneWidget);
    expect(find.text('YOUR MUSIC. YOUR EXPERIENCE.'), findsOneWidget);
    expect(find.text('Library'), findsOneWidget);
  });
}
