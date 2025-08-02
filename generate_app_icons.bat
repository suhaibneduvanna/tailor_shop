@echo off
echo Generating app icons for all platforms...
echo.

echo Step 1: Getting dependencies...
flutter pub get

echo.
echo Step 2: Generating launcher icons...
dart run flutter_launcher_icons

echo.
echo App icons generated successfully!
echo Your new icons are now applied to:
echo - Android
echo - iOS  
echo - Web
echo - Windows
echo - macOS

echo.
echo To see the changes:
echo 1. Run your app on any platform
echo 2. For Windows installer, build with: flutter build windows --release
echo.
pause
