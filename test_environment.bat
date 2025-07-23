@echo off
title Flutter Environment Test
color 0A

echo Testing Flutter environment...
echo.

echo 1. Checking current directory:
echo %CD%
echo.

echo 2. Checking if pubspec.yaml exists:
if exist "pubspec.yaml" (
    echo ✓ pubspec.yaml found
) else (
    echo ✗ pubspec.yaml NOT found - you may be in wrong directory
)
echo.

echo 3. Checking Flutter installation:
where flutter >nul 2>&1
if %errorlevel% equ 0 (
    echo ✓ Flutter found in PATH
    flutter --version
) else (
    echo ✗ Flutter NOT found in PATH
)
echo.

echo 4. Checking app icon:
if exist "assets\icons\app_icon.png" (
    echo ✓ App icon found: assets\icons\app_icon.png
) else (
    echo ✗ App icon NOT found at assets\icons\app_icon.png
)
echo.

echo 5. Testing a simple Flutter command:
echo Running: flutter pub get
flutter pub get
echo Exit code: %errorlevel%
echo.

echo 6. Checking Windows build capability:
echo Running: flutter doctor
flutter doctor
echo.

echo Test completed. 
echo If you see any ✗ marks above, those need to be fixed first.
echo.
echo Press any key to close...
pause >nul
