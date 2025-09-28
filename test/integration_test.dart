import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shopflutter/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Tests d\'intégration', () {
    testWidgets('Test de navigation de base', (WidgetTester tester) async {
      // Démarrer l'application
      app.main();
      await tester.pumpAndSettle();

      // Vérifier que l'application se charge
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Test de l\'écran d\'accueil', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Attendre que l'application soit complètement chargée
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Vérifier la présence d'éléments de base
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
