#ifndef IOS_INIT_H
#define IOS_INIT_H

// This header provides initialization for the iOS application
#include <signal.h>

// Function to configure iOS app before Go runtime starts
static inline void configureiOSApp(void) {
    // Ignore specific signals that can crash the app
    signal(SIGPIPE, SIG_IGN);
    signal(SIGBUS, SIG_IGN);
    
    // Any other iOS-specific configuration can go here
}

#endif /* IOS_INIT_H */
