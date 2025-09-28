// test/widget/simple_widget_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Simple Widget Tests', () {
    testWidgets('devrait afficher un texte simple', (
      WidgetTester tester,
    ) async {
      // Arrange
      const testText = 'Hello World';

      // Act
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: Text(testText))),
      );

      // Assert
      expect(find.text(testText), findsOneWidget);
    });

    testWidgets('devrait afficher un bouton', (WidgetTester tester) async {
      // Arrange
      const buttonText = 'Test Button';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ElevatedButton(
              onPressed: () {},
              child: const Text(buttonText),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(buttonText), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('devrait gérer les interactions de bouton', (
      WidgetTester tester,
    ) async {
      // Arrange
      bool buttonPressed = false;
      const buttonText = 'Press Me';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ElevatedButton(
              onPressed: () => buttonPressed = true,
              child: const Text(buttonText),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Assert
      expect(buttonPressed, isTrue);
    });

    testWidgets('devrait afficher un formulaire simple', (
      WidgetTester tester,
    ) async {
      // Arrange
      const hintText = 'Enter text';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextField(
              decoration: const InputDecoration(hintText: hintText),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text(hintText), findsOneWidget);
    });

    testWidgets('devrait gérer la saisie de texte', (
      WidgetTester tester,
    ) async {
      // Arrange
      const inputText = 'Test Input';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextField(
              decoration: const InputDecoration(hintText: 'Enter text'),
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), inputText);

      // Assert
      expect(find.text(inputText), findsOneWidget);
    });

    testWidgets('devrait afficher une liste', (WidgetTester tester) async {
      // Arrange
      final items = ['Item 1', 'Item 2', 'Item 3'];

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: items
                  .map((item) => ListTile(title: Text(item)))
                  .toList(),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(ListView), findsOneWidget);
      for (final item in items) {
        expect(find.text(item), findsOneWidget);
      }
    });
  });
}
