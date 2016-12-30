#ifndef SET_TIMER_H
#define SET_TIMER_H

#include <stdio.h>
#include <inttypes.h>
#include <signal.h>
#include <sys/time.h>
#include <time.h>
#include <unistd.h>

extern void setSignal(int signum, __sighandler_t handler);
extern void setTimer(int which, const struct itimerval *new_value, struct itimerval *old_value);
extern int getTimer(int which, const struct itimerval *curr_value);

#endif /* SET_TIMER_H */
