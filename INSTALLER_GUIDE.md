# Windows Installer Setup Guide

This guide will help you create Windows installers for your Tailor Shop Management System.

## 📋 Prerequisites

### Required Software:
1. **Flutter SDK** - Already installed ✅
2. **Visual Studio 2022** (with C++ workload) - For Windows builds
3. **Inno Setup** (Optional) - For traditional .exe installer
   - Download from: https://jrsoftware.org/isinfo.php
   - Choose the latest version (currently 6.x)

## 🎨 Create App Icons (Important!)

Before building installers, you need to create proper app icons:

### Option 1: Use Online Converters (Recommended)
1. Open the `assets/icons/app_icon.svg` file we created
2. Go to https://convertio.co/svg-png/
3. Upload the SVG file and convert to PNG (256x256 pixels)
4. Save as `assets/icons/app_icon.png`
5. Go to https://convertio.co/png-ico/
6. Convert the PNG to ICO format
7. Save as `assets/icons/app_icon.ico`

### Option 2: Use Design Software
- Adobe Illustrator/Photoshop
- GIMP (free)
- Canva (online)

**Important**: Make sure the PNG is exactly 256x256 pixels!

## 🚀 Building Installers

### Method 1: Using PowerShell Script (Recommended)

Open PowerShell in your project folder and run:

```powershell
# Build both MSIX and Inno Setup installers
.\build_installer.ps1 -All

# Build only MSIX installer (Microsoft Store format)
.\build_installer.ps1 -MSIXOnly

# Build only Inno Setup installer (traditional .exe)
.\build_installer.ps1 -InnoOnly

# Show help
.\build_installer.ps1 -Help
```

### Method 2: Manual Steps

#### For MSIX Installer (Modern Windows):
```bash
flutter clean
flutter pub get
flutter build windows --release
flutter pub run msix:create
```

#### For Inno Setup Installer (Traditional):
1. Install Inno Setup from https://jrsoftware.org/isinfo.php
2. Run the PowerShell script or manually compile `installer/inno_setup.iss`

## 📁 Output Locations

After successful build, you'll find:

- **MSIX Installer**: `build/windows/x64/runner/Release/`
- **Inno Setup Installer**: `installer/Output/`
- **Standalone App**: `build/windows/x64/runner/Release/tailor_shop.exe`

## ⚙️ Customization

### Update Publisher Information

Edit `pubspec.yaml` and update these fields:
```yaml
msix_config:
  display_name: Your Shop Name Management
  publisher_display_name: Your Business Name
  identity_name: com.yourcompany.yourapp
  publisher: CN=YourCompany
```

### Update Inno Setup Script

Edit `installer/inno_setup.iss` to customize:
- Company name
- Application name
- Installation directory
- Start menu entries
- Desktop shortcuts

## 🔧 Troubleshooting

### Common Issues:

1. **"App icon not found"**
   - Create `app_icon.png` (256x256) in `assets/icons/`
   - The script will warn but continue with default icon

2. **"MSIX creation failed"**
   - Check that Windows SDK is installed
   - Verify icon file exists and is correct size
   - Check publisher certificate settings

3. **"Inno Setup not found"**
   - Install Inno Setup from the official website
   - Restart PowerShell after installation

4. **"Flutter build failed"**
   - Run `flutter doctor` to check setup
   - Ensure Visual Studio with C++ workload is installed

## 📦 Distribution

### MSIX Installer:
- **Pros**: Modern, secure, automatic updates
- **Cons**: Requires Windows 10/11, may need sideloading enabled
- **Best for**: Internal distribution, Microsoft Store

### Inno Setup Installer:
- **Pros**: Works on all Windows versions, familiar to users
- **Cons**: Requires manual updates, less secure
- **Best for**: Public distribution, older Windows systems

## 🔐 Code Signing (Production)

For production distribution:
1. Get a code signing certificate
2. Sign your executables to avoid Windows security warnings
3. Consider EV certificates for immediate trust

## 📞 Support

If you encounter issues:
1. Check the error messages carefully
2. Ensure all prerequisites are installed
3. Verify icon files exist and are correct size
4. Check Windows version compatibility

---

**Next Steps:**
1. Create your app icons using the SVG template
2. Test the build process with the PowerShell script
3. Customize the installer settings
4. Test installation on different Windows versions
