# 🧪 Guide des Tests - ShopFlutter

Ce guide décrit la stratégie de test complète pour l'application ShopFlutter.

## 📋 Types de Tests

### 1. Tests Unitaires (`unit/`)
Tests des fonctions et classes individuelles sans dépendances externes.

```bash
# Exécuter tous les tests unitaires
flutter test test/unit/

# Exécuter un test spécifique
flutter test test/unit/usecases/auth_usecase_test.dart
```

### 2. Tests de Widgets (`widget/`)
Tests des composants UI individuels.

```bash
# Exécuter tous les tests de widgets
flutter test test/widget/

# Exécuter avec couverture
flutter test test/widget/ --coverage
```

### 3. Tests d'Intégration (`integration_test/`)
Tests des flux complets de l'application.

```bash
# Exécuter les tests d'intégration
flutter test integration_test/
```

### 4. Tests de Performance
Tests de performance et de charge.

```bash
# Tests de performance
flutter test test/performance_test.dart
flutter test test/load_test.dart
```

### 5. Tests de Sécurité
Tests de validation et de sécurité.

```bash
# Tests de sécurité
flutter test test/security_test.dart
```

### 6. Tests d'Accessibilité
Tests de conformité aux standards d'accessibilité.

```bash
# Tests d'accessibilité
flutter test test/accessibility_test.dart
```

### 7. Tests Golden Files
Tests de régression visuelle avec captures d'écran.

```bash
# Générer les golden files
flutter test test/golden_test.dart --update-goldens

# Vérifier les golden files
flutter test test/golden_test.dart
```

### 8. Tests Smoke
Tests de base pour vérifier que l'application fonctionne.

```bash
# Tests smoke (rapides)
flutter test test/smoke_test.dart
```

### 9. Tests End-to-End (E2E)
Tests de parcours utilisateur complets.

```bash
# Tests E2E
flutter test test/e2e_test.dart
```

## 🎯 Stratégie de Test

### Pyramide des Tests
```
        /\
       /  \
      / E2E \
     /______\
    /        \
   /Integration\
  /____________\
 /              \
/   Unit Tests   \
/________________\
```

- **70%** Tests unitaires (rapides, fiables)
- **20%** Tests d'intégration (fonctionnalités)
- **10%** Tests E2E (parcours utilisateur)

### Couverture de Code
- **Objectif minimum:** 50%
- **Objectif recommandé:** 80%
- **Objectif idéal:** 90%+

## 🚀 Commandes Utiles

### Exécution des Tests

```bash
# Tous les tests
flutter test

# Tests avec couverture
flutter test --coverage

# Tests spécifiques
flutter test test/unit/
flutter test test/widget/
flutter test test/integration_test.dart

# Tests en mode watch (redémarre à chaque modification)
flutter test --watch
```

### Vérification de la Couverture

```bash
# Windows
scripts\check-coverage.bat --min-coverage=50

# Linux/macOS
./scripts/check-coverage.sh --min-coverage=50
```

### Golden Files

```bash
# Mettre à jour les golden files
flutter test --update-goldens

# Vérifier les golden files
flutter test test/golden_test.dart
```

## 📊 Rapports de Test

### Couverture HTML
```bash
# Générer le rapport HTML
genhtml coverage/lcov.info -o coverage/html

# Ouvrir le rapport
open coverage/html/index.html  # macOS
start coverage/html/index.html # Windows
```

### Rapports CI/CD
Les rapports sont automatiquement générés dans GitHub Actions :
- Couverture de code
- Résultats des tests
- Performance
- Golden files

## 🛠️ Configuration des Tests

### Fichiers de Configuration
- `pubspec.yaml` - Dépendances de test
- `test/test_runner.dart` - Runner personnalisé
- `coverage/lcov.info` - Rapport de couverture

### Mocks et Stubs
```dart
// Exemple de mock avec Mockito
@GenerateMocks([AuthRepository])
void main() {
  late MockAuthRepository mockAuthRepository;
  
  setUp(() {
    mockAuthRepository = MockAuthRepository();
  });
  
  test('should authenticate user', () async {
    // Arrange
    when(mockAuthRepository.signIn(any, any))
        .thenAnswer((_) async => Right(user));
    
    // Act & Assert
    // ...
  });
}
```

## 🔧 Debugging des Tests

### Logs de Debug
```dart
test('my test', () {
  debugPrint('Debug message');
  print('Console message');
  // ...
});
```

### Tests avec Breakpoints
```bash
# Exécuter en mode debug
flutter test --debug test/my_test.dart
```

### Tests Flaky
Pour les tests instables :
```bash
# Exécuter plusieurs fois
flutter test --repeat=10 test/flaky_test.dart
```

## 📝 Bonnes Pratiques

### 1. Structure des Tests
```dart
group('FeatureName', () {
  setUp(() {
    // Configuration commune
  });
  
  tearDown(() {
    // Nettoyage
  });
  
  test('should do something when condition', () {
    // Arrange
    // Act
    // Assert
  });
});
```

### 2. Nommage des Tests
- Utiliser des descriptions claires
- Format: "should [expected behavior] when [condition]"
- Exemple: `should return user when credentials are valid`

### 3. Tests Indépendants
- Chaque test doit être indépendant
- Pas de dépendances entre tests
- Utiliser `setUp()` et `tearDown()`

### 4. Mocks et Stubs
- Mocker les dépendances externes
- Utiliser Mockito pour les mocks
- Vérifier les interactions importantes

### 5. Tests de Performance
- Mesurer les temps critiques
- Définir des seuils acceptables
- Tester sur différentes configurations

## 🐛 Dépannage

### Tests qui Échouent
1. Vérifier les logs d'erreur
2. Exécuter en mode debug
3. Vérifier les mocks et stubs
4. Valider les données de test

### Couverture Insuffisante
1. Identifier les fichiers non couverts
2. Ajouter des tests unitaires
3. Exclure les fichiers générés
4. Vérifier la configuration

### Tests Lents
1. Identifier les tests lents
2. Optimiser les mocks
3. Réduire les `pumpAndSettle()`
4. Paralléliser si possible

## 📚 Ressources

- [Testing Flutter apps](https://docs.flutter.dev/testing)
- [Mockito](https://pub.dev/packages/mockito)
- [Integration testing](https://docs.flutter.dev/testing/integration-tests)
- [Golden file testing](https://github.com/flutter/flutter/wiki/Writing-a-golden-file-test-for-package:flutter)

---

**Tests bien écrits = Code de qualité ! 🚀**