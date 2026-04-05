#ifndef _TIME_H_
#define _TIME_H_

#include <stddef.h>
#include <stdio.h>
#include <sys/types.h>

#define CLOCKS_PER_SEC 200
#define CLK_TCK	       200

#ifndef __time_t_defined
typedef __time_t time_t;
#define __time_t_defined 1
#endif
#ifndef __clock_t_defined
typedef __clock_t clock_t;
#define __clock_t_defined 1
#endif
#ifndef __suseconds_t_defined
typedef __suseconds_t suseconds_t;
#define __suseconds_t_defined 1
#endif


struct tm
{
	int tm_sec;         /* seconds */
	int tm_min;         /* minutes */
	int tm_hour;        /* hours */
	int tm_mday;        /* day of the month */
	int tm_mon;         /* month */
	int tm_year;        /* year */
	int tm_wday;        /* day of the week */
	int tm_yday;        /* day in the year */
	int tm_isdst;       /* daylight saving time */
};

struct timeval
{
	time_t tv_sec;			/* seconds */
	suseconds_t tv_usec;	/* microseconds */
};

struct timezone
{
	int tz_minuteswest;		/* minutes west of GMT */
	int tz_dsttime;			/* Nonzero if DST is ever in effect */
};

extern long timezone;
extern char* tzname[2];

time_t time(time_t *tloc);
void tzset(void);
clock_t clock(void);
time_t mktime(struct tm *tm);
struct tm* gmtime(const time_t* timep);
struct tm* localtime(const time_t* timep);
size_t strftime(char* s, size_t smax, const char* fmt, const struct tm* tp);

#endif /* _TIME_H_ */
