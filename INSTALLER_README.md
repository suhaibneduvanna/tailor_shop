# Tailor Shop Management - Windows Installer Guide

This guide will help you create a Windows installer for the Tailor Shop Management application.

## Prerequisites

1. **Flutter SDK** - Make sure Flutter is installed and configured
2. **Visual Studio** - Required for Windows development
3. **Windows 10 SDK** - Required for building Windows apps

## Option 1: MSIX Installer (Recommended)

MSIX is the modern Windows app package format that provides automatic updates, better security, and easy distribution.

### Steps:

1. **Install dependencies:**
   ```bash
   flutter pub get
   ```

2. **Build the app:**
   ```bash
   flutter build windows --release
   ```

3. **Create MSIX installer:**
   ```bash
   dart run msix:create
   ```

4. **Or use the batch script:**
   ```bash
   build_installer.bat
   ```

The MSIX package will be created in `build/windows/x64/runner/Release/` folder.

### MSIX Configuration

The MSIX configuration is in `pubspec.yaml` under `msix_config`. You can customize:

- `display_name`: App name shown to users
- `publisher_display_name`: Your company name
- `description`: App description
- `logo_path`: Path to app icon (PNG format)
- `capabilities`: Windows permissions needed

## Option 2: Traditional .exe Installer (Inno Setup)

This creates a traditional Windows installer that users are familiar with.

### Prerequisites:

1. **Download and install Inno Setup:** https://jrsoftware.org/isinfo.php

### Steps:

1. **Build the Flutter app:**
   ```bash
   flutter build windows --release
   ```

2. **Run the PowerShell script:**
   ```powershell
   .\build_installer.ps1
   ```

   Or manually compile with Inno Setup:
   ```bash
   "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" installer_script.iss
   ```

The installer will be created in the `installer/` folder.

### Inno Setup Configuration

Edit `installer_script.iss` to customize:

- App name and version
- Company information
- Installation directory
- Desktop shortcuts
- Start menu entries

## Customization

### App Icon

1. Create app icons in these formats:
   - `assets/icons/app_icon.png` (for MSIX) - 256x256 pixels
   - `assets/icons/app_icon.ico` (for Inno Setup) - Windows ICO format

2. You can convert PNG to ICO using online tools or software like GIMP.

### App Information

Update the following files with your information:

1. **pubspec.yaml** - App version, name, description
2. **installer_script.iss** - Company name, website, support info
3. **windows/runner/main.cpp** - Window title and size

## Distribution

### MSIX Package
- Can be distributed directly to users
- Can be submitted to Microsoft Store
- Supports automatic updates
- Users can install with a double-click

### Traditional Installer
- Familiar installation experience
- Works on all Windows versions
- Can include custom installation logic
- Users expect this format for desktop apps

## Testing

1. **Test on clean Windows machine** to ensure all dependencies are included
2. **Test installation and uninstallation** process
3. **Verify app functionality** after installation
4. **Check Windows Defender** doesn't flag the installer

## Troubleshooting

### Common Issues:

1. **Missing Visual C++ Redistributables**
   - Include redistributables in installer
   - Or have users install Visual Studio Build Tools

2. **Antivirus false positives**
   - Sign your installer with a code signing certificate
   - Submit to antivirus vendors for whitelisting

3. **App crashes on other machines**
   - Ensure all dependencies are included
   - Test on machines without development tools

### Code Signing (Recommended for Production)

For production releases, sign your installer with a code signing certificate:

1. Purchase a code signing certificate
2. Sign the MSIX package or .exe installer
3. This prevents Windows security warnings

## File Structure

```
tailor_shop/
├── assets/icons/          # App icons
├── build/windows/         # Built application
├── installer/             # Generated installers
├── build_installer.bat    # MSIX build script
├── build_installer.ps1    # Inno Setup build script
├── installer_script.iss   # Inno Setup configuration
└── pubspec.yaml          # MSIX configuration
```

## Support

For issues with the installer creation process:

1. Check Flutter documentation for Windows deployment
2. Refer to MSIX package documentation
3. Check Inno Setup documentation for traditional installers

---

**Note:** Replace placeholder information (company name, website, etc.) with your actual details before building the installer.
