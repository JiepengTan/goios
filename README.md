# Go to iOS Integration Demo (.xcframework)

This demo shows how to compile Go code into an .xcframework for integration with iOS applications.

## Project Structure

```
goios/
├── go/                      # Go source code
│   ├── goios.go             # Main Go functions
│   ├── goios_export.go      # Go functions exported to C
│   ├── goios_bridge.c       # C bridge implementation
│   ├── goios_bridge.h       # C header file
│   └── go.mod               # Go module file
├── iosapp/                  # iOS demo application
│   ├── GoIOSDemo/           # Demo app source files
│   └── GoIOSDemo.xcodeproj  # Xcode project
├── build_xcframework.sh     # Script to build .xcframework
├── test_go_xcframework.sh   # Script to test and build
└── README.md                # This file
```

## Prerequisites

- macOS (required for iOS development)
- Xcode (14.0 or later recommended)
- Go (1.17 or later)
- Basic knowledge of Go and iOS development

## How It Works

1. **Go Code**: The Go code in the `go/` directory provides simple functions that will be exposed to iOS.
2. **C Bridge**: We use a C bridge to connect Go and iOS, as Go can be compiled to C-compatible libraries.
3. **XCFramework**: The `.xcframework` format allows for distributing binary libraries that work across different architectures (simulator and device).

## Step-by-Step Process

### 1. Writing Go Code

First, we create Go functions that we want to expose to iOS. We export them using special comment annotations (`//export`).

### 2. Creating C Bridge

We create C wrapper functions in `goios_bridge.c` and a header file `goios_bridge.h` that provide the interface iOS code will use.

### 3. Building the XCFramework

The `build_xcframework.sh` script performs the following steps:
- Compiles Go code to C archives for different architectures (iOS device arm64, simulator x86_64 and arm64)
- Creates "fat" libraries by combining architectures
- Packages the libraries into `.framework` bundles
- Combines the frameworks into a single `.xcframework`

### 4. Using in iOS

The iOS demo app shows how to:
- Link against the `.xcframework`
- Use a bridging header to expose C functions to Swift
- Create a Swift wrapper class to make calls to the Go functions

## Building and Running

1. Build the .xcframework:
```bash
chmod +x build_xcframework.sh
./build_xcframework.sh
```

2. Test and build (optional):
```bash
chmod +x test_go_xcframework.sh
./test_go_xcframework.sh
```

3. Open the Xcode project:
```bash
open iosapp/GoIOSDemo.xcodeproj
```

4. Build and run the iOS app in Xcode.

## Demo App Features

The demo iOS app demonstrates:
- Addition of two numbers (using Go's `Simple` function)
- String handling with "Say Hello" (using Go's `Hello` function)
- Factorial calculation (using Go's `CalculateFactorial` function)

## Troubleshooting

- **Framework not found**: Make sure you've run `build_xcframework.sh` before opening the Xcode project.
- **Build errors**: Ensure you have the correct versions of Xcode and Go installed.
- **Code signing issues**: You may need to adjust the signing settings in the Xcode project.

## Further Improvements

- Add more complex Go functions to demonstrate advanced use cases
- Add proper error handling in the C bridge
- Add automated tests for the iOS app
- Create a module system for packaging multiple Go libraries