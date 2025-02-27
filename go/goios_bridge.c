#include <stdlib.h>
#include <stdio.h>
#include "goios_bridge.h"
#include "ios_adapter_complete.h"

// iOS app initialization - runs when the library is loaded
__attribute__((constructor)) void initialize_ios_bridge(void) {
    // Configure iOS app before Go runtime starts
    initializeIOSEnvironment();
}

// These functions are implemented in Go and exported to C
extern int Simple_GoIOS(int a, int b);
extern char* Hello_GoIOS(const char* name);
extern int CalculateFactorial_GoIOS(int n);
extern int TestGoroutines_GoIOS(int count, int workload);

// C wrapper for the Simple Go function
int Simple(int a, int b) {
    return Simple_GoIOS(a, b);
}

// C wrapper for the Hello Go function
char* Hello(const char* name) {
    return Hello_GoIOS(name);
}

// C wrapper for the CalculateFactorial Go function
int CalculateFactorial(int n) {
    return CalculateFactorial_GoIOS(n);
}

// C wrapper for the TestGoroutines Go function
int TestGoroutines(int count, int workload) {
    return TestGoroutines_GoIOS(count, workload);
}
