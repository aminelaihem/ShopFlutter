@echo off
REM Script principal de déploiement pour Windows
REM Usage: scripts\deploy.bat [--env=staging|production] [--dry-run]

setlocal enabledelayedexpansion

REM Configuration
set ENVIRONMENT=production
set DRY_RUN=false
set FIREBASE_PROJECT_ID=shopflutter-d3308

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
echo [INFO] Déploiement ShopFlutter
echo [INFO] ==============================================
echo [INFO] Environnement: %ENVIRONMENT%
echo [INFO] Projet Firebase: %FIREBASE_PROJECT_ID%
if "%DRY_RUN%"=="true" echo [INFO] Mode dry-run activé
echo [INFO] ==============================================

REM Vérification des prérequis
echo [INFO] Vérification des prérequis...
where flutter >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Flutter n'est pas installé
    exit /b 1
)

where firebase >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Firebase CLI n'est pas installé
    echo [INFO] Installez-le avec: npm install -g firebase-tools
    exit /b 1
)

REM Vérification de la connexion Firebase
firebase projects:list >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Vous n'êtes pas connecté à Firebase
    echo [INFO] Connectez-vous avec: firebase login
    exit /b 1
)

echo [SUCCESS] Prérequis vérifiés

REM Étape 1: Tests et validation
echo [INFO] Étape 1/5: Tests et validation
call scripts\build-web.bat --release
if %errorlevel% neq 0 (
    echo [ERROR] Build échoué
    exit /b 1
)

REM Étape 2: Vérification de la couverture
echo [INFO] Étape 2/5: Vérification de la couverture
call scripts\check-coverage.bat --min-coverage=50
if %errorlevel% neq 0 (
    echo [ERROR] Couverture insuffisante
    exit /b 1
)

REM Étape 3: Configuration Firebase
echo [INFO] Étape 3/5: Configuration Firebase
firebase use %FIREBASE_PROJECT_ID%
if %errorlevel% neq 0 (
    echo [ERROR] Impossible de sélectionner le projet Firebase
    exit /b 1
)

REM Étape 4: Déploiement
echo [INFO] Étape 4/5: Déploiement
if "%DRY_RUN%"=="true" (
    echo [INFO] DRY RUN: Déploiement simulé
    echo [INFO] Commande qui serait exécutée: firebase deploy --only hosting
) else (
    if "%ENVIRONMENT%"=="staging" (
        REM Déploiement sur canal preview
        firebase hosting:channel:deploy preview --expires 7d
    ) else (
        REM Déploiement en production
        firebase deploy --only hosting
    )
    
    if %errorlevel% neq 0 (
        echo [ERROR] Déploiement échoué
        exit /b 1
    )
)

REM Étape 5: Vérification post-déploiement
echo [INFO] Étape 5/5: Vérification post-déploiement
if "%DRY_RUN%"=="false" (
    if "%ENVIRONMENT%"=="production" (
        set APP_URL=https://%FIREBASE_PROJECT_ID%.web.app
    ) else (
        set APP_URL=https://%FIREBASE_PROJECT_ID%--preview.web.app
    )
    
    echo [INFO] Vérification de l'URL: !APP_URL!
    
    REM Vérification avec curl si disponible
    where curl >nul 2>&1
    if %errorlevel% equ 0 (
        curl -s -o nul -w "%%{http_code}" "!APP_URL!" | findstr "200" >nul
        if %errorlevel% equ 0 (
            echo [SUCCESS] Application accessible
        ) else (
            echo [WARNING] Application pourrait ne pas être accessible
        )
    )
)

echo [SUCCESS] ==============================================
echo [SUCCESS] Déploiement terminé avec succès !
echo [SUCCESS] ==============================================
if "%DRY_RUN%"=="false" (
    echo [SUCCESS] URL de l'application: !APP_URL!
    echo [SUCCESS] Console Firebase: https://console.firebase.google.com/project/%FIREBASE_PROJECT_ID%
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
exit /b 0
