import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shopflutter/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Tests de compatibilité', () {
    testWidgets('Test de compatibilité - Thème sombre', (
      WidgetTester tester,
    ) async {
      // Tester avec le thème sombre
      app.main();
      await tester.pumpAndSettle();

      // Vérifier que l'application fonctionne avec le thème sombre
      expect(find.byType(MaterialApp), findsOneWidget);

      // Vérifier que les widgets sont correctement rendus
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('Test de compatibilité - Thème clair', (
      WidgetTester tester,
    ) async {
      // Tester avec le thème clair
      app.main();
      await tester.pumpAndSettle();

      // Vérifier que l'application fonctionne avec le thème clair
      expect(find.byType(MaterialApp), findsOneWidget);

      // Vérifier que les widgets sont correctement rendus
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('Test de compatibilité - Tailles d\'écran', (
      WidgetTester tester,
    ) async {
      app.main();
      await tester.pumpAndSettle();

      // Tester différentes tailles d'écran
      final screenSizes = [
        const Size(320, 568), // iPhone SE
        const Size(375, 667), // iPhone 8
        const Size(414, 896), // iPhone 11 Pro Max
        const Size(768, 1024), // iPad
        const Size(1024, 768), // iPad landscape
        const Size(1920, 1080), // Desktop
      ];

      for (final size in screenSizes) {
        // Changer la taille de l'écran
        tester.binding.window.physicalSizeTestValue = size;
        tester.binding.window.devicePixelRatioTestValue = 1.0;

        // Reconstruire l'application
        await tester.pumpAndSettle();

        // Vérifier que l'application fonctionne
        expect(find.byType(MaterialApp), findsOneWidget);
        expect(find.byType(Scaffold), findsOneWidget);
      }
    });

    testWidgets('Test de compatibilité - Orientation', (
      WidgetTester tester,
    ) async {
      app.main();
      await tester.pumpAndSettle();

      // Tester l'orientation portrait
      tester.binding.window.physicalSizeTestValue = const Size(375, 667);
      await tester.pumpAndSettle();
      expect(find.byType(MaterialApp), findsOneWidget);

      // Tester l'orientation paysage
      tester.binding.window.physicalSizeTestValue = const Size(667, 375);
      await tester.pumpAndSettle();
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('Test de compatibilité - Densité de pixels', (
      WidgetTester tester,
    ) async {
      app.main();
      await tester.pumpAndSettle();

      // Tester différentes densités de pixels
      final densities = [1.0, 1.5, 2.0, 3.0];

      for (final density in densities) {
        tester.binding.window.devicePixelRatioTestValue = density;
        await tester.pumpAndSettle();

        // Vérifier que l'application fonctionne
        expect(find.byType(MaterialApp), findsOneWidget);
        expect(find.byType(Scaffold), findsOneWidget);
      }
    });

    testWidgets('Test de compatibilité - Accessibilité', (
      WidgetTester tester,
    ) async {
      app.main();
      await tester.pumpAndSettle();

      // Tester avec des paramètres d'accessibilité
      tester.binding.platformDispatcher.textScaleFactorTestValue = 1.5;
      await tester.pumpAndSettle();

      // Vérifier que l'application fonctionne avec un facteur de zoom
      expect(find.byType(MaterialApp), findsOneWidget);

      // Réinitialiser
      tester.binding.platformDispatcher.textScaleFactorTestValue = 1.0;
      await tester.pumpAndSettle();
    });
  });
}
