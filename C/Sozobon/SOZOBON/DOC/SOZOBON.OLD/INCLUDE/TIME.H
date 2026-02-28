/*
 *	TIME.H		Date/Time related definitions
 */

#ifndef	TIME_H
#define	TIME_H

#include <types.h>

#define	CLK_TCK		((clock_t) 200)		/* clock ticks per second */

struct tm
	{
	int	tm_sec;		/* seconds (0..59) */
	int	tm_min;		/* minutes (0..59) */
	int	tm_hour;	/* hours (0..23) */
	int	tm_mday;	/* day of month (1..31) */
	int	tm_mon;		/* month (0..11) */
	int	tm_year;	/* year - 1900 */
	int	tm_wday;	/* day of week (0=Sun..6=Sat) */
	int	tm_yday;	/* day of year (0..365) */
	int	tm_isdst;	/* daylight saving? (always -1=unknown) */
	};

extern	char		*asctime();
extern	struct tm	*gmtime();	/* always returns NULL */
extern	struct tm	*localtime();
extern	time_t		time();
extern	char		*ctime();
extern	time_t		mktime();
/* extern	long		difftime();	*/
/* extern	int		strftime();	*/
extern	void		stime();
extern	int		utime();
extern	clock_t		clock();
extern	long		julian_date();
extern	clock_t		start_timer();
extern	clock_t		time_since();

#endif TIME_H
