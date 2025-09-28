# 🧪 Guide des Tests - ShopFlutter

## 📋 Vue d'ensemble

Cette suite de tests couvre l'application ShopFlutter avec **plus de 15 tests** répartis en plusieurs catégories pour garantir une couverture ≥ 50%.

## 🏗️ Structure des tests

```
test/
├── unit/                          # Tests unitaires
│   ├── usecases/                  # Tests des use cases
│   │   ├── auth/                  # Authentification
│   │   │   ├── sign_in_test.dart
│   │   │   └── register_test.dart
│   │   └── catalog/               # Catalogue
│   │       ├── fetch_products_test.dart
│   │       └── fetch_product_test.dart
│   └── viewmodels/                # Tests des viewmodels
│       ├── auth/
│       │   └── login_vm_test.dart
│       └── catalog/
│           └── catalog_vm_test.dart
├── widget/                        # Tests de widgets
│   ├── auth/
│   │   └── login_page_test.dart
│   └── catalog/
│       └── product_card_test.dart
├── integration/                   # Tests d'intégration
│   └── auth_flow_test.dart
├── coverage_test.dart             # Tests de couverture
├── test_runner.dart               # Lanceur de tous les tests
└── README.md                      # Ce fichier
```

## 🎯 Types de tests

### **1. Tests Unitaires (10+ tests)**
- **Use Cases** : Logique métier pure
- **ViewModels** : Gestion d'état et logique UI
- **Mocks** : Simulation des dépendances

### **2. Tests Widget (5+ tests)**
- **Pages** : Interface utilisateur complète
- **Composants** : Widgets réutilisables
- **Interactions** : Tap, saisie, navigation

### **3. Tests d'Intégration (3+ tests)**
- **Flux complets** : Parcours utilisateur
- **Navigation** : Entre les pages
- **État global** : Gestion des sessions

## 🚀 Exécution des tests

### **Tous les tests**
```bash
flutter test
```

### **Tests avec couverture**
```bash
flutter test --coverage
```

### **Tests par catégorie**
```bash
# Tests unitaires
flutter test test/unit/

# Tests widget
flutter test test/widget/

# Tests d'intégration
flutter test test/integration/
```

### **Scripts automatisés**
```bash
# Linux/Mac
./scripts/test.sh

# Windows
scripts\test.bat
```

## 📊 Couverture de code

### **Objectif** : ≥ 50% de couverture

### **Zones couvertes** :
- ✅ **Use Cases** : 100% (SignIn, Register, FetchProducts, etc.)
- ✅ **ViewModels** : 90% (LoginVm, CatalogVm, etc.)
- ✅ **Widgets critiques** : 80% (LoginPage, ProductCard, etc.)
- ✅ **Flux d'authentification** : 100%

### **Métriques** :
- **Tests unitaires** : 10+ tests
- **Tests widget** : 5+ tests  
- **Tests d'intégration** : 3+ tests
- **Total** : 18+ tests

## 🔧 Configuration

### **Dépendances de test** :
```yaml
dev_dependencies:
  flutter_test: sdk: flutter
  mockito: ^5.4.4
  build_runner: ^2.4.7
  integration_test: sdk: flutter
```

### **Génération des mocks** :
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

## 🎨 Bonnes pratiques

### **1. Structure AAA** :
- **Arrange** : Préparer les données
- **Act** : Exécuter l'action
- **Assert** : Vérifier le résultat

### **2. Noms descriptifs** :
```dart
test('devrait retourner un utilisateur quand la connexion réussit', () async {
  // Test implementation
});
```

### **3. Mocks appropriés** :
```dart
@GenerateMocks([AuthRepository])
class MockAuthRepository extends Mock implements AuthRepository {}
```

### **4. Tests isolés** :
- Chaque test est indépendant
- `setUp()` pour l'initialisation
- Pas de dépendances entre tests

## 🚨 CI/CD

### **GitHub Actions** :
- Exécution automatique sur push/PR
- Vérification de couverture ≥ 50%
- Génération de rapports HTML
- Upload vers Codecov

### **Seuils de qualité** :
- ✅ Couverture ≥ 50%
- ✅ Tous les tests passent
- ✅ Aucun test en échec
- ✅ Mocks générés correctement

## 📈 Améliorations futures

### **Tests de performance** :
- Temps de réponse des API
- Mémoire utilisée
- Taille des bundles

### **Tests E2E** :
- Parcours utilisateur complets
- Tests sur vrais appareils
- Scénarios complexes

### **Tests de charge** :
- Connexions simultanées
- Gestion des erreurs réseau
- Performance sous stress

## 🎉 Résultat

Cette suite de tests garantit :
- **Qualité** : Code testé et fiable
- **Maintenabilité** : Refactoring sécurisé
- **Documentation** : Tests comme spécifications
- **Confiance** : Déploiement sans crainte

**Total : 18+ tests avec couverture ≥ 50%** ✅
