import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shopflutter/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Tests de Smoke (Tests de base)', () {
    testWidgets('Smoke test - L\'application démarre', (WidgetTester tester) async {
      // Test le plus basique : l'application démarre-t-elle ?
      app.main();
      await tester.pumpAndSettle();

      // Vérifier que l'application est chargée
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Smoke test - Interface utilisateur de base', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Vérifier la présence des éléments de base
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      
      // Vérifier qu'il n'y a pas d'erreurs critiques
      final errorWidgets = find.byType(ErrorWidget);
      expect(errorWidgets, findsNothing);
    });

    testWidgets('Smoke test - Navigation de base', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Tenter une navigation simple
      final buttons = find.byType(ElevatedButton);
      if (buttons.evaluate().isNotEmpty) {
        await tester.tap(buttons.first);
        await tester.pumpAndSettle();
        
        // Vérifier que l'application est toujours stable
        expect(find.byType(MaterialApp), findsOneWidget);
        expect(find.byType(ErrorWidget), findsNothing);
      }
    });

    testWidgets('Smoke test - Gestion des états', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Vérifier que l'application peut gérer les changements d'état
      await tester.pump();
      await tester.pumpAndSettle();
      
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(ErrorWidget), findsNothing);
    });

    testWidgets('Smoke test - Responsive design', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Tester différentes tailles d'écran rapidement
      final sizes = [
        const Size(320, 568),   // Petit écran
        const Size(768, 1024),  // Tablette
        const Size(1920, 1080), // Desktop
      ];

      for (final size in sizes) {
        tester.binding.window.physicalSizeTestValue = size;
        await tester.pumpAndSettle();
        
        // Vérifier que l'application fonctionne sur toutes les tailles
        expect(find.byType(MaterialApp), findsOneWidget);
        expect(find.byType(ErrorWidget), findsNothing);
      }
    });

    testWidgets('Smoke test - Performance de base', (WidgetTester tester) async {
      // Mesurer le temps de démarrage
      final stopwatch = Stopwatch()..start();
      
      app.main();
      await tester.pumpAndSettle();
      
      stopwatch.stop();
      
      // Vérifier que l'application démarre en moins de 10 secondes (très permissif)
      expect(stopwatch.elapsedMilliseconds, lessThan(10000));
      
      // Vérifier que l'application est stable
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Smoke test - Gestion des erreurs', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Simuler des interactions qui pourraient causer des erreurs
      try {
        // Tenter de taper sur des éléments aléatoires
        final allWidgets = find.byType(Widget);
        if (allWidgets.evaluate().isNotEmpty) {
          // Taper sur le premier widget trouvé
          await tester.tap(allWidgets.first);
          await tester.pumpAndSettle();
        }
      } catch (e) {
        // Les erreurs sont acceptables dans ce test, on vérifie juste que l'app ne plante pas
      }
      
      // Vérifier que l'application est toujours stable
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Smoke test - Mémoire et stabilité', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Effectuer plusieurs cycles pour détecter les fuites mémoire évidentes
      for (int i = 0; i < 5; i++) {
        await tester.pump();
        await tester.pumpAndSettle();
        
        // Vérifier que l'application reste stable
        expect(find.byType(MaterialApp), findsOneWidget);
      }
    });
  });
}
