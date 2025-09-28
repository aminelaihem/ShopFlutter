@echo off
REM Script de vérification de la couverture de code sur Windows
REM Usage: scripts\check-coverage.bat [--min-coverage=50]

setlocal enabledelayedexpansion

REM Configuration par défaut
set MIN_COVERAGE=50
set COVERAGE_FILE=coverage\lcov.info

REM Traitement des arguments
for %%i in (%*) do (
    if "%%i"=="--help" goto :show_help
    if "%%i"=="--min-coverage=50" set MIN_COVERAGE=50
    if "%%i"=="--min-coverage=60" set MIN_COVERAGE=60
    if "%%i"=="--min-coverage=70" set MIN_COVERAGE=70
    if "%%i"=="--min-coverage=80" set MIN_COVERAGE=80
)

echo [INFO] Vérification de la couverture de code
echo [INFO] Couverture minimale requise: %MIN_COVERAGE%%
echo [INFO] Fichier de couverture: %COVERAGE_FILE%

REM Vérification des prérequis
echo [INFO] Vérification des prérequis...

REM Vérifier que le fichier de couverture existe
if not exist "%COVERAGE_FILE%" (
    echo [ERROR] Le fichier de couverture %COVERAGE_FILE% n'existe pas
    echo [ERROR] Exécutez d'abord: flutter test --coverage
    exit /b 1
)

REM Vérifier que lcov est disponible (via WSL ou Git Bash)
where lcov >nul 2>&1
if %errorlevel% neq 0 (
    echo [WARNING] lcov n'est pas disponible dans le PATH
    echo [INFO] Tentative d'utilisation de WSL...
    
    REM Essayer avec WSL
    wsl lcov --version >nul 2>&1
    if %errorlevel% neq 0 (
        echo [ERROR] lcov n'est pas disponible. Installez-le via WSL ou Git Bash
        echo [INFO] Sur WSL: sudo apt-get install lcov
        exit /b 1
    )
    
    set LCOV_CMD=wsl lcov
) else (
    set LCOV_CMD=lcov
)

REM Analyser la couverture
echo [INFO] Analyse de la couverture de code...

REM Générer le rapport de couverture
%LCOV_CMD% --summary "%COVERAGE_FILE%" > coverage_summary.txt 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Impossible d'analyser le fichier de couverture
    exit /b 1
)

REM Extraire le pourcentage de couverture
for /f "tokens=*" %%i in ('%LCOV_CMD% --summary "%COVERAGE_FILE%" 2^>nul ^| findstr /r "[0-9][0-9]*\.[0-9][0-9]*%%"') do (
    set COVERAGE_LINE=%%i
)

REM Extraire le pourcentage (simplifié pour Windows)
for /f "tokens=2 delims= " %%a in ("!COVERAGE_LINE!") do (
    set COVERAGE_PERCENT=%%a
)

REM Nettoyer le pourcentage
set COVERAGE_PERCENT=%COVERAGE_PERCENT:%%=%

echo.
echo [INFO] Rapport de couverture de code:
echo ==================================
type coverage_summary.txt
echo.

REM Vérifier si la couverture est suffisante
if %COVERAGE_PERCENT% geq %MIN_COVERAGE% (
    echo [SUCCESS] Couverture de code: %COVERAGE_PERCENT%%% (^>= %MIN_COVERAGE%%%)
    echo [SUCCESS] La couverture de code est suffisante !
    del coverage_summary.txt 2>nul
    exit /b 0
) else (
    echo [ERROR] Couverture de code: %COVERAGE_PERCENT%%% (^< %MIN_COVERAGE%%%)
    echo [ERROR] La couverture de code est insuffisante !
    del coverage_summary.txt 2>nul
    exit /b 1
)

:show_help
echo Usage: %0 [OPTIONS]
echo.
echo Options:
echo   --min-coverage=N    Couverture minimale requise (défaut: 50)
echo   --help              Afficher cette aide
echo.
echo Exemples:
echo   %0 --min-coverage=60
echo   %0 --min-coverage=80
exit /b 0
