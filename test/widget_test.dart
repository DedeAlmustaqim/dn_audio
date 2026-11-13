import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:dn_audio/main.dart';
import 'package:dn_audio/modules/player/services/dn_audio_handler.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.put<DnAudioHandler>(DnAudioHandler(), permanent: true);
  });

  tearDown(() async {
    await Get.reset();
  });

  testWidgets('DN Audio home screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(const DnAudioApp());
    await tester.pump();
    expect(find.text('DN AUDIO'), findsOneWidget);
    expect(find.text('Your Music.'), findsOneWidget);
    expect(find.text('Library'), findsOneWidget);
  });
}
