// test/widget/auth/auth_layout_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopflutter/src/features/auth/presentation/widgets/auth_layout.dart';

void main() {
  group('AuthLayout Widget Tests', () {
    testWidgets('devrait afficher le titre et sous-titre', (
      WidgetTester tester,
    ) async {
      // Arrange
      const title = 'Test Title';
      const subtitle = 'Test Subtitle';
      const child = Text('Test Child');

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: AuthLayout(title: title, subtitle: subtitle, child: child),
        ),
      );

      // Assert
      expect(find.text(title), findsOneWidget);
      expect(find.text(subtitle), findsOneWidget);
      expect(find.text('Test Child'), findsOneWidget);
    });

    testWidgets('devrait afficher le gradient de fond', (
      WidgetTester tester,
    ) async {
      // Arrange
      const child = Text('Test Child');

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: AuthLayout(title: 'Test', subtitle: 'Test', child: child),
        ),
      );

      // Assert
      expect(find.byType(Container), findsWidgets);
      expect(find.text('Test Child'), findsOneWidget);
    });

    testWidgets('devrait afficher les éléments décoratifs', (
      WidgetTester tester,
    ) async {
      // Arrange
      const child = Text('Test Child');

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: AuthLayout(title: 'Test', subtitle: 'Test', child: child),
        ),
      );

      // Assert
      expect(find.byType(Positioned), findsWidgets);
      expect(find.text('Test Child'), findsOneWidget);
    });

    testWidgets('devrait centrer le contenu', (WidgetTester tester) async {
      // Arrange
      const child = Text('Test Child');

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: AuthLayout(title: 'Test', subtitle: 'Test', child: child),
        ),
      );

      // Assert
      expect(find.byType(Center), findsWidgets);
      expect(find.text('Test Child'), findsOneWidget);
    });
  });
}
