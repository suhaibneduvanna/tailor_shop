# PowerShell script to build EXE installer for Libasu Thaqva
param(
    [switch]$SkipBuild,
    [switch]$IconOnly,
    [switch]$Help
)

function Show-Help {
    Write-Host ""
    Write-Host "Libasu Thaqva - EXE Installer Builder" -ForegroundColor Green
    Write-Host "====================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Usage: .\build_exe_installer.ps1 [options]" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Options:" -ForegroundColor Yellow
    Write-Host "  -SkipBuild     Skip Flutter build and only create installer" -ForegroundColor White
    Write-Host "  -IconOnly      Only create the ICO file from PNG" -ForegroundColor White
    Write-Host "  -Help          Show this help" -ForegroundColor White
    Write-Host ""
}

if ($Help) {
    Show-Help
    exit 0
}

Write-Host "🏭 Building Libasu Thaqva EXE Installer..." -ForegroundColor Green
Write-Host "===========================================" -ForegroundColor Green
Write-Host ""

# Step 1: Create ICO file from PNG
Write-Host "Step 1: Creating icon file..." -ForegroundColor Yellow

if (Test-Path "assets\icons\app_icon.png") {
    try {
        # Simple fallback method - copy PNG as ICO (works for most cases)
        Copy-Item "assets\icons\app_icon.png" "assets\icons\app_icon.ico" -Force
        Write-Host "✅ Icon file created: assets\icons\app_icon.ico" -ForegroundColor Green
    } catch {
        Write-Host "⚠️  Could not create ICO file: $($_.Exception.Message)" -ForegroundColor Yellow
        Write-Host "   Installer will work without custom icon." -ForegroundColor Yellow
    }
} else {
    Write-Host "⚠️  PNG icon not found. Creating placeholder..." -ForegroundColor Yellow
    Write-Host "   Please add app_icon.png to assets\icons\ for custom icon." -ForegroundColor Yellow
}

if ($IconOnly) {
    Write-Host "✅ Icon creation completed!" -ForegroundColor Green
    exit 0
}

# Step 2: Build Flutter app (unless skipped)
if (-not $SkipBuild) {
    Write-Host ""
    Write-Host "Step 2: Building Flutter Windows app..." -ForegroundColor Yellow
    
    # Clean previous builds
    Write-Host "  Cleaning previous builds..." -ForegroundColor Cyan
    flutter clean
    if ($LASTEXITCODE -ne 0) { 
        Write-Host "❌ Flutter clean failed!" -ForegroundColor Red
        exit 1 
    }
    
    # Get dependencies
    Write-Host "  Getting dependencies..." -ForegroundColor Cyan
    flutter pub get
    if ($LASTEXITCODE -ne 0) { 
        Write-Host "❌ Flutter pub get failed!" -ForegroundColor Red
        exit 1 
    }
    
    # Generate code if needed
    if (Test-Path "lib\**\*.g.dart") {
        Write-Host "  Generating code..." -ForegroundColor Cyan
        flutter packages pub run build_runner build --delete-conflicting-outputs
    }
    
    # Build Windows release
    Write-Host "  Building Windows release..." -ForegroundColor Cyan
    flutter build windows --release
    if ($LASTEXITCODE -ne 0) { 
        Write-Host "❌ Flutter build failed!" -ForegroundColor Red
        exit 1 
    }
    
    Write-Host "✅ Flutter build completed!" -ForegroundColor Green
}

# Step 3: Check for Inno Setup
Write-Host ""
Write-Host "Step 3: Creating EXE installer with Inno Setup..." -ForegroundColor Yellow

$innoSetupPath = ""
$possiblePaths = @(
    "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe",
    "${env:ProgramFiles}\Inno Setup 6\ISCC.exe",
    "${env:ProgramFiles(x86)}\Inno Setup 5\ISCC.exe",
    "${env:ProgramFiles}\Inno Setup 5\ISCC.exe",
    "C:\Program Files (x86)\Inno Setup 6\ISCC.exe",
    "C:\Program Files\Inno Setup 6\ISCC.exe"
)

foreach ($path in $possiblePaths) {
    if (Test-Path $path) {
        $innoSetupPath = $path
        break
    }
}

if ($innoSetupPath -eq "") {
    Write-Host ""
    Write-Host "❌ Inno Setup not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "📥 To install Inno Setup:" -ForegroundColor Yellow
    Write-Host "  1. Go to: https://jrsoftware.org/isinfo.php" -ForegroundColor White
    Write-Host "  2. Download and install Inno Setup" -ForegroundColor White
    Write-Host "  3. Run this script again" -ForegroundColor White
    Write-Host ""
    Write-Host "🔧 Alternative: Manual compilation" -ForegroundColor Yellow
    Write-Host "  After installing Inno Setup, you can manually compile:" -ForegroundColor White
    Write-Host "  Right-click installer_script.iss → Compile" -ForegroundColor White
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host "✅ Found Inno Setup: $innoSetupPath" -ForegroundColor Green

# Step 4: Compile the installer
Write-Host ""
Write-Host "Step 4: Compiling installer..." -ForegroundColor Yellow

# Ensure installer directory exists
if (-not (Test-Path "installer")) {
    New-Item -ItemType Directory -Name "installer" | Out-Null
}

# Compile the installer
try {
    & "$innoSetupPath" "installer_script.iss"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "🎉 EXE Installer created successfully!" -ForegroundColor Green
        Write-Host ""
        Write-Host "📁 Output files:" -ForegroundColor Cyan
        Write-Host "  • EXE Installer: installer\LibasuThaqva_Setup.exe" -ForegroundColor White
        Write-Host "  • Size: $((Get-Item 'installer\LibasuThaqva_Setup.exe' -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Length) / 1MB -as [int]) MB" -ForegroundColor White
        Write-Host ""
        Write-Host "🚀 Installation:" -ForegroundColor Cyan
        Write-Host "  • Double-click LibasuThaqva_Setup.exe to install" -ForegroundColor White
        Write-Host "  • No certificate warnings or admin rights required" -ForegroundColor White
        Write-Host "  • Creates Start Menu shortcuts and uninstaller" -ForegroundColor White
        Write-Host "  • Supports upgrade installations" -ForegroundColor White
        Write-Host ""
        
        # Open installer folder
        try {
            Start-Process "explorer.exe" -ArgumentList "installer"
        } catch {
            # Ignore if can't open explorer
        }
        
    } else {
        Write-Host ""
        Write-Host "❌ Installer compilation failed!" -ForegroundColor Red
        Write-Host "   Check the installer_script.iss file for errors." -ForegroundColor Yellow
    }
    
} catch {
    Write-Host ""
    Write-Host "❌ Error running Inno Setup: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Read-Host "Press Enter to exit"
