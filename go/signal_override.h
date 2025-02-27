#ifndef SIGNAL_OVERRIDE_H
#define SIGNAL_OVERRIDE_H

#include <signal.h>

// We no longer need to override these functions because we're now
// implementing them directly in darwin_stubs.c with the correct names
// that the Go runtime expects.

// Additional functions we might need to stub
int sigprocmask(int how, const sigset_t *set, sigset_t *oldset);

#endif /* SIGNAL_OVERRIDE_H */
