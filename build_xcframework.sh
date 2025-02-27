#!/bin/bash

set -e

# Configuration variables
GO_SRC_DIR="./go"
OUTPUT_DIR="./output"
FRAMEWORK_NAME="GoIOS"
BUILD_DIR="$OUTPUT_DIR/build"
SIMULATOR_DIR="$BUILD_DIR/simulator"
DEVICE_DIR="$BUILD_DIR/device"
FRAMEWORK_DIR="$OUTPUT_DIR/$FRAMEWORK_NAME.framework"
XCFRAMEWORK_DIR="$OUTPUT_DIR/$FRAMEWORK_NAME.xcframework"

# Cleanup previous builds
rm -rf "$OUTPUT_DIR"
mkdir -p "$SIMULATOR_DIR" "$DEVICE_DIR"

echo "📦 Building Go libraries..."

cd "$GO_SRC_DIR"

# Get SDK paths
SIMULATOR_SDK_PATH=$(xcrun --sdk iphonesimulator --show-sdk-path)
DEVICE_SDK_PATH=$(xcrun --sdk iphoneos --show-sdk-path)

# Build for iOS Simulator (x86_64)
echo "🔨 Building for iOS Simulator (x86_64)..."
CGO_ENABLED=1 \
GOOS=darwin \
GOARCH=amd64 \
CGO_CFLAGS="-isysroot $SIMULATOR_SDK_PATH -mios-simulator-version-min=11.0 -arch x86_64" \
CGO_LDFLAGS="-isysroot $SIMULATOR_SDK_PATH -mios-simulator-version-min=11.0 -arch x86_64" \
go build -buildmode=c-archive -o "../$SIMULATOR_DIR/libgoios-x86_64.a" .

# Build for iOS Simulator (arm64)
echo "🔨 Building for iOS Simulator (arm64)..."
CGO_ENABLED=1 \
GOOS=darwin \
GOARCH=arm64 \
CGO_CFLAGS="-isysroot $SIMULATOR_SDK_PATH -mios-simulator-version-min=11.0 -arch arm64" \
CGO_LDFLAGS="-isysroot $SIMULATOR_SDK_PATH -mios-simulator-version-min=11.0 -arch arm64" \
go build -buildmode=c-archive -o "../$SIMULATOR_DIR/libgoios-arm64-sim.a" .

# Build for iOS Device (arm64)
echo "🔨 Building for iOS Device (arm64)..."
CGO_ENABLED=1 \
GOOS=darwin \
GOARCH=arm64 \
CGO_CFLAGS="-isysroot $DEVICE_SDK_PATH -mios-version-min=11.0 -arch arm64" \
CGO_LDFLAGS="-isysroot $DEVICE_SDK_PATH -mios-version-min=11.0 -arch arm64" \
go build -buildmode=c-archive -o "../$DEVICE_DIR/libgoios-arm64.a" .

cd ..

# Create separate architectures for simulator and device
echo "📚 Creating separate framework libraries..."

# Copy header files
echo "📄 Copying header files..."
cp "$SIMULATOR_DIR/libgoios-x86_64.h" "$SIMULATOR_DIR/GoIOS.h"
cp "$DEVICE_DIR/libgoios-arm64.h" "$DEVICE_DIR/GoIOS.h"

# Create separate framework directories
mkdir -p "$SIMULATOR_DIR/$FRAMEWORK_NAME.framework/Headers"
mkdir -p "$DEVICE_DIR/$FRAMEWORK_NAME.framework/Headers"

# Copy headers for frameworks
cp "$SIMULATOR_DIR/libgoios-x86_64.h" "$SIMULATOR_DIR/$FRAMEWORK_NAME.framework/Headers/GoIOS.h"
cp "$DEVICE_DIR/libgoios-arm64.h" "$DEVICE_DIR/$FRAMEWORK_NAME.framework/Headers/GoIOS.h"

