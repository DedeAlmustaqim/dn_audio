import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dn_audio/core/widgets/app_empty_state.dart';
import 'package:dn_audio/core/widgets/app_search_field.dart';
import 'package:dn_audio/core/widgets/app_loading_state.dart';

void main() {
  group('AppSearchField', () {
    testWidgets('forwards entered text to onChanged', (tester) async {
      String? query;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppSearchField(
              hintText: 'Search music',
              onChanged: (value) => query = value,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'ambient');
      expect(query, 'ambient');
    });
  });

  group('AppEmptyState', () {
    testWidgets('shows content and invokes its optional action', (tester) async {
      var actionCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppEmptyState(
              icon: Icons.music_off,
              title: 'No music found',
              message: 'Scan your device to find local music.',
              actionLabel: 'Scan again',
              onAction: () => actionCalled = true,
            ),
          ),
        ),
      );

      expect(find.text('No music found'), findsOneWidget);
      expect(find.text('Scan your device to find local music.'), findsOneWidget);
      await tester.tap(find.text('Scan again'));
      expect(actionCalled, isTrue);
    });

    testWidgets('does not show an action when no callback is supplied', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppEmptyState(
              icon: Icons.music_off,
              title: 'No music found',
              message: 'Your songs will appear here.',
              actionLabel: 'Scan again',
            ),
          ),
        ),
      );

      expect(find.text('Scan again'), findsNothing);
    });
  });
  group('AppLoadingState', () {
    testWidgets('shows progress and optional label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppLoadingState(label: 'Loading library...'),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading library...'), findsOneWidget);
    });
  });

}
