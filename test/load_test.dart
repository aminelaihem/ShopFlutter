import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shopflutter/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Tests de charge', () {
    testWidgets('Test de charge - Chargement initial', (
      WidgetTester tester,
    ) async {
      // Mesurer le temps de chargement initial
      final stopwatch = Stopwatch()..start();

      app.main();
      await tester.pumpAndSettle();

      stopwatch.stop();

      // Vérifier que l'application se charge en moins de 5 secondes
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));

      print('Temps de chargement initial: ${stopwatch.elapsedMilliseconds}ms');
    });

    testWidgets('Test de charge - Navigation répétée', (
      WidgetTester tester,
    ) async {
      app.main();
      await tester.pumpAndSettle();

      // Effectuer plusieurs navigations pour tester la charge
      final buttons = find.byType(ElevatedButton);
      final totalButtons = buttons.evaluate().length;

      if (totalButtons > 0) {
        for (int i = 0; i < 20; i++) {
          final buttonIndex = i % totalButtons;
          final button = buttons.at(buttonIndex);

          final stopwatch = Stopwatch()..start();
          await tester.tap(button);
          await tester.pumpAndSettle();
          stopwatch.stop();

          // Vérifier que chaque navigation se fait rapidement
          expect(stopwatch.elapsedMilliseconds, lessThan(1000));
        }
      }
    });

    testWidgets('Test de charge - Rendu de widgets', (
      WidgetTester tester,
    ) async {
      app.main();
      await tester.pumpAndSettle();

      // Tester le rendu de nombreux widgets
      for (int i = 0; i < 50; i++) {
        final stopwatch = Stopwatch()..start();

        // Forcer un rebuild
        await tester.pump();
        await tester.pumpAndSettle();

        stopwatch.stop();

        // Vérifier que le rendu reste rapide
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
      }
    });

    testWidgets('Test de charge - Gestion des événements', (
      WidgetTester tester,
    ) async {
      app.main();
      await tester.pumpAndSettle();

      // Simuler de nombreux événements
      final buttons = find.byType(ElevatedButton);
      final totalButtons = buttons.evaluate().length;

      if (totalButtons > 0) {
        for (int i = 0; i < 100; i++) {
          final buttonIndex = i % totalButtons;
          final button = buttons.at(buttonIndex);

          // Simuler un tap rapide
          await tester.tap(button);
          await tester.pump();
        }

        // Vérifier que l'application est toujours stable
        expect(find.byType(MaterialApp), findsOneWidget);
      }
    });

    testWidgets('Test de charge - Mémoire', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Effectuer des opérations répétées pour tester la gestion mémoire
      for (int cycle = 0; cycle < 10; cycle++) {
        // Navigation
        final buttons = find.byType(ElevatedButton);
        if (buttons.evaluate().isNotEmpty) {
          await tester.tap(buttons.first);
          await tester.pumpAndSettle();
        }

        // Rebuild
        await tester.pump();
        await tester.pumpAndSettle();

        // Vérifier que l'application reste stable
        expect(find.byType(MaterialApp), findsOneWidget);
      }
    });
  });
}
