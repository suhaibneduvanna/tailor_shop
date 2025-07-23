@echo off
title Tailor Shop Management - Debug Installer Builder
color 0F

echo.
echo ===============================================
echo   Tailor Shop Management - DEBUG BUILD
echo ===============================================
echo.

REM Enable command echoing for debugging
echo on

echo.
echo [DEBUG] Current directory: %CD%
echo [DEBUG] Checking Flutter installation...
where flutter
if %errorlevel% neq 0 (
    echo [ERROR] Flutter not found in PATH
    goto :error_exit
)

echo.
echo [DEBUG] Flutter version:
flutter --version

echo.
echo [DEBUG] Checking for pubspec.yaml...
if not exist "pubspec.yaml" (
    echo [ERROR] pubspec.yaml not found. Are you in the correct directory?
    goto :error_exit
)

echo.
echo [DEBUG] Checking for app icon...
if exist "assets\icons\app_icon.png" (
    echo [OK] App icon found: assets\icons\app_icon.png
) else (
    echo [WARNING] App icon not found at assets\icons\app_icon.png
)

echo.
echo [DEBUG] Cleaning previous build...
flutter clean

echo.
echo [DEBUG] Getting dependencies...
flutter pub get
if %errorlevel% neq 0 (
    echo [ERROR] Failed to get dependencies
    goto :error_exit
)

echo.
echo [DEBUG] Building Windows release...
flutter build windows --release
if %errorlevel% neq 0 (
    echo [ERROR] Flutter build failed
    goto :error_exit
)

echo.
echo [DEBUG] Checking if MSIX package is available...
flutter pub deps | findstr msix
if %errorlevel% neq 0 (
    echo [ERROR] MSIX package not found in dependencies
    goto :error_exit
)

echo.
echo [DEBUG] Creating MSIX installer...
dart run msix:create
if %errorlevel% neq 0 (
    echo [ERROR] MSIX creation failed
    goto :error_exit
)

echo.
echo [SUCCESS] Build completed successfully!
echo.
dir "build\windows\x64\runner\Release\" /B
echo.
goto :normal_exit

:error_exit
@echo off
echo.
echo ========================================
echo BUILD FAILED - CHECK ERRORS ABOVE
echo ========================================
echo.
echo Common solutions:
echo 1. Make sure you're in the project root directory
echo 2. Check that Flutter is properly installed
echo 3. Ensure Windows development is set up (flutter doctor)
echo 4. Verify that Visual Studio with C++ workload is installed
echo.
echo Press any key to exit...
pause >nul
exit /b 1

:normal_exit
@echo off
echo.
echo Press any key to exit...
pause >nul
exit /b 0
