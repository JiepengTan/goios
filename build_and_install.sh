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
ARCHIVE_PATH="$OUTPUT_DIR/$APP_NAME.xcarchive"
IPA_PATH="$OUTPUT_DIR/$APP_NAME.ipa"
EXPORT_OPTIONS_PATH="$OUTPUT_DIR/ExportOptions.plist"

# Colors for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}📱 Build and Install iOS App Script${NC}"
echo "======================================"

# Check if ios-deploy is installed
if ! command -v ios-deploy &> /dev/null; then
    echo -e "${YELLOW}⚠️  ios-deploy is not installed. Installing it now...${NC}"
    npm install -g ios-deploy
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ Failed to install ios-deploy. Please install it manually:${NC}"
        echo "npm install -g ios-deploy"
        exit 1
    fi
fi

# Step 1: Build GoIOS.xcframework
echo -e "${BLUE}🔨 Step 1: Building GoIOS.xcframework...${NC}"
if [ -f "$PROJECT_DIR/build_xcframework.sh" ]; then
    chmod +x "$PROJECT_DIR/build_xcframework.sh"
    "$PROJECT_DIR/build_xcframework.sh"
else
    echo -e "${RED}❌ build_xcframework.sh not found!${NC}"
    exit 1
fi

# Step 2: Get connected device UDID and name
echo -e "${BLUE}🔍 Step 2: Checking for connected iOS devices...${NC}"
DEVICE_INFO=$(ios-deploy -c)
if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Error: No iOS devices connected or ios-deploy failed.${NC}"
    echo "Make sure your device is connected and unlocked."
    exit 1
fi

DEVICE_UDID=$(echo "$DEVICE_INFO" | grep -o -E '([0-9a-f]{40})' | head -n 1)
DEVICE_NAME=$(echo "$DEVICE_INFO" | grep -o -E '"name" = "([^"]+)"' | sed 's/"name" = "//;s/"//g' | head -n 1)

if [ -z "$DEVICE_UDID" ]; then
    echo -e "${RED}❌ Could not find device UDID.${NC}"
    exit 1
fi

echo -e "${GREEN}📱 Found device: $DEVICE_NAME ($DEVICE_UDID)${NC}"

# Step 3: Create export options plist
echo -e "${BLUE}📝 Step 3: Creating export options...${NC}"
mkdir -p "$OUTPUT_DIR"

cat > "$EXPORT_OPTIONS_PATH" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>development</string>
    <key>teamID</key>
    <string>DEVELOPMENT_TEAM_ID</string>
    <key>provisioningProfiles</key>
    <dict>
        <key>com.example.GoIOSDemo</key>
        <string>YOUR_PROVISIONING_PROFILE_NAME</string>
    </dict>
</dict>
</plist>
EOF

echo -e "${YELLOW}⚠️  Important: You need to edit $EXPORT_OPTIONS_PATH and set:${NC}"
echo -e "   - Your development team ID"
echo -e "   - Your provisioning profile name"
echo ""
echo -e "${YELLOW}Do you want to edit the export options now? (y/n)${NC}"
read -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    ${EDITOR:-vi} "$EXPORT_OPTIONS_PATH"
fi

# Step 4: Build and archive the app
echo -e "${BLUE}🏗 Step 4: Building and archiving the app...${NC}"
xcodebuild clean archive \
    -project "$XCODE_PROJECT" \
    -scheme "$APP_NAME" \
    -configuration Release \
    -destination "generic/platform=iOS" \
    -archivePath "$ARCHIVE_PATH" \
    CODE_SIGN_IDENTITY="iPhone Developer" \
    DEVELOPMENT_TEAM="$(defaults read "$EXPORT_OPTIONS_PATH" teamID)" \
    PROVISIONING_PROFILE_SPECIFIER="$(defaults read "$EXPORT_OPTIONS_PATH" 'provisioningProfiles:com.example.GoIOSDemo')"

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Archive build failed!${NC}"
    exit 1
fi

# Step 5: Export IPA
echo -e "${BLUE}📦 Step 5: Exporting IPA...${NC}"
xcodebuild -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportOptionsPlist "$EXPORT_OPTIONS_PATH" \
    -exportPath "$OUTPUT_DIR"

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ IPA export failed!${NC}"
    exit 1
fi

# Step 6: Install IPA on device
echo -e "${BLUE}📲 Step 6: Installing app on device $DEVICE_NAME...${NC}"
ios-deploy --bundle "$IPA_PATH" --id "$DEVICE_UDID" --debug

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ App installation failed!${NC}"
    echo "You might need to trust the developer certificate on your device."
    echo "Go to Settings > General > Device Management on your iOS device."
    exit 1
fi

echo -e "${GREEN}✅ Successfully built and installed $APP_NAME on your device!${NC}"
echo -e "   IPA location: $IPA_PATH"
