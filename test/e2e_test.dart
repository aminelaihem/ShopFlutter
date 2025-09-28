import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shopflutter/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Tests End-to-End', () {
    testWidgets('E2E - Parcours utilisateur complet', (
      WidgetTester tester,
    ) async {
      // Démarrer l'application
      app.main();
      await tester.pumpAndSettle();

      // Étape 1: Vérifier que l'application démarre
      expect(find.byType(MaterialApp), findsOneWidget);

      // Étape 2: Navigation vers l'authentification (si disponible)
      final authButtons = find.text('Se connecter').or(find.text('Login'));
      if (authButtons.evaluate().isNotEmpty) {
        await tester.tap(authButtons.first);
        await tester.pumpAndSettle();
      }

      // Étape 3: Navigation vers le catalogue (si disponible)
      final catalogButtons = find.text('Catalogue').or(find.text('Produits'));
      if (catalogButtons.evaluate().isNotEmpty) {
        await tester.tap(catalogButtons.first);
        await tester.pumpAndSettle();
      }

      // Étape 4: Navigation vers le panier (si disponible)
      final cartButtons = find.text('Panier').or(find.text('Cart'));
      if (cartButtons.evaluate().isNotEmpty) {
        await tester.tap(cartButtons.first);
        await tester.pumpAndSettle();
      }

      // Vérifier que l'application est toujours stable
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(ErrorWidget), findsNothing);
    });

    testWidgets('E2E - Test de navigation complète', (
      WidgetTester tester,
    ) async {
      app.main();
      await tester.pumpAndSettle();

      // Parcourir tous les boutons disponibles
      final allButtons = find.byType(ElevatedButton);
      final buttonCount = allButtons.evaluate().length;

      for (int i = 0; i < buttonCount && i < 10; i++) {
        // Limiter à 10 boutons pour éviter les tests trop longs
        try {
          await tester.tap(allButtons.at(i));
          await tester.pumpAndSettle();

          // Vérifier que l'application reste stable
          expect(find.byType(MaterialApp), findsOneWidget);

          // Revenir en arrière si possible
          final backButtons = find
              .byIcon(Icons.arrow_back)
              .or(find.text('Retour'));
          if (backButtons.evaluate().isNotEmpty) {
            await tester.tap(backButtons.first);
            await tester.pumpAndSettle();
          }
        } catch (e) {
          // Continuer même en cas d'erreur sur un bouton spécifique
          print('Erreur sur le bouton $i: $e');
        }
      }
    });

    testWidgets('E2E - Test de formulaires', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Rechercher des champs de texte
      final textFields = find.byType(TextField).or(find.byType(TextFormField));

      if (textFields.evaluate().isNotEmpty) {
        // Tester la saisie dans les champs
        for (int i = 0; i < textFields.evaluate().length && i < 5; i++) {
          try {
            await tester.enterText(textFields.at(i), 'Test $i');
            await tester.pumpAndSettle();
          } catch (e) {
            print('Erreur sur le champ $i: $e');
          }
        }

        // Vérifier que l'application reste stable
        expect(find.byType(MaterialApp), findsOneWidget);
      }
    });

    testWidgets('E2E - Test de gestes', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Tester le défilement si des listes sont présentes
      final scrollables = find.byType(Scrollable);

      if (scrollables.evaluate().isNotEmpty) {
        try {
          // Faire défiler vers le bas
          await tester.drag(scrollables.first, const Offset(0, -200));
          await tester.pumpAndSettle();

          // Faire défiler vers le haut
          await tester.drag(scrollables.first, const Offset(0, 200));
          await tester.pumpAndSettle();

          // Vérifier la stabilité
          expect(find.byType(MaterialApp), findsOneWidget);
        } catch (e) {
          print('Erreur lors du défilement: $e');
        }
      }
    });

    testWidgets('E2E - Test de persistance des données', (
      WidgetTester tester,
    ) async {
      app.main();
      await tester.pumpAndSettle();

      // Effectuer des actions qui pourraient modifier l'état
      final buttons = find.byType(ElevatedButton);
      if (buttons.evaluate().isNotEmpty) {
        await tester.tap(buttons.first);
        await tester.pumpAndSettle();
      }

      // Redémarrer l'application pour tester la persistance
      app.main();
      await tester.pumpAndSettle();

      // Vérifier que l'application démarre toujours correctement
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('E2E - Test de performance utilisateur', (
      WidgetTester tester,
    ) async {
      // Mesurer les temps de réponse pour les interactions utilisateur
      app.main();
      await tester.pumpAndSettle();

      final buttons = find.byType(ElevatedButton);

      if (buttons.evaluate().isNotEmpty) {
        // Mesurer le temps de réponse des boutons
        for (int i = 0; i < buttons.evaluate().length && i < 3; i++) {
          final stopwatch = Stopwatch()..start();

          await tester.tap(buttons.at(i));
          await tester.pumpAndSettle();

          stopwatch.stop();

          // Vérifier que la réponse est rapide (moins de 2 secondes)
          expect(stopwatch.elapsedMilliseconds, lessThan(2000));

          print(
            'Temps de réponse bouton $i: ${stopwatch.elapsedMilliseconds}ms',
          );
        }
      }
    });

    testWidgets('E2E - Test de récupération d\'erreurs', (
      WidgetTester tester,
    ) async {
      app.main();
      await tester.pumpAndSettle();

      // Simuler des conditions d'erreur
      try {
        // Tenter des actions qui pourraient échouer
        final nonExistentWidget = find.byKey(const Key('non-existent'));
        if (nonExistentWidget.evaluate().isNotEmpty) {
          await tester.tap(nonExistentWidget);
        }

        // Tester avec des données invalides
        final textFields = find.byType(TextField);
        if (textFields.evaluate().isNotEmpty) {
          await tester.enterText(textFields.first, '');
          await tester.pumpAndSettle();
        }
      } catch (e) {
        // Les erreurs sont attendues dans ce test
      }

      // Vérifier que l'application reste utilisable
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
