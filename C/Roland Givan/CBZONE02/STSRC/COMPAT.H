#ifndef _TIME_T
#define _TIME_T long
typedef _TIME_T		time_t;
#endif

struct timeval {
	long	tv_sec;		/* seconds */
	long	tv_usec;	/* microseconds */
};

struct timezone {
	int	tz_minuteswest;	/* minues west of GMT */
	int	tz_dsttime;	/* daylight savings time correction */
};

struct timeb {
	long		time;		/* seconds since Jan 1., 1970 */
	short		millitm;	/* milliseconds since "time" */
	short		timezone;	/* minutes west of GMT */
	short		dstflag;	/* if time zone can have DST */
};
