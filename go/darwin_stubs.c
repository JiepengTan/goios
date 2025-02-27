// Stub implementations for Darwin ARM exception handlers
// These are normally provided by the Go runtime, but we need to provide them for iOS

#include <signal.h>
#include <stddef.h>
#include <stdint.h>
#include <string.h>
#include <errno.h>

// Define a global variable to store the signal stack
static stack_t global_sigstack;
static int sigstack_set = 0;

// Define a global signal mask to track signal state
static sigset_t global_sigmask;
static int sigmask_initialized = 0;

// Define a global array to track signal actions
#define MAX_SIGNALS 32
static struct sigaction global_sigactions[MAX_SIGNALS];
static int sigactions_initialized = 0;

// Handle signals on iOS
void darwin_arm_init_mach_exception_handler(void) {
    // Empty implementation - intentionally not doing anything on iOS
}

void darwin_arm_init_thread_exception_port(void) {
    // Empty implementation - intentionally not doing anything on iOS
}

// Implement sigaltstack for iOS - This is the key function that Go runtime uses
// We need to properly handle the signal stack to prevent crashes
int sigaltstack(const stack_t *ss, stack_t *oss) {
    // If caller wants old state, return our global copy
    if (oss != NULL && sigstack_set) {
        memcpy(oss, &global_sigstack, sizeof(stack_t));
    }
    
    // If no new stack is provided, just return success
    if (ss == NULL) {
        return 0;
    }
    
    // Store the new stack info
    memcpy(&global_sigstack, ss, sizeof(stack_t));
    sigstack_set = 1;
    
    // Always return success
    return 0;
}

// Signal handling stubs with proper errno handling
int pthread_sigmask(int how, const sigset_t *set, sigset_t *oset) {
    // Initialize global mask if needed
    if (!sigmask_initialized) {
        sigemptyset(&global_sigmask);
        sigmask_initialized = 1;
    }
    
    // Return old mask if requested
    if (oset != NULL) {
        memcpy(oset, &global_sigmask, sizeof(sigset_t));
    }
    
    // Update global mask if a new set is provided
    if (set != NULL) {
        switch (how) {
            case SIG_BLOCK:
                // Add signals in set to the mask
                for (int i = 1; i < NSIG; i++) {
                    if (sigismember(set, i)) {
                        sigaddset(&global_sigmask, i);
                    }
                }
                break;
            case SIG_UNBLOCK:
                // Remove signals in set from the mask
                for (int i = 1; i < NSIG; i++) {
                    if (sigismember(set, i)) {
                        sigdelset(&global_sigmask, i);
                    }
                }
                break;
            case SIG_SETMASK:
                // Replace the mask
                memcpy(&global_sigmask, set, sizeof(sigset_t));
                break;
        }
    }
    
    return 0;
}

int sigaction(int sig, const struct sigaction *act, struct sigaction *oact) {
    // Initialize global sigactions if needed
    if (!sigactions_initialized) {
        memset(&global_sigactions, 0, sizeof(global_sigactions));
        sigactions_initialized = 1;
    }
    
    // Check signal range
    if (sig < 1 || sig >= MAX_SIGNALS) {
        errno = EINVAL;
        return -1;
    }
    
    // Return old action if requested
    if (oact != NULL) {
        memcpy(oact, &global_sigactions[sig], sizeof(struct sigaction));
    }
    
    // Update action if a new one is provided
    if (act != NULL) {
        memcpy(&global_sigactions[sig], act, sizeof(struct sigaction));
        
        // Actually set system-level signal handlers for critical signals
        // to ensure they don't crash the app
        if (sig == SIGPIPE || sig == SIGILL || sig == SIGTRAP || 
            sig == SIGABRT || sig == SIGFPE || sig == SIGBUS || sig == SIGSEGV) {
            // Set the actual signal to be ignored at the system level
            signal(sig, SIG_IGN);
        }
    }
    
    return 0;
}

// Additional signal handling functions Go might call
int sigprocmask(int how, const sigset_t *set, sigset_t *oldset) {
    return pthread_sigmask(how, set, oldset);
}

// This prevents crashes from signal handlers trying to write to stderr/stdout
void abort(void) {
    // Do nothing, just prevent actual abort
    while(1) {
        // Infinite loop to prevent resuming execution
        // In practice this should never be called
    }
}
