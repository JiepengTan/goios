#ifndef GoIOS_Bridging_Header_h
#define GoIOS_Bridging_Header_h

#import <GoIOS/GoIOS.h>

// Manually declare C functions if they're not properly found in the framework
// This is necessary if the automatic import isn't working
#ifdef __cplusplus
extern "C" {
#endif

// Simple adds two integers and returns the result
int Simple(int a, int b);

// Hello returns a greeting message
char* Hello(const char* name);

// CalculateFactorial calculates the factorial of a number
int CalculateFactorial(int n);

#ifdef __cplusplus
}
#endif

#endif /* GoIOS_Bridging_Header_h */
