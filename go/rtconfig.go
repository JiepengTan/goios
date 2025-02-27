// +build darwin
// +build arm64 amd64
// +build cgo
// +build ios

package main

// Runtime configuration to disable signal handling
// This file configures Go's runtime behavior for iOS

/*
#cgo CFLAGS: -x objective-c
#cgo LDFLAGS: -framework Foundation -framework UIKit
#include <stdlib.h>

// iOS app launch callback to initialize our runtime
__attribute__((constructor)) static void ios_init(void) {
    // Perform pre-main initialization for iOS
    // This runs before any Go code
}
*/
import "C"

import (
	"runtime"
	"runtime/debug"
)

func init() {
	// Force garbage collection to run more aggressively
	// This can help prevent memory issues on iOS
	debug.SetGCPercent(10)

	// Do NOT set max threads - let Go manage its own threads
	// The previous limit of 5 was still too restrictive
	
	// Limit the number of OS threads that Go tries to use for user code
	// This is different from SetMaxThreads which limits total threads
	// Setting to 2 provides a good balance for mobile apps
	runtime.GOMAXPROCS(2)
}
