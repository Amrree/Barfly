#!/bin/bash

# Mac Pet Build Script
# This script builds the Mac Pet application for distribution

set -e

echo "🐱 Building Mac Pet..."

# Clean previous builds
echo "Cleaning previous builds..."
xcodebuild clean -project MacPet.xcodeproj -scheme MacPet

# Build for Release
echo "Building for Release..."
xcodebuild build -project MacPet.xcodeproj -scheme MacPet -configuration Release

# Create DMG for distribution
echo "Creating DMG..."
APP_NAME="MacPet"
BUILD_DIR="build/Release"
DMG_NAME="MacPet-1.0.dmg"
VOLUME_NAME="Mac Pet"

# Create DMG
hdiutil create -srcfolder "$BUILD_DIR/$APP_NAME.app" -volname "$VOLUME_NAME" -fs HFS+ -fsargs "-c c=64,a=16,e=16" -format UDZO "$DMG_NAME"

echo "✅ Build complete! DMG created: $DMG_NAME"
echo "📦 App bundle location: $BUILD_DIR/$APP_NAME.app"