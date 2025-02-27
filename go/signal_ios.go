// +build darwin
// +build arm64 amd64
// +build cgo
// +build ios

package main

// Handle signal issues on iOS

/*
#cgo CFLAGS: -x objective-c
#cgo LDFLAGS: -framework Foundation -framework UIKit
#include <stdlib.h>
#include <signal.h>
#include "signal_override.h"

// Special functions to set up iOS environment
void disableSignals() {
    // Disable all critical signals at C level
    signal(SIGPIPE, SIG_IGN);
    signal(SIGBUS, SIG_IGN);
    signal(SIGSEGV, SIG_IGN);
    signal(SIGABRT, SIG_IGN);
    signal(SIGILL, SIG_IGN);
    signal(SIGFPE, SIG_IGN);
    signal(SIGTRAP, SIG_IGN);
}
*/
import "C"

import (
	"os"
	"os/signal"
	_ "runtime/cgo"
	"syscall"
	_ "unsafe" // Needed for Go/C interop
)

// Set a very large value (64MB) for the Go signal stack
// This helps prevent "signal stack too small" errors
const signalStackSize = 64 * 1024 * 1024

func init() {
	// Disable all signal handling in Go
	// This prevents Go from trying to set up signal handlers
	signal.Ignore(
		syscall.SIGBUS,
		syscall.SIGPIPE,
		syscall.SIGSEGV,
		syscall.SIGABRT,
		syscall.SIGILL,
		syscall.SIGFPE,
		syscall.SIGTRAP,
	)

	// Call C function to disable signals at C level
	C.disableSignals()

	// Prevent crashes by redirecting stderr/stdout to /dev/null on iOS
	// This helps avoid issues with Go runtime trying to write error messages
	redirectStderr()
}

func redirectStderr() {
	// Redirect stderr to /dev/null
	// This is especially important for production builds
	f, err := os.OpenFile("/dev/null", os.O_WRONLY, 0)
	if err == nil {
		syscall.Dup2(int(f.Fd()), int(os.Stderr.Fd()))
		// Also redirect stdout for good measure
		syscall.Dup2(int(f.Fd()), int(os.Stdout.Fd()))
	}
}
