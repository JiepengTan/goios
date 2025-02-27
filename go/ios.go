// +build darwin
// +build arm64 amd64
// +build cgo
// +build ios

package main

// This file contains iOS-specific code and stubs to make the Go runtime work on iOS

/*
#cgo CFLAGS: -x objective-c
#cgo LDFLAGS: -framework Foundation -framework UIKit
#include <stdlib.h>
#include <stdint.h>
#include <UIKit/UIKit.h>

// The actual implementations are in darwin_stubs.c
*/
import "C"

// Empty file - just imports the CGO directives needed for iOS
