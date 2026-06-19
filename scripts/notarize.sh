#!/bin/bash
set -euo pipefail

# KeyLoom Notarization Script
# Usage: ./scripts/notarize.sh [path/to/KeyLoom.app]
#
# Prerequisites:
#   - Apple Developer Program membership
#   - Xcode 15+ Command Line Tools
#   - App-specific password saved in keychain, or use @keychain:AC_PASSWORD
#
# Environment variables:
#   APPLE_ID       – Your Apple ID email
#   APPLE_TEAM_ID  – Your Team ID (found in App Store Connect)
#   AC_PASSWORD    – App-specific password for notarization (or keychain reference)

APP_PATH="${1:-build/Release/KeyLoom.app}"
ARCHIVE_PATH="${APP_PATH}.zip"
BUNDLE_ID="com.fabiconcept.keyloom"
VERSION=$(/usr/libexec/PlistBuddy -c "Print CFBundleShortVersionString" "$APP_PATH/Contents/Info.plist" 2>/dev/null || echo "1.0.0")

echo "=== KeyLoom Notarization v$VERSION ==="
echo "App: $APP_PATH"

# Validate prerequisites
if [ ! -d "$APP_PATH" ]; then
    echo "Error: App not found at $APP_PATH"
    echo "Build it first: xcodebuild -project KeyLoom.xcodeproj -scheme KeyLoom -configuration Release build"
    exit 1
fi

if [ -z "${APPLE_ID:-}" ]; then
    echo "Error: APPLE_ID environment variable not set"
    exit 1
fi

# Step 1: Create a compressed archive for notarization
echo ""
echo "Step 1: Creating archive..."
ditto -c -k --keepParent "$APP_PATH" "$ARCHIVE_PATH"
echo "Created: $ARCHIVE_PATH"

# Step 2: Submit to Apple for notarization
echo ""
echo "Step 2: Submitting for notarization..."
SUBMIT_OUTPUT=$(xcrun notarytool submit "$ARCHIVE_PATH" \
    --apple-id "$APPLE_ID" \
    --team-id "$APPLE_TEAM_ID" \
    --password "$AC_PASSWORD" \
    --wait 2>&1)

echo "$SUBMIT_OUTPUT"

# Extract submission ID
SUBMISSION_ID=$(echo "$SUBMIT_OUTPUT" | grep -oE 'id: [a-f0-9-]+' | head -1 | cut -d' ' -f2)
if [ -z "$SUBMISSION_ID" ]; then
    echo "Error: Could not extract submission ID"
    exit 1
fi

# Step 3: Check notarization status
echo ""
echo "Step 3: Checking notarization status..."
xcrun notarytool log --apple-id "$APPLE_ID" \
    --team-id "$APPLE_TEAM_ID" \
    --password "$AC_PASSWORD" \
    "$SUBMISSION_ID"

# Step 4: Staple the ticket to the app
echo ""
echo "Step 4: Stapling notarization ticket..."
xcrun stapler staple "$APP_PATH"

# Step 5: Validate
echo ""
echo "Step 5: Validating..."
spctl --assess --verbose "$APP_PATH"

# Clean up
rm "$ARCHIVE_PATH"

echo ""
echo "=== Notarization complete! ==="
echo "KeyLoom.app is now ready for distribution."
echo "You can find the signed and notarized app at: $APP_PATH"
