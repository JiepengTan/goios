#!/bin/bash

set -e

# Configuration variables
PROJECT_DIR="$(pwd)"
GO_SRC_DIR="$PROJECT_DIR/go"
OUTPUT_DIR="$PROJECT_DIR/output"
IOSAPP_DIR="$PROJECT_DIR/iosapp"
FRAMEWORK_NAME="GoIOS"
XCFRAMEWORK_DIR="$OUTPUT_DIR/$FRAMEWORK_NAME.xcframework"
APP_NAME="GoIOSDemo"
XCODE_PROJECT="$IOSAPP_DIR/$APP_NAME.xcodeproj"

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}📱 Build for iOS Device Script${NC}"
echo "======================================"

# Step 1: Build GoIOS.xcframework
echo -e "${BLUE}🔨 Step 1: Building GoIOS.xcframework...${NC}"
if [ -f "$PROJECT_DIR/build_xcframework.sh" ]; then
    chmod +x "$PROJECT_DIR/build_xcframework.sh"
    "$PROJECT_DIR/build_xcframework.sh"
else
    echo -e "${RED}❌ build_xcframework.sh not found!${NC}"
    exit 1
fi

# Verify the XCFramework was created in the expected location
if [ ! -d "$XCFRAMEWORK_DIR" ]; then
    echo -e "${RED}❌ XCFramework not found at $XCFRAMEWORK_DIR${NC}"
    exit 1
fi

# Also verify if the symlink was created properly
if [ ! -L "../output/GoIOS.xcframework" ] && [ ! -d "../output/GoIOS.xcframework" ]; then
    echo -e "${YELLOW}⚠️ XCFramework symlink not found at expected location. Creating it now...${NC}"
    mkdir -p "../output"
    ln -sf "$(pwd)/output/GoIOS.xcframework" "../output/GoIOS.xcframework"
fi

# Step 2: Open Xcode Project
echo -e "${BLUE}🚀 Step 2: Opening Xcode project...${NC}"
open "$XCODE_PROJECT"

echo -e "${GREEN}✅ GoIOS.xcframework has been built and Xcode project is now open.${NC}"
echo ""
echo -e "${YELLOW}📋 To run on your device:${NC}"
echo "1. Connect your iOS device to your Mac"
echo "2. In Xcode, select your device from the device dropdown in the toolbar"
echo "3. In Xcode, you'll need to configure code signing:"
echo "   - Select the project in the Navigator"
echo "   - Select the GoIOSDemo target"
echo "   - Go to the 'Signing & Capabilities' tab"
echo "   - Check 'Automatically manage signing'"
echo "   - Select your Team"
echo "4. Click the Run button (▶️) to build and run the app on your device"
echo ""
echo -e "${YELLOW}Note:${NC} The first time you run the app on your device, you may need to:"
echo "- Trust the developer certificate on your device"
echo "- Go to Settings > General > Device Management on your iOS device"
echo "- Select your developer account and trust it"
