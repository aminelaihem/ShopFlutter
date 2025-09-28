@echo off
REM Script de validation complète pour Windows
REM Usage: scripts\validate.bat [--fix] [--coverage=50]

setlocal enabledelayedexpansion

REM Configuration
set FIX_ISSUES=false
set MIN_COVERAGE=50
set EXIT_CODE=0

REM Traitement des arguments
:parse_args
if "%1"=="" goto :start_validation
if "%1"=="--fix" set FIX_ISSUES=true
if "%1"=="--coverage=50" set MIN_COVERAGE=50
if "%1"=="--coverage=60" set MIN_COVERAGE=60
if "%1"=="--coverage=70" set MIN_COVERAGE=70
if "%1"=="--coverage=80" set MIN_COVERAGE=80
if "%1"=="--help" goto :show_help
shift
goto :parse_args

:start_validation
echo [INFO] ==============================================
echo [INFO] Validation complète du projet ShopFlutter
echo [INFO] ==============================================
if "%FIX_ISSUES%"=="true" echo [INFO] Mode correction automatique activé
echo [INFO] Couverture minimale requise: %MIN_COVERAGE%%
echo [INFO] ==============================================

REM Vérification des prérequis
echo [INFO] Étape 1/8: Vérification des prérequis
where flutter >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Flutter n'est pas installé
    set EXIT_CODE=1
    goto :end
)

where dart >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Dart n'est pas installé
    set EXIT_CODE=1
    goto :end
)

echo [SUCCESS] Prérequis vérifiés

REM Nettoyage
echo [INFO] Étape 2/8: Nettoyage
flutter clean
flutter pub get
if %errorlevel% neq 0 (
    echo [ERROR] Échec de la récupération des dépendances
    set EXIT_CODE=1
    goto :end
)

echo [SUCCESS] Dépendances récupérées

REM Vérification du formatage
echo [INFO] Étape 3/8: Vérification du formatage
if "%FIX_ISSUES%"=="true" (
    flutter format .
    echo [INFO] Code reformaté automatiquement
) else (
    flutter format --set-exit-if-changed
    if %errorlevel% neq 0 (
        echo [ERROR] Le code n'est pas correctement formaté
        echo [INFO] Exécutez avec --fix pour corriger automatiquement
        set EXIT_CODE=1
    )
)

REM Analyse statique
echo [INFO] Étape 4/8: Analyse statique
flutter analyze
if %errorlevel% neq 0 (
    echo [ERROR] L'analyse statique a détecté des problèmes
    set EXIT_CODE=1
) else (
    echo [SUCCESS] Analyse statique réussie
)

REM Tests unitaires
echo [INFO] Étape 5/8: Tests unitaires
flutter test test/unit/
if %errorlevel% neq 0 (
    echo [ERROR] Les tests unitaires ont échoué
    set EXIT_CODE=1
) else (
    echo [SUCCESS] Tests unitaires réussis
)

REM Tests de widgets
echo [INFO] Étape 6/8: Tests de widgets
flutter test test/widget/
if %errorlevel% neq 0 (
    echo [ERROR] Les tests de widgets ont échoué
    set EXIT_CODE=1
) else (
    echo [SUCCESS] Tests de widgets réussis
)

REM Tests avec couverture
echo [INFO] Étape 7/8: Tests avec couverture
flutter test --coverage
if %errorlevel% neq 0 (
    echo [ERROR] Les tests ont échoué
    set EXIT_CODE=1
    goto :end
)

REM Vérification de la couverture
call scripts\check-coverage.bat --min-coverage=%MIN_COVERAGE%
if %errorlevel% neq 0 (
    echo [ERROR] Couverture de code insuffisante
    set EXIT_CODE=1
) else (
    echo [SUCCESS] Couverture de code suffisante
)

REM Tests de smoke
echo [INFO] Étape 8/8: Tests de smoke
flutter test test/smoke_test.dart
if %errorlevel% neq 0 (
    echo [ERROR] Les tests de smoke ont échoué
    set EXIT_CODE=1
) else (
    echo [SUCCESS] Tests de smoke réussis
)

REM Build de test
echo [INFO] Test de build web
flutter build web --release
if %errorlevel% neq 0 (
    echo [ERROR] Le build web a échoué
    set EXIT_CODE=1
) else (
    echo [SUCCESS] Build web réussi
)

:end
echo [INFO] ==============================================
if %EXIT_CODE% equ 0 (
    echo [SUCCESS] ✅ Validation complète réussie !
    echo [SUCCESS] Le projet est prêt pour le déploiement
) else (
    echo [ERROR] ❌ Validation échouée
    echo [ERROR] Corrigez les erreurs avant le déploiement
)
echo [INFO] ==============================================

exit /b %EXIT_CODE%

:show_help
echo Usage: %0 [OPTIONS]
echo.
echo Options:
echo   --fix               Corriger automatiquement les problèmes de formatage
echo   --coverage=N        Couverture minimale requise (défaut: 50)
echo   --help              Afficher cette aide
echo.
echo Exemples:
echo   %0                     # Validation standard
echo   %0 --fix              # Validation avec correction automatique
echo   %0 --coverage=80      # Validation avec couverture 80%%
echo   %0 --fix --coverage=70 # Validation complète avec corrections
exit /b 0
