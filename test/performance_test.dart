import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shopflutter/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Tests de performance', () {
    testWidgets('Test de performance - Chargement initial', (WidgetTester tester) async {
      // Mesurer le temps de démarrage
      final stopwatch = Stopwatch()..start();
      
      app.main();
      await tester.pumpAndSettle();
      
      stopwatch.stop();
      
      // Vérifier que l'application se charge en moins de 3 secondes
      expect(stopwatch.elapsedMilliseconds, lessThan(3000));
      
      print('Temps de chargement: ${stopwatch.elapsedMilliseconds}ms');
    });

    testWidgets('Test de performance - Navigation', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Mesurer le temps de navigation
      final stopwatch = Stopwatch()..start();
      
      // Simuler une navigation (si des boutons de navigation existent)
      final navigationButtons = find.byType(ElevatedButton);
      if (navigationButtons.evaluate().isNotEmpty) {
        await tester.tap(navigationButtons.first);
        await tester.pumpAndSettle();
      }
      
      stopwatch.stop();
      
      // Vérifier que la navigation se fait en moins de 1 seconde
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      
      print('Temps de navigation: ${stopwatch.elapsedMilliseconds}ms');
    });

    testWidgets('Test de performance - Rendu des widgets', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Mesurer le temps de rendu
      final stopwatch = Stopwatch()..start();
      
      // Forcer un rebuild
      await tester.pump();
      await tester.pumpAndSettle();
      
      stopwatch.stop();
      
      // Vérifier que le rendu se fait rapidement
      expect(stopwatch.elapsedMilliseconds, lessThan(500));
      
      print('Temps de rendu: ${stopwatch.elapsedMilliseconds}ms');
    });
  });
}
