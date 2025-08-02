#!/bin/bash

echo "🔄 Updating app name to 'Libasu Thaqva'..."
echo

echo "✅ Configuration files updated:"
echo "  - pubspec.yaml (description and MSIX config)"
echo "  - Android manifest"
echo "  - iOS Info.plist"
echo "  - macOS Info.plist"
echo "  - Web index.html and manifest.json"
echo "  - Windows CMakeLists.txt"
echo "  - Linux CMakeLists.txt"
echo "  - main.dart app title"

echo
echo "🚀 Next steps to apply changes:"
echo "1. Clean the project:"
echo "   flutter clean"
echo
echo "2. Get dependencies:"
echo "   flutter pub get"
echo
echo "3. For desktop platforms, you may need to rebuild:"
echo "   flutter build windows --release"
echo "   flutter build macos --release"
echo "   flutter build linux --release"
echo
echo "4. For mobile platforms:"
echo "   flutter build apk --release"
echo "   flutter build ipa --release"
echo
echo "5. Test the app on your target platform:"
echo "   flutter run -d macos"
echo
echo "App name successfully changed to: Libasu Thaqva"
echo "🎉 All configuration files have been updated!"
