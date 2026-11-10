import 'package:flutter_test/flutter_test.dart';
import 'package:dn_audio/main.dart';

void main() {
  testWidgets('DN Audio home screen renders', (WidgetTester tester) async {
    await tester.pumpWidget(const DnAudioApp());
    await tester.pump();
    expect(find.text('DN AUDIO'), findsOneWidget);
    expect(find.text('Your Music.'), findsOneWidget);
    expect(find.text('Library'), findsOneWidget);
  });
}
