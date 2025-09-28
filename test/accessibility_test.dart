import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shopflutter/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Tests d\'accessibilité', () {
    testWidgets('Test des labels sémantiques', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Vérifier la présence de labels sémantiques
      expect(find.byType(Semantics), findsWidgets);

      // Vérifier que les boutons ont des labels
      final buttons = find.byType(ElevatedButton);
      for (int i = 0; i < buttons.evaluate().length; i++) {
        final button = buttons.at(i);
        final semantics = tester.getSemantics(button);
        expect(semantics.label, isNotNull);
        expect(semantics.label, isNotEmpty);
      }
    });

    testWidgets('Test des contrastes de couleurs', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Vérifier que les textes ont des contrastes suffisants
      final textWidgets = find.byType(Text);
      for (int i = 0; i < textWidgets.evaluate().length; i++) {
        final textWidget = textWidgets.at(i);
        final text = textWidget.widget as Text;

        // Vérifier que le style n'est pas null
        expect(text.style, isNotNull);

        // Vérifier que la couleur n'est pas trop claire
        if (text.style?.color != null) {
          final color = text.style!.color!;
          final luminance = color.computeLuminance();
          expect(luminance, lessThan(0.8)); // Éviter les couleurs trop claires
        }
      }
    });

    testWidgets('Test de la navigation au clavier', (
      WidgetTester tester,
    ) async {
      app.main();
      await tester.pumpAndSettle();

      // Vérifier que les éléments interactifs sont focusables
      final focusableWidgets = find.byType(ElevatedButton);
      for (int i = 0; i < focusableWidgets.evaluate().length; i++) {
        final widget = focusableWidgets.at(i);
        final semantics = tester.getSemantics(widget);
        expect(semantics.hasFlag(SemanticsFlag.isFocusable), isTrue);
      }
    });

    testWidgets('Test des tailles de police', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Vérifier que les textes ont des tailles suffisantes
      final textWidgets = find.byType(Text);
      for (int i = 0; i < textWidgets.evaluate().length; i++) {
        final textWidget = textWidgets.at(i);
        final text = textWidget.widget as Text;

        if (text.style?.fontSize != null) {
          final fontSize = text.style!.fontSize!;
          expect(
            fontSize,
            greaterThanOrEqualTo(12.0),
          ); // Taille minimale recommandée
        }
      }
    });

    testWidgets('Test des indicateurs de focus', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Vérifier que les éléments focusables ont des indicateurs visuels
      final focusableWidgets = find.byType(ElevatedButton);
      for (int i = 0; i < focusableWidgets.evaluate().length; i++) {
        final widget = focusableWidgets.at(i);
        final semantics = tester.getSemantics(widget);
        expect(semantics.hasFlag(SemanticsFlag.isFocusable), isTrue);
      }
    });

    testWidgets('Test des descriptions alternatives', (
      WidgetTester tester,
    ) async {
      app.main();
      await tester.pumpAndSettle();

      // Vérifier que les images ont des descriptions alternatives
      final imageWidgets = find.byType(Image);
      for (int i = 0; i < imageWidgets.evaluate().length; i++) {
        final imageWidget = imageWidgets.at(i);
        final image = imageWidget.widget as Image;

        // Vérifier que l'image a un sémantique label ou un tooltip
        final semantics = tester.getSemantics(imageWidget);
        expect(semantics.label, isNotNull);
        expect(semantics.label, isNotEmpty);
      }
    });
  });
}
