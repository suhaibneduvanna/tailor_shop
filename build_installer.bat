@echo off
title Tailor Shop Management - Installer Builder
color 0A

echo.
echo ===============================================
echo   Tailor Shop Management - Installer Builder
echo ===============================================
echo.

echo [1/4] Checking prerequisites...
where flutter >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Flutter not found. Please install Flutter and add it to PATH.
    echo Press any key to exit...
    pause >nul
    exit /b 1
)
echo OK: Flutter found

echo.
echo [2/4] Building Flutter application...
echo.
flutter clean
call flutter pub get
call flutter build windows --release

if %errorlevel% neq 0 (
    echo.
    echo ERROR: Flutter build failed!
    echo Check the error messages above for details.
    echo Press any key to exit...
    pause >nul
    exit /b 1
)

echo.
echo [3/4] Creating MSIX installer...
echo.

REM Check for app icon
if not exist "assets\icons\app_icon.png" (
    echo WARNING: App icon not found at assets\icons\app_icon.png
    echo You can continue, but please add a proper icon later.
    echo.
)

call dart run msix:create

if %errorlevel% neq 0 (
    echo.
    echo ERROR: MSIX creation failed!
    echo Please check that you have the Windows SDK installed.
    echo Check the error messages above for details.
    echo Press any key to exit...
    pause >nul
    exit /b 1
)

echo.
echo [4/4] Build completed successfully!
echo.
echo Your installer is ready:
echo - MSIX Installer: build\windows\x64\runner\Release\
echo - Standalone App: build\windows\x64\runner\Release\tailor_shop.exe
echo.
echo Next steps:
echo 1. Test the application
echo 2. Add proper app icons (see INSTALLER_GUIDE.md)
echo 3. Update publisher information in pubspec.yaml
echo.
echo Press any key to exit...
pause >nul
