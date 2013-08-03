
struct	tm	{
		int	tm_sec;		/* seconds (0-59) */
		int	tm_min;		/* minutes (0-59) */
		int	tm_hour;	/* hour (0-23) */
		int	tm_mday;	/* day of month (1-31) */
		int	tm_mon;		/* month of year (0-11) */
		int	tm_year;	/* year - 1900 */
		int	tm_wday;	/* day of week (Sunday = 0) */
		int	tm_yday;	/* day of year (0-365) */
		int	tm_isdst;	/* daylight savings if nonzero */
		};

#define	_isleap(y)	((y) % 4 == 0 && (y) % 100 != 0 || (y) % 400 == 0)
