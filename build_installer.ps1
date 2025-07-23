# PowerShell script to build Tailor Shop Management installer
param(
    [switch]$MSIXOnly,
    [switch]$InnoOnly,
    [switch]$All,
    [switch]$Help
)

function Show-Help {
    Write-Host ""
    Write-Host "Tailor Shop Management System - Installer Builder" -ForegroundColor Green
    Write-Host "=================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Usage: .\build_installer.ps1 [options]" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Options:" -ForegroundColor Yellow
    Write-Host "  -MSIXOnly      Create MSIX installer only" -ForegroundColor White
    Write-Host "  -InnoOnly      Create Inno Setup installer only" -ForegroundColor White
    Write-Host "  -All           Create both installers (default)" -ForegroundColor White
    Write-Host "  -Help          Show this help" -ForegroundColor White
    Write-Host ""
}

if ($Help) {
    Show-Help
    exit 0
}

if (!$MSIXOnly -and !$InnoOnly) {
    $All = $true
}

Write-Host "🏭 Building Tailor Shop Management Installer..." -ForegroundColor Green
Write-Host "===============================================" -ForegroundColor Green
Write-Host ""

# Step 1: Clean and get dependencies
Write-Host "Step 1: Preparing build environment..." -ForegroundColor Yellow
flutter clean
flutter pub get

# Step 2: Build Windows release
Write-Host ""
Write-Host "Step 2: Building Windows release..." -ForegroundColor Yellow
flutter build windows --release

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Flutter build failed!" -ForegroundColor Red
    exit 1
}

Write-Host "✅ Flutter build completed successfully!" -ForegroundColor Green

# Step 3: Create MSIX installer
if ($MSIXOnly -or $All) {
    Write-Host ""
    Write-Host "Step 3: Creating MSIX installer..." -ForegroundColor Yellow
    
    # Check for app icon
    if (!(Test-Path "assets\icons\app_icon.png")) {
        Write-Host "⚠️  App icon not found. Please add app_icon.png to assets\icons\" -ForegroundColor Yellow
        Write-Host "   You can use the SVG file we created to generate the PNG icon." -ForegroundColor Yellow
    }
    
    flutter pub run msix:create
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ MSIX installer created successfully!" -ForegroundColor Green
    } else {
        Write-Host "❌ MSIX installer creation failed!" -ForegroundColor Red
    }
}

# Step 4: Create Inno Setup installer
if ($InnoOnly -or $All) {
    Write-Host ""
    Write-Host "Step 4: Creating Inno Setup installer..." -ForegroundColor Yellow
$innoSetupPath = ""
$possiblePaths = @(
    "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe",
    "${env:ProgramFiles}\Inno Setup 6\ISCC.exe",
    "${env:ProgramFiles(x86)}\Inno Setup 5\ISCC.exe",
    "${env:ProgramFiles}\Inno Setup 5\ISCC.exe"
)

foreach ($path in $possiblePaths) {
    if (Test-Path $path) {
        $innoSetupPath = $path
        break
    }
}

if ($innoSetupPath -eq "") {
    Write-Host ""
    Write-Host "Inno Setup not found. Please install Inno Setup from: https://jrsoftware.org/isinfo.php" -ForegroundColor Red
    Write-Host "After installing Inno Setup, you can manually compile the installer using installer_script.iss" -ForegroundColor Yellow
    Write-Host ""
} else {
    # Step 3: Create installer with Inno Setup
    Write-Host ""
    Write-Host "Step 3: Creating installer with Inno Setup..." -ForegroundColor Yellow
    
    # Create installer directory
    if (!(Test-Path "installer")) {
        New-Item -ItemType Directory -Name "installer"
    }
    
    # Compile installer
    & "$innoSetupPath" "installer_script.iss"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "Build completed successfully!" -ForegroundColor Green
        Write-Host "Installer created in the 'installer' folder." -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "Error creating installer. Please check the installer_script.iss file." -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