# Create Info.plist files
cat > "$SIMULATOR_DIR/$FRAMEWORK_NAME.framework/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>en</string>
	<key>CFBundleExecutable</key>
	<string>GoIOS</string>
	<key>CFBundleIdentifier</key>
	<string>com.example.GoIOS</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>GoIOS</string>
	<key>CFBundlePackageType</key>
	<string>FMWK</string>
	<key>CFBundleShortVersionString</key>
	<string>1.0</string>
	<key>CFBundleVersion</key>
	<string>1</string>
	<key>MinimumOSVersion</key>
	<string>11.0</string>
</dict>
</plist>
EOF

cat > "$DEVICE_DIR/$FRAMEWORK_NAME.framework/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>CFBundleDevelopmentRegion</key>
	<string>en</string>
	<key>CFBundleExecutable</key>
	<string>GoIOS</string>
	<key>CFBundleIdentifier</key>
	<string>com.example.GoIOS</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>GoIOS</string>
	<key>CFBundlePackageType</key>
	<string>FMWK</string>
	<key>CFBundleShortVersionString</key>
	<string>1.0</string>
	<key>CFBundleVersion</key>
	<string>1</string>
	<key>MinimumOSVersion</key>
	<string>11.0</string>
</dict>
</plist>
EOF

# Add C bridge file
echo "🌉 Adding C bridge file..."
gcc -isysroot $SIMULATOR_SDK_PATH -mios-simulator-version-min=11.0 -arch x86_64 -c "$GO_SRC_DIR/goios_bridge.c" -o "$BUILD_DIR/goios_bridge_x86_64.o"
gcc -isysroot $SIMULATOR_SDK_PATH -mios-simulator-version-min=11.0 -arch arm64 -c "$GO_SRC_DIR/goios_bridge.c" -o "$BUILD_DIR/goios_bridge_arm64_sim.o"
gcc -isysroot $DEVICE_SDK_PATH -mios-version-min=11.0 -arch arm64 -c "$GO_SRC_DIR/goios_bridge.c" -o "$BUILD_DIR/goios_bridge_arm64.o"

# Link libraries for x86_64 simulator
echo "🔗 Linking libraries for x86_64 simulator..."
libtool -static -arch_only x86_64 -o "$SIMULATOR_DIR/$FRAMEWORK_NAME.framework/GoIOS-x86_64" \
  "$SIMULATOR_DIR/libgoios-x86_64.a" \
  "$BUILD_DIR/goios_bridge_x86_64.o"

# Link libraries for arm64 simulator
echo "🔗 Linking libraries for arm64 simulator..."
libtool -static -arch_only arm64 -o "$SIMULATOR_DIR/$FRAMEWORK_NAME.framework/GoIOS-arm64" \
  "$SIMULATOR_DIR/libgoios-arm64-sim.a" \
  "$BUILD_DIR/goios_bridge_arm64_sim.o"

# Create fat binary for simulator
echo "🔗 Creating fat binary for simulator..."
lipo -create -output "$SIMULATOR_DIR/$FRAMEWORK_NAME.framework/$FRAMEWORK_NAME" \
  "$SIMULATOR_DIR/$FRAMEWORK_NAME.framework/GoIOS-x86_64" \
  "$SIMULATOR_DIR/$FRAMEWORK_NAME.framework/GoIOS-arm64"

# Link libraries for arm64 device
echo "🔗 Linking libraries for arm64 device..."
libtool -static -arch_only arm64 -o "$DEVICE_DIR/$FRAMEWORK_NAME.framework/$FRAMEWORK_NAME" \
  "$DEVICE_DIR/libgoios-arm64.a" \
  "$BUILD_DIR/goios_bridge_arm64.o"

# Create XCFramework
echo "🎁 Creating XCFramework..."
rm -rf "$XCFRAMEWORK_DIR"
xcrun xcodebuild -create-xcframework \
  -framework "$SIMULATOR_DIR/$FRAMEWORK_NAME.framework" \
  -framework "$DEVICE_DIR/$FRAMEWORK_NAME.framework" \
  -output "$XCFRAMEWORK_DIR"

echo "✅ Successfully built $FRAMEWORK_NAME.xcframework!"
echo "📍 Location: $XCFRAMEWORK_DIR"
