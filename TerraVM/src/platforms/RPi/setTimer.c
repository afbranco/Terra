#include <signal.h>
#include <sys/time.h>
#include <unistd.h>

int getTimer(int which, struct itimerval *curr_value)
{
	return getitimer(which, curr_value);
}

void setTimer(int which, const struct itimerval *new_value, struct itimerval *old_value)
{
	setitimer(which, new_value, old_value);
} 

void setSignal(int signum, __sighandler_t handler)
{
	signal(signum, handler);

}
