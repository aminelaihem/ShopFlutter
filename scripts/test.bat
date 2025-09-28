@echo off
REM Script de test pour Windows CI/CD
REM Usage: scripts\test.bat

echo 🧪 Démarrage des tests...

REM Installer les dépendances
echo 📦 Installation des dépendances...
flutter pub get

REM Générer les mocks
echo 🔧 Génération des mocks...
flutter packages pub run build_runner build --delete-conflicting-outputs

REM Exécuter les tests unitaires
echo 🔬 Exécution des tests unitaires...
flutter test test/unit/ --coverage

REM Exécuter les tests widget
echo 🎨 Exécution des tests widget...
flutter test test/widget/ --coverage

REM Exécuter les tests d'intégration
echo 🔗 Exécution des tests d'intégration...
flutter test test/integration/ --coverage

REM Exécuter tous les tests avec couverture
echo 📊 Exécution de tous les tests avec couverture...
flutter test --coverage

echo 🎉 Tests terminés avec succès!
