#!/bin/bash
set -euo pipefail

# KeyLoom Release Build Script
# Builds, signs, and prepares the app for distribution
#
# Usage:
#   ./scripts/build-release.sh          – Development-signed build
#   DISTRIBUTION=1 ./scripts/build-release.sh – Distribution-signed build

PROJECT="KeyLoom.xcodeproj"
SCHEME="KeyLoom"
CONFIGURATION="Release"
BUILD_DIR="build"

echo "=== KeyLoom Release Build ==="
echo "Scheme: $SCHEME | Configuration: $CONFIGURATION"

# Clean
echo ""
echo "Cleaning..."
xcodebuild -project "$PROJECT" -scheme "$SCHEME" -configuration "$CONFIGURATION" clean

# Build
echo ""
echo "Building..."
if [ "${DISTRIBUTION:-0}" = "1" ]; then
    # Distribution build (for notarization)
    xcodebuild -project "$PROJECT" -scheme "$SCHEME" \
        -configuration "$CONFIGURATION" \
        -derivedDataPath "$BUILD_DIR" \
        CODE_SIGN_STYLE="Manual" \
        CODE_SIGN_IDENTITY="Developer ID Application" \
        OTHER_CODE_SIGN_FLAGS="--timestamp" \
        build
else
    # Development build
    xcodebuild -project "$PROJECT" -scheme "$SCHEME" \
        -configuration "$CONFIGURATION" \
        -derivedDataPath "$BUILD_DIR" \
        build
fi

APP_PATH="$BUILD_DIR/Build/Products/$CONFIGURATION/$SCHEME.app"

if [ -d "$APP_PATH" ]; then
    echo ""
    echo "Build complete: $APP_PATH"
    
    VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "$APP_PATH/Contents/Info.plist" 2>/dev/null || echo "?")
    echo "Version: $VERSION"
    
    # Create DMG
    echo ""
    echo "Creating DMG..."
    DMG_NAME="KeyLoom-$VERSION.dmg"
    mkdir -p "$BUILD_DIR/DMG"
    cp -R "$APP_PATH" "$BUILD_DIR/DMG/"
    ln -s /Applications "$BUILD_DIR/DMG/Applications"
    hdiutil create -volname "KeyLoom" -srcfolder "$BUILD_DIR/DMG" \
        -ov -format UDZO "$BUILD_DIR/$DMG_NAME"
    rm -rf "$BUILD_DIR/DMG"
    echo "DMG: $BUILD_DIR/$DMG_NAME"
else
    echo "Warning: App not found at expected path. Build may have failed."
fi

echo ""
echo "=== Build complete ==="
