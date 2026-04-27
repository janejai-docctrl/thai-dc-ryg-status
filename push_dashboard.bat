@echo off
title MIR Dashboard - Auto Push GitHub

set REPO_DIR=D:\THAI_DC_RYG\00_Project_Info\thai-dc-status
set TOKEN_FILE=%REPO_DIR%\token.txt
set GH_USER=janejai-docctrl
set GH_REPO=thai-dc-ryg-status
set BRANCH=main

echo.
echo === MIR Dashboard Auto Push - THAI DC 1-RYG ===
echo.

:: Read token from file
if not exist "%TOKEN_FILE%" (
    echo ERROR: token.txt not found at %TOKEN_FILE%
    echo Please create token.txt with your GitHub token inside
    pause
    exit /b 1
)
set /p GH_TOKEN=<"%TOKEN_FILE%"
if "%GH_TOKEN%"=="" (
    echo ERROR: token.txt is empty
    pause
    exit /b 1
)
echo [OK] Token loaded

echo [1/5] Checking folder...
if not exist "%REPO_DIR%\" (
    echo Cloning from GitHub...
    cd /d "D:\THAI_DC_RYG\00_Project_Info"
    git clone https://%GH_TOKEN%@github.com/%GH_USER%/%GH_REPO%.git thai-dc-status
    if %ERRORLEVEL% neq 0 (
        echo ERROR: Clone failed.
        pause
        exit /b 1
    )
)
echo [OK] Folder found

echo.
echo [2/5] Entering repo folder...
cd /d "%REPO_DIR%"
echo [OK] %CD%

echo.
echo [3/5] Setting git remote...
git remote set-url origin https://%GH_TOKEN%@github.com/%GH_USER%/%GH_REPO%.git
git config user.email "janejai@doccontrol.th"
git config user.name "Janejai Seesom"
echo [OK] Remote ready

echo.
echo [4/5] Cleanup and status...
git rebase --abort 2>nul
git merge --abort 2>nul
git fetch origin %BRANCH%
git reset --hard origin/%BRANCH%
git status --short

echo.
echo [5/5] Pushing to GitHub...

set TODAY=%date:~0,2%-%date:~3,2%-%date:~6,4%
set NOW=%time:~0,2%:%time:~3,2%
set MSG=Update dashboard %TODAY% %NOW%

git add -A

git diff --cached --quiet
if %ERRORLEVEL% equ 0 (
    echo WARNING: No changes. Nothing to push.
    pause
    exit /b 0
)

git commit -m "%MSG%"
git push origin %BRANCH%
if %ERRORLEVEL% neq 0 (
    echo ERROR: Push failed.
    pause
    exit /b 1
)

echo.
echo ================================================
echo  SUCCESS - Dashboard pushed!
echo  https://janejai-docctrl.github.io/thai-dc-ryg-status/
echo  Wait 2-3 min then Ctrl+Shift+R
echo ================================================
echo.
pause
