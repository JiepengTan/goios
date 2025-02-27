#ifndef GOIOS_BRIDGE_H
#define GOIOS_BRIDGE_H

// Simple adds two integers and returns the result
int Simple(int a, int b);

// Hello returns a greeting message
char* Hello(const char* name);

// CalculateFactorial calculates the factorial of a number
int CalculateFactorial(int n);

// TestGoroutines tests Go's goroutine functionality on iOS
// count: number of goroutines to launch
// workload: amount of work each goroutine performs
int TestGoroutines(int count, int workload);

#endif // GOIOS_BRIDGE_H
