#!/bin/bash

# Check if Inno Setup is installed
if ! command -v iscc &> /dev/null; then
    echo ""
    echo "ERROR: Inno Setup is not installed or not in PATH"
    echo ""
    echo "Please install Inno Setup from: https://jrsoftware.org/isdl.php"
    echo "After installation, add it to PATH or use the full path to iscc.exe"
    echo ""
    echo "Typical installation path:"
    echo "  C:\\Program Files (x86)\\Inno Setup 6\\ISCC.exe"
    exit 1
fi

# Build Flutter Windows app
echo "Building Flutter Windows release..."
flutter build windows --release || exit -1

# Build installer
echo ""
echo "Creating installer with Inno Setup..."
cd bash
iscc installer.iss || exit 1
cd ..

echo ""
echo "Installer created successfully!"
