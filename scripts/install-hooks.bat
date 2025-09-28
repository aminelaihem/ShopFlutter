@echo off
REM Script d'installation des hooks Git pour Windows
REM Usage: scripts\install-hooks.bat

echo [INFO] Installation des hooks Git...

REM Vérifier que nous sommes dans un repository Git
if not exist ".git" (
    echo [ERROR] Ce n'est pas un repository Git
    exit /b 1
)

REM Créer le répertoire des hooks s'il n'existe pas
if not exist ".git\hooks" mkdir ".git\hooks"

REM Copier les hooks
echo [INFO] Installation du hook pre-commit...
copy ".githooks\pre-commit" ".git\hooks\pre-commit" >nul
if %errorlevel% neq 0 (
    echo [ERROR] Échec de l'installation du hook pre-commit
    exit /b 1
)

echo [INFO] Installation du hook pre-push...
copy ".githooks\pre-push" ".git\hooks\pre-push" >nul
if %errorlevel% neq 0 (
    echo [ERROR] Échec de l'installation du hook pre-push
    exit /b 1
)

REM Sur Windows, les hooks doivent être des fichiers .bat ou avoir l'extension appropriée
REM Créer des wrappers batch pour les hooks bash
echo [INFO] Création des wrappers Windows...

REM Wrapper pour pre-commit
echo @echo off > ".git\hooks\pre-commit.bat"
echo bash .git/hooks/pre-commit >> ".git\hooks\pre-commit.bat"

REM Wrapper pour pre-push
echo @echo off > ".git\hooks\pre-push.bat"
echo bash .git/hooks/pre-push >> ".git\hooks\pre-push.bat"

echo [SUCCESS] Hooks Git installés avec succès !
echo [INFO] Les hooks suivants sont maintenant actifs:
echo [INFO]   - pre-commit: Validation avant chaque commit
echo [INFO]   - pre-push: Validation complète avant chaque push
echo [INFO]
echo [INFO] Pour désactiver temporairement un hook:
echo [INFO]   git commit --no-verify
echo [INFO]   git push --no-verify

exit /b 0
