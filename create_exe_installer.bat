@echo off
title Quick EXE Installer Creator

echo.
echo ===============================================
echo    Libasu Thaqva - Quick EXE Installer Creator
echo ===============================================
echo.

REM Check if Inno Setup is now installed
set "INNO_PATH="
if exist "%ProgramFiles(x86)%\Inno Setup 6\ISCC.exe" set "INNO_PATH=%ProgramFiles(x86)%\Inno Setup 6\ISCC.exe"
if exist "%ProgramFiles%\Inno Setup 6\ISCC.exe" set "INNO_PATH=%ProgramFiles%\Inno Setup 6\ISCC.exe"

if "%INNO_PATH%"=="" (
    echo ❌ Inno Setup still not found!
    echo.
    echo Please install Inno Setup from:
    echo https://jrsoftware.org/isinfo.php
    echo.
    echo After installation, run this script again.
    echo.
    pause
    exit /b 1
)

echo ✅ Found Inno Setup: %INNO_PATH%
echo.
echo Creating EXE installer...

REM Ensure the build is ready
if not exist "build\windows\x64\runner\Release\libasu_thaqva.exe" (
    echo ❌ Flutter app not built yet!
    echo.
    echo Please build the app first:
    echo 1. Run: flutter build windows --release
    echo 2. Then run this script again
    echo.
    pause
    exit /b 1
)

REM Create installer directory
if not exist "installer" mkdir "installer"

REM Compile the installer
echo Compiling installer with Inno Setup...
"%INNO_PATH%" "installer_script.iss"

if %errorLevel% == 0 (
    echo.
    echo ===============================================
    echo   🎉 EXE Installer Created Successfully!
    echo ===============================================
    echo.
    echo Output: installer\LibasuThaqva_Setup.exe
    echo.
    echo This professional installer:
    echo ✅ Works like standard Windows software
    echo ✅ No certificate warnings
    echo ✅ Creates Start Menu shortcuts  
    echo ✅ Adds uninstaller to Control Panel
    echo ✅ Supports upgrade installations
    echo ✅ Uses your custom ICO icon
    echo.
    
    REM Get file size
    for %%A in (installer\LibasuThaqva_Setup.exe) do set SIZE=%%~zA
    set /a SIZE_MB=%SIZE%/1048576
    echo File size: %SIZE_MB% MB
    echo.
    
    echo Opening installer folder...
    start explorer.exe installer
    
) else (
    echo.
    echo ❌ Installer creation failed!
    echo.
    echo Please check:
    echo 1. installer_script.iss file exists
    echo 2. All paths in the script are correct
    echo 3. Flutter build completed successfully
)

echo.
pause
