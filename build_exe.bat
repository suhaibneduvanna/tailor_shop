@echo off
title Libasu Thaqva - EXE Installer Builder

echo.
echo ============================================
echo    Libasu Thaqva - EXE Installer Builder
echo ============================================
echo.
echo This will create a traditional Windows EXE installer
echo that works like standard software installers.
echo.

REM Check if Inno Setup is installed
set "INNO_PATH="
if exist "%ProgramFiles(x86)%\Inno Setup 6\ISCC.exe" set "INNO_PATH=%ProgramFiles(x86)%\Inno Setup 6\ISCC.exe"
if exist "%ProgramFiles%\Inno Setup 6\ISCC.exe" set "INNO_PATH=%ProgramFiles%\Inno Setup 6\ISCC.exe"
if exist "%ProgramFiles(x86)%\Inno Setup 5\ISCC.exe" set "INNO_PATH=%ProgramFiles(x86)%\Inno Setup 5\ISCC.exe"
if exist "%ProgramFiles%\Inno Setup 5\ISCC.exe" set "INNO_PATH=%ProgramFiles%\Inno Setup 5\ISCC.exe"

if "%INNO_PATH%"=="" (
    echo.
    echo ERROR: Inno Setup not found!
    echo.
    echo Please install Inno Setup first:
    echo 1. Go to: https://jrsoftware.org/isinfo.php
    echo 2. Download and install Inno Setup
    echo 3. Run this script again
    echo.
    pause
    exit /b 1
)

echo Found Inno Setup: %INNO_PATH%
echo.

REM Step 1: Create icon
echo Step 1: Creating icon file...
if exist "assets\icons\app_icon.png" (
    copy "assets\icons\app_icon.png" "assets\icons\app_icon.ico" >nul 2>&1
    echo ✓ Icon created
) else (
    echo ! Icon not found - installer will use default icon
)

REM Step 2: Build Flutter app
echo.
echo Step 2: Building Flutter app...
echo   Cleaning...
flutter clean
if %errorLevel% neq 0 (
    echo ERROR: Flutter clean failed!
    pause
    exit /b 1
)

echo   Getting dependencies...
flutter pub get
if %errorLevel% neq 0 (
    echo ERROR: Flutter pub get failed!
    pause
    exit /b 1
)

echo   Building Windows release...
flutter build windows --release
if %errorLevel% neq 0 (
    echo ERROR: Flutter build failed!
    pause
    exit /b 1
)

echo ✓ Flutter build completed

REM Step 3: Create installer directory
echo.
echo Step 3: Preparing installer...
if not exist "installer" mkdir "installer"

REM Step 4: Compile installer
echo.
echo Step 4: Creating EXE installer...
"%INNO_PATH%" "installer_script.iss"

if %errorLevel% == 0 (
    echo.
    echo ============================================
    echo   🎉 EXE Installer Created Successfully!
    echo ============================================
    echo.
    echo Output: installer\LibasuThaqva_Setup.exe
    echo.
    echo This installer:
    echo ✓ Works like standard Windows software
    echo ✓ No certificate warnings
    echo ✓ Creates Start Menu shortcuts
    echo ✓ Includes uninstaller
    echo ✓ Supports upgrades
    echo.
    echo Opening installer folder...
    start explorer.exe installer
) else (
    echo.
    echo ============================================
    echo   ❌ Installer Creation Failed
    echo ============================================
    echo.
    echo Please check the installer_script.iss file
    echo for any configuration errors.
)

echo.
pause
