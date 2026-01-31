#!/bin/bash

# Script to create macOS App Bundle from Swift Package Manager executable
# This allows proper testing of menu bar app with notifications

set -e

echo "🔨 Building ClipStack..."
swift build -c release

echo "📦 Creating App Bundle..."

# Define paths
BUILD_DIR=".build/release"
APP_NAME="ClipStack"
APP_BUNDLE="$BUILD_DIR/$APP_NAME.app"
CONTENTS="$APP_BUNDLE/Contents"
MACOS="$CONTENTS/MacOS"
RESOURCES="$CONTENTS/Resources"

# Clean previous bundle
rm -rf "$APP_BUNDLE"

# Create bundle structure
mkdir -p "$MACOS"
mkdir -p "$RESOURCES"

# Copy executable
cp "$BUILD_DIR/$APP_NAME" "$MACOS/"

# Copy Info.plist
cp "ClipStack/Resources/Info.plist" "$CONTENTS/"

# Copy entitlements (for reference)
cp "ClipStack/Resources/ClipStack.entitlements" "$RESOURCES/"

# Create PkgInfo
echo "APPL????" > "$CONTENTS/PkgInfo"

echo "✅ App Bundle created at: $APP_BUNDLE"
echo ""
echo "To run the app:"
echo "  open $APP_BUNDLE"
echo ""
echo "To run with console output:"
echo "  $APP_BUNDLE/Contents/MacOS/$APP_NAME"
echo ""
echo "⚠️  Note: You may need to grant permissions in System Settings:"
echo "   - Privacy & Security > Accessibility"
echo "   - Privacy & Security > Automation"