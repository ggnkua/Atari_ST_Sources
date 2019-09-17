/*
 *	TIME.H		Date/Time related definitions
 */

struct tm {
	int	tm_sec;		/* seconds */
	int	tm_min;		/* minutes */
	int	tm_hour;	/* hours */
	int	tm_mday;	/* day of month */
	int	tm_mon;		/* month */
	int	tm_year;	/* year - 1900 */
	int	tm_wday;	/* day of week (0=Sun..6=Sat) */
	int	tm_yday;	/* day of year */
	int	tm_isdst;	/* is daylight saving time? (always FALSE) */
};

typedef	unsigned long	TIMER;

#define	localtime	gmtime

extern	long		time();
extern	char		*ctime();
extern	struct tm	*gmtime();
extern	char		*asctime();
extern	long		cnvtime();
extern	long		start_timer();
extern	long		time_since();
