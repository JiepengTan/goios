//go:build darwin && (arm64 || amd64) && cgo && ios
// +build darwin
// +build arm64 amd64
// +build cgo
// +build ios

package main

import "C"
import (
	"unsafe"
)

// Simple is a simple function that adds two integers
func Simple(a, b int) int {
	return a + b
}

// Hello returns a greeting message
func Hello(name string) string {
	return "Hello, " + name + " from Go!"
}

// CalculateFactorial calculates the factorial of a non-negative integer
func CalculateFactorial(n int) int {
	if n <= 0 {
		return 1
	}
	return n * CalculateFactorial(n-1)
}

//export Simple_GoIOS
func Simple_GoIOS(a, b C.int) C.int {
	return C.int(Simple(int(a), int(b)))
}

//export Hello_GoIOS
func Hello_GoIOS(name *C.char) *C.char {
	goString := C.GoString(name)
	result := Hello(goString)
	// Convert Go string to C string, which requires memory allocation.
	// In real applications, this memory would need to be freed by the caller.
	cString := C.CString(result)
	// We're using unsafe.Pointer just to show that it's used (to avoid the import warning)
	// In real-world code, we might need this for more complex memory operations
	_ = unsafe.Pointer(cString)
	return cString
}

//export CalculateFactorial_GoIOS
func CalculateFactorial_GoIOS(n C.int) C.int {
	return C.int(CalculateFactorial(int(n)))
}

// TestGoroutines runs multiple goroutines and aggregates their results
func TestGoroutines(count int, workload int) int {
	// Channel to collect results from goroutines
	results := make(chan int, count)
	
	// Launch goroutines
	for i := 0; i < count; i++ {
		go func(id int) {
			// Perform some CPU work
			sum := 0
			for j := 0; j < workload; j++ {
				sum += j * id
			}
			// Send result back through channel
			results <- sum
		}(i + 1)
	}
	
	// Collect and aggregate results
	totalSum := 0
	for i := 0; i < count; i++ {
		totalSum += <-results
	}
	
	return totalSum
}

//export TestGoroutines_GoIOS
func TestGoroutines_GoIOS(count, workload C.int) C.int {
	return C.int(TestGoroutines(int(count), int(workload)))
}

// Required but not used
func main() {}
