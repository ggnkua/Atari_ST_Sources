#include <time.h>
#include <mint/osbind.h>
#include <sys/time.h>

time_t time(time_t *tloc)
{
	struct timeval now;

	if (gettimeofday (&now, NULL) != 0)
		return ((time_t) -1);

	if (tloc)
		*tloc = now.tv_sec;

	return now.tv_sec;
}

