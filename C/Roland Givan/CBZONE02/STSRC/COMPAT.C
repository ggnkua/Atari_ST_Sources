/* BSDish gettimeofday() and settimeofday() calls */
/* also ftime(), which seems to be similar to gettimeofday() */

#include "compat.h"

time_t _timezone = -1;	/* holds # seconds west of GMT */

static int _dst = 0;

int
gettimeofday( tv, tzp )
	struct timeval *tv;
	struct timezone *tzp;
{
	struct timeb tp;
	int r;

	r = ftime(&tp);
	if (r) return r;

	if (tv) {
		tv->tv_sec = tp.time;
		tv->tv_usec = 0;
	}
	if (tzp) {
		tzp->tz_minuteswest = tp.timezone;
		tzp->tz_dsttime = tp.dstflag;
	}
	return 0;
}

int
ftime(tp)
	struct timeb *tp;
{
	long t = time((time_t *)0);

	tp->time = t;
	tp->millitm = 0;
	tp->timezone = (int)(_timezone / 60);
	tp->dstflag = (_dst) ? 1 : 0;

	return 0;
}

