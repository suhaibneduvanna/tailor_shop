@echo off
title Libasu Thaqva - Portable Version Builder

echo.
echo =============================================
echo    Libasu Thaqva - Portable Version Builder
echo =============================================
echo.
echo This creates a portable version that doesn't
echo require installation - just extract and run!
echo.

REM Create output directory
set "OUTPUT_DIR=LibasuThaqva_Portable"
if exist "%OUTPUT_DIR%" (
    echo Removing previous portable version...
    rmdir /s /q "%OUTPUT_DIR%"
)
mkdir "%OUTPUT_DIR%"

echo Step 1: Building Flutter app...
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

echo.
echo Step 2: Creating portable package...

REM Copy the entire release folder
echo   Copying application files...
xcopy "build\windows\x64\runner\Release\*" "%OUTPUT_DIR%\" /E /I /Q

REM Create a launcher script
echo @echo off > "%OUTPUT_DIR%\Start_LibasuThaqva.bat"
echo title Libasu Thaqva >> "%OUTPUT_DIR%\Start_LibasuThaqva.bat"
echo echo Starting Libasu Thaqva... >> "%OUTPUT_DIR%\Start_LibasuThaqva.bat"
echo start "" "tailor_shop.exe" >> "%OUTPUT_DIR%\Start_LibasuThaqva.bat"

REM Create README for users
echo # Libasu Thaqva - Portable Version > "%OUTPUT_DIR%\README.txt"
echo. >> "%OUTPUT_DIR%\README.txt"
echo This is a portable version of Libasu Thaqva. >> "%OUTPUT_DIR%\README.txt"
echo No installation required! >> "%OUTPUT_DIR%\README.txt"
echo. >> "%OUTPUT_DIR%\README.txt"
echo To run the application: >> "%OUTPUT_DIR%\README.txt"
echo 1. Double-click "Start_LibasuThaqva.bat" >> "%OUTPUT_DIR%\README.txt"
echo    OR >> "%OUTPUT_DIR%\README.txt"
echo 2. Double-click "tailor_shop.exe" directly >> "%OUTPUT_DIR%\README.txt"
echo. >> "%OUTPUT_DIR%\README.txt"
echo The app will create its data files in this folder. >> "%OUTPUT_DIR%\README.txt"
echo You can copy this entire folder to any computer. >> "%OUTPUT_DIR%\README.txt"
echo. >> "%OUTPUT_DIR%\README.txt"
echo System Requirements: >> "%OUTPUT_DIR%\README.txt"
echo - Windows 10 or later >> "%OUTPUT_DIR%\README.txt"
echo - 64-bit system >> "%OUTPUT_DIR%\README.txt"

echo ✓ Portable package created

echo.
echo Step 3: Creating ZIP archive...
if exist "%OUTPUT_DIR%.zip" del "%OUTPUT_DIR%.zip"

REM Try to create ZIP using PowerShell
powershell -command "Compress-Archive -Path '%OUTPUT_DIR%\*' -DestinationPath '%OUTPUT_DIR%.zip'" 2>nul

if exist "%OUTPUT_DIR%.zip" (
    echo ✓ ZIP archive created: %OUTPUT_DIR%.zip
) else (
    echo ! Could not create ZIP archive
    echo   You can manually create a ZIP file from the %OUTPUT_DIR% folder
)

echo.
echo =============================================
echo   🎉 Portable Version Created Successfully!
echo =============================================
echo.
echo Output:
echo   📁 Folder: %OUTPUT_DIR%\
echo   📦 ZIP file: %OUTPUT_DIR%.zip
echo.
echo Distribution options:
echo ✓ Share the ZIP file for easy distribution
echo ✓ Copy the folder to USB drives
echo ✓ No installation required on target computers
echo ✓ All data stored in the application folder
echo.
echo Opening output folder...
start explorer.exe "%OUTPUT_DIR%"

echo.
pause
