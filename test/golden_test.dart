import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopflutter/main.dart' as app;

void main() {
  group('Tests Golden Files', () {
    testWidgets('Golden test - Écran principal', (WidgetTester tester) async {
      // Configuration pour les tests golden
      tester.binding.window.physicalSizeTestValue = const Size(375, 667);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      // Démarrer l'application
      app.main();
      await tester.pumpAndSettle();

      // Capturer l'écran principal
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/main_screen.png'),
      );
    });

    testWidgets('Golden test - Thème sombre', (WidgetTester tester) async {
      tester.binding.window.physicalSizeTestValue = const Size(375, 667);
      tester.binding.window.devicePixelRatioTestValue = 1.0;

      app.main();
      await tester.pumpAndSettle();

      // Capturer avec le thème sombre
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/dark_theme.png'),
      );
    });

    testWidgets('Golden test - iPhone SE', (WidgetTester tester) async {
      // Taille iPhone SE
      tester.binding.window.physicalSizeTestValue = const Size(320, 568);
      tester.binding.window.devicePixelRatioTestValue = 2.0;

      app.main();
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/iphone_se.png'),
      );
    });

    testWidgets('Golden test - iPad', (WidgetTester tester) async {
      // Taille iPad
      tester.binding.window.physicalSizeTestValue = const Size(768, 1024);
      tester.binding.window.devicePixelRatioTestValue = 2.0;

      app.main();
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/ipad.png'),
      );
    });

    testWidgets('Golden test - Orientation paysage', (WidgetTester tester) async {
      // Orientation paysage
      tester.binding.window.physicalSizeTestValue = const Size(667, 375);
      tester.binding.window.devicePixelRatioTestValue = 2.0;

      app.main();
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/landscape.png'),
      );
    });
  });
}
