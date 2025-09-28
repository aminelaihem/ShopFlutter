@echo off
REM Script de build pour le web sur Windows
REM Usage: scripts\build-web.bat [--release|--debug]

setlocal enabledelayedexpansion

REM Configuration
set BUILD_MODE=release
set OUTPUT_DIR=build\web

REM Traitement des arguments
if "%1"=="--debug" set BUILD_MODE=debug
if "%1"=="--help" goto :show_help

echo [INFO] Démarrage du build web
echo [INFO] Mode: %BUILD_MODE%
echo [INFO] Répertoire de sortie: %OUTPUT_DIR%

REM Vérification des prérequis
echo [INFO] Vérification des prérequis...
where flutter >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Flutter n'est pas installé ou n'est pas dans le PATH
    exit /b 1
)

REM Nettoyage
echo [INFO] Nettoyage des builds précédents...
if exist "%OUTPUT_DIR%" rmdir /s /q "%OUTPUT_DIR%"
flutter clean

REM Récupération des dépendances
echo [INFO] Récupération des dépendances...
flutter pub get
if %errorlevel% neq 0 (
    echo [ERROR] Échec de la récupération des dépendances
    exit /b 1
)

REM Validation du code
echo [INFO] Validation du code...
flutter format --set-exit-if-changed
if %errorlevel% neq 0 (
    echo [ERROR] Le code n'est pas correctement formaté
    exit /b 1
)

flutter analyze
if %errorlevel% neq 0 (
    echo [ERROR] L'analyse statique a échoué
    exit /b 1
)

REM Tests
echo [INFO] Exécution des tests...
flutter test --coverage
if %errorlevel% neq 0 (
    echo [ERROR] Les tests ont échoué
    exit /b 1
)

REM Build
echo [INFO] Build pour le web en mode %BUILD_MODE%...
if "%BUILD_MODE%"=="release" (
    flutter build web --release --web-renderer html
) else (
    flutter build web --debug
)

if %errorlevel% neq 0 (
    echo [ERROR] Échec du build web
    exit /b 1
)

REM Vérification du build
echo [INFO] Vérification du build...
if not exist "%OUTPUT_DIR%\index.html" (
    echo [ERROR] Le fichier index.html n'existe pas dans le build
    exit /b 1
)

echo [SUCCESS] Build web terminé avec succès !
echo [SUCCESS] Build disponible dans: %OUTPUT_DIR%

if "%BUILD_MODE%"=="release" (
    echo [INFO] Pour tester localement:
    echo [INFO]   cd %OUTPUT_DIR% ^&^& python -m http.server 8000
    echo [INFO]   Puis ouvrez: http://localhost:8000
)

exit /b 0

:show_help
echo Usage: %0 [OPTIONS]
echo.
echo Options:
echo   --release    Build en mode release (défaut)
echo   --debug      Build en mode debug
echo   --help       Afficher cette aide
echo.
echo Exemples:
echo   %0 --release
echo   %0 --debug
exit /b 0
