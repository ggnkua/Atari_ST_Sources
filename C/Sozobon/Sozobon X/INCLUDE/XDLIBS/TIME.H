/*
 * @(#)time.h, xdLibs, SozobonX
 *
 * Date/Time related definitions
 */

#ifndef	_TIME_H
#define	_TIME_H

#include <types.h>

/* 
 * TYPE time_t, defined in types.h is used for rawtime values.
 * These are not seconds since 1970, but a encoded time value
 * with DATE in highword and TIME in lowword for time comparisons
 */

#define	CLK_TCK		((clock_t) 200)		/* clock ticks per second */

struct tm
	{
	int	tm_sec;		/* seconds (0..61) */
	int	tm_min;		/* minutes (0..59) */
	int	tm_hour;	/* hours (0..23) */
	int	tm_mday;	/* day of month (1..31) */
	int	tm_mon;		/* month (0..11) */
	int	tm_year;	/* year - 1900 */
	int	tm_wday;	/* day of week (0=Sun..6=Sat) */
	int	tm_yday;	/* day of year (0..365) */
	int	tm_isdst;	/* daylight saving? (TRUE/FALSE/-1=unknown) */
};

extern	time_t		time(time_t *rawtime);

extern	char		*asctime(struct tm *time);
extern	char		*ctime(time_t *rawtime);

extern	struct tm	*gmtime(void);	/* this time always returns NULL */

extern	struct tm	*localtime(time_t *rawtime);
extern	time_t		mktime(struct tm *time);
extern	long		julian_date(struct tm *time);

/* missing */
/* extern	double		difftime(time_t time1, time_t time2);	*/
/* extern	int		strftime(char *s, size_t maxsize,
					const char *format, const struct tm *timeptr);	*/

extern	int		stime(time_t *rawtime);
extern	int		utime(char *pathname, time_t *rawtime);

extern	clock_t		clock(void);
extern	clock_t		start_timer(clock_t *);
extern	clock_t		time_since(clock_t *);

#endif 	/* _TIME_H	*/

