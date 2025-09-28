@echo off
REM Script de déploiement Vercel pour Windows
REM Usage: scripts\deploy-vercel.bat [--env=staging|production] [--dry-run]

setlocal enabledelayedexpansion

REM Configuration
set ENVIRONMENT=production
set DRY_RUN=false

REM Traitement des arguments
:parse_args
if "%1"=="" goto :start_deploy
if "%1"=="--env=staging" set ENVIRONMENT=staging
if "%1"=="--env=production" set ENVIRONMENT=production
if "%1"=="--dry-run" set DRY_RUN=true
if "%1"=="--help" goto :show_help
shift
goto :parse_args

:start_deploy
echo [INFO] ==============================================
echo [INFO] Déploiement ShopFlutter sur Vercel
echo [INFO] ==============================================
echo [INFO] Environnement: %ENVIRONMENT%
if "%DRY_RUN%"=="true" echo [INFO] Mode dry-run activé
echo [INFO] ==============================================

REM Vérification des prérequis
echo [INFO] Vérification des prérequis...
where flutter >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Flutter n'est pas installé
    exit /b 1
)

where node >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Node.js n'est pas installé
    echo [INFO] Installez-le depuis: https://nodejs.org
    exit /b 1
)

where vercel >nul 2>&1
if %errorlevel% neq 0 (
    echo [INFO] Installation de Vercel CLI...
    npm install -g vercel@latest
    if %errorlevel% neq 0 (
        echo [ERROR] Échec de l'installation de Vercel CLI
        exit /b 1
    )
)

echo [SUCCESS] Prérequis vérifiés

REM Étape 1: Tests et validation
echo [INFO] Étape 1/4: Tests et validation
call scripts\build-web.bat --release
if %errorlevel% neq 0 (
    echo [ERROR] Build échoué
    exit /b 1
)

REM Étape 2: Vérification de la couverture
echo [INFO] Étape 2/4: Vérification de la couverture
call scripts\check-coverage.bat --min-coverage=50
if %errorlevel% neq 0 (
    echo [ERROR] Couverture insuffisante
    exit /b 1
)

REM Étape 3: Configuration Vercel
echo [INFO] Étape 3/4: Configuration Vercel
if "%DRY_RUN%"=="true" (
    echo [INFO] DRY RUN: Configuration Vercel simulée
) else (
    vercel --yes
    if %errorlevel% neq 0 (
        echo [ERROR] Configuration Vercel échouée
        echo [INFO] Assurez-vous d'être connecté: vercel login
        exit /b 1
    )
)

REM Étape 4: Déploiement
echo [INFO] Étape 4/4: Déploiement
if "%DRY_RUN%"=="true" (
    echo [INFO] DRY RUN: Déploiement simulé
    if "%ENVIRONMENT%"=="staging" (
        echo [INFO] Commande qui serait exécutée: vercel
    ) else (
        echo [INFO] Commande qui serait exécutée: vercel --prod
    )
) else (
    if "%ENVIRONMENT%"=="staging" (
        vercel
        echo [INFO] Déploiement en preview terminé
    ) else (
        vercel --prod
        echo [INFO] Déploiement en production terminé
    )
    
    if %errorlevel% neq 0 (
        echo [ERROR] Déploiement échoué
        exit /b 1
    )
)

echo [SUCCESS] ==============================================
echo [SUCCESS] Déploiement Vercel terminé avec succès !
echo [SUCCESS] ==============================================
if "%DRY_RUN%"=="false" (
    echo [SUCCESS] URL de l'application: https://shopflutter.vercel.app
    echo [SUCCESS] Dashboard Vercel: https://vercel.com/dashboard
)
echo [SUCCESS] ==============================================

exit /b 0

:show_help
echo Usage: %0 [OPTIONS]
echo.
echo Options:
echo   --env=staging       Déployer sur l'environnement de staging
echo   --env=production    Déployer sur l'environnement de production (défaut)
echo   --dry-run           Mode simulation (aucun déploiement réel)
echo   --help              Afficher cette aide
echo.
echo Exemples:
echo   %0                          # Déploiement en production
echo   %0 --env=staging           # Déploiement en staging
echo   %0 --dry-run               # Simulation
echo   %0 --env=staging --dry-run # Simulation staging
echo.
echo Prérequis:
echo   - Flutter installé
echo   - Node.js installé
echo   - Vercel CLI installé (automatique)
echo   - Connexion Vercel (vercel login)
exit /b 0
