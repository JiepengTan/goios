#!/bin/bash

set -e

echo "🔍 Checking Go installation..."
if ! command -v go &> /dev/null; then
    echo "❌ Go is not installed. Please install Go first."
    exit 1
fi

echo "📋 Running tests on Go code..."
cd go
go test -v ./...
cd ..

echo "🏗️ Building .xcframework..."
chmod +x build_xcframework.sh
./build_xcframework.sh

echo "✅ Tests passed and .xcframework built successfully!"
echo ""
echo "📝 Next steps:"
echo "1. Open the Xcode project: open iosapp/GoIOSDemo.xcodeproj"
echo "2. Select a simulator or real device target"
echo "3. Build and run the app (⌘+R)"
echo ""
echo "Note: If you encounter any issues with the .xcframework not being found, make sure you've built it first with './build_xcframework.sh'"
