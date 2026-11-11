import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:midterm_ready/app/app.dart';
import 'package:midterm_ready/data/in_memory_item_repository.dart';
import 'package:midterm_ready/screens/item_form_screen.dart';

void main() {
  // ---------------------------------------------------------------------------
  // App smoke test
  // ---------------------------------------------------------------------------
  group('MidtermApp', () {
    testWidgets('renders item list with seeded items', (tester) async {
      await tester.pumpWidget(MidtermApp());
      await tester.pumpAndSettle();

      // The app bar title should be visible
      expect(find.text('Items'), findsOneWidget);

      // At least one seeded item card is visible
      expect(find.text('Flutter Basics'), findsOneWidget);
    });

    testWidgets('search filters items', (tester) async {
      await tester.pumpWidget(MidtermApp());
      await tester.pumpAndSettle();

      // Open search
      await tester.tap(find.byIcon(Icons.search));
      await tester.pumpAndSettle();

      // Type a search query
      await tester.enterText(find.byType(TextField), 'null');
      await tester.pumpAndSettle();

      // Only the matching item should be visible
      expect(find.text('Dart Null Safety'), findsOneWidget);
      expect(find.text('Flutter Basics'), findsNothing);
    });
  });

  // ---------------------------------------------------------------------------
  // Form validation widget tests
  // ---------------------------------------------------------------------------
  group('ItemFormScreen validation', () {
    Widget buildForm() {
      return MaterialApp(
        home: ItemFormScreen(repository: InMemoryItemRepository()),
      );
    }

    testWidgets('shows error when title is empty on save', (tester) async {
      await tester.pumpWidget(buildForm());
      await tester.pumpAndSettle();

      // Tap the bottom Save button without entering a title
      await tester.tap(find.text('Create Item'));
      await tester.pumpAndSettle();

      expect(find.text('Title is required.'), findsOneWidget);
    });

    testWidgets('shows error when title is too short', (tester) async {
      await tester.pumpWidget(buildForm());
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('titleField')), 'A');
      await tester.tap(find.text('Create Item'));
      await tester.pumpAndSettle();

      expect(find.text('Title must be at least 2 characters.'), findsOneWidget);
    });

    testWidgets('no error when title is valid', (tester) async {
      await tester.pumpWidget(buildForm());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('titleField')),
        'Valid Title',
      );
      await tester.tap(find.text('Create Item'));
      await tester.pumpAndSettle();

      expect(find.text('Title is required.'), findsNothing);
      expect(find.text('Title must be at least 2 characters.'), findsNothing);
    });
  });
}
