#!/bin/bash

# Script de test pour CI/CD
# Usage: ./scripts/test.sh

echo "🧪 Démarrage des tests..."

# Installer les dépendances
echo "📦 Installation des dépendances..."
flutter pub get

# Générer les mocks
echo "🔧 Génération des mocks..."
flutter packages pub run build_runner build --delete-conflicting-outputs

# Exécuter les tests unitaires
echo "🔬 Exécution des tests unitaires..."
flutter test test/unit/ --coverage

# Exécuter les tests widget
echo "🎨 Exécution des tests widget..."
flutter test test/widget/ --coverage

# Exécuter les tests d'intégration
echo "🔗 Exécution des tests d'intégration..."
flutter test test/integration/ --coverage

# Exécuter tous les tests avec couverture
echo "📊 Exécution de tous les tests avec couverture..."
flutter test --coverage

# Générer le rapport de couverture
echo "📈 Génération du rapport de couverture..."
if command -v lcov &> /dev/null; then
    genhtml coverage/lcov.info -o coverage/html
    echo "✅ Rapport de couverture généré dans coverage/html/"
else
    echo "⚠️  lcov non installé, rapport HTML non généré"
fi

# Vérifier la couverture minimale (50%)
echo "🎯 Vérification de la couverture minimale..."
if command -v lcov &> /dev/null; then
    COVERAGE=$(lcov --summary coverage/lcov.info | grep "lines" | awk '{print $2}' | sed 's/%//')
    if (( $(echo "$COVERAGE >= 50" | bc -l) )); then
        echo "✅ Couverture de $COVERAGE% - Objectif atteint (≥50%)"
    else
        echo "❌ Couverture de $COVERAGE% - Objectif non atteint (≥50%)"
        exit 1
    fi
else
    echo "⚠️  lcov non installé, vérification de couverture ignorée"
fi

echo "🎉 Tests terminés avec succès!"
