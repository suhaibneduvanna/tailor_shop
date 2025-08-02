# Installation Guide for EXE Installer Creation

## 📥 Installing Inno Setup

To create a traditional EXE installer for Libasu Thaqva, you need to install Inno Setup:

### Step 1: Download Inno Setup
1. Go to: **https://jrsoftware.org/isinfo.php**
2. Click **"Download Inno Setup"**
3. Download the latest version (usually "innosetup-6.x.x.exe")

### Step 2: Install Inno Setup
1. Run the downloaded installer
2. Follow the installation wizard
3. Use default settings (install to Program Files)
4. Complete the installation

### Step 3: Create EXE Installer
After installing Inno Setup, you can create the EXE installer:

**Option 1: Double-click** `build_exe.bat`
**Option 2: Run** `build_exe_installer.ps1` in PowerShell

## 🎯 What the EXE Installer Provides

✅ **Traditional Windows installer experience**
✅ **No certificate warnings or errors**
✅ **Creates Start Menu shortcuts**
✅ **Includes uninstaller in Control Panel**
✅ **Supports upgrade installations**
✅ **Works offline without internet**
✅ **Professional installer wizard**

## 📦 Alternative: Portable Version

If you don't want to install Inno Setup, I can create a portable version that doesn't require installation.

## 🔧 Manual Installation (Without Inno Setup)

You can also distribute the app manually:
1. Build with: `flutter build windows --release`
2. Copy entire folder: `build\windows\x64\runner\Release\`
3. Users can run: `tailor_shop.exe` directly
4. No installation required - portable application

Let me know if you'd like me to:
- Create a portable version script
- Help with Inno Setup installation
- Create distribution instructions
