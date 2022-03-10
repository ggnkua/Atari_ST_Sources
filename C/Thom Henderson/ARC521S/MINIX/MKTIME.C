/*
 * mktime.c
 *	++jrb
 */

#include <sys/types.h>
#include <time.h>

/*
 * days in a given year
 */
#define days_in_year(Y) (leap(Y) ? 366 : 365)

/* # of days / month in a normal year */
static unsigned int md[] = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};

static int leap (y)
int y;
{
	y += 1900;
	if ((y % 400) == 0)
	    return (1);
	if ((y % 100) == 0)
	    return (0);
	return ((y % 4) == 0);
}

/* Return the number of days between Jan 1, Base Year and the given
 * broken-down time.
 */

static unsigned long ndays (since, year, month, day)
unsigned int year, month, day;
{
	register unsigned long n = day;
	register unsigned int m, y;
	
	for (y = since; y < year; y++)
	{
		n += 365;
		if (leap (y)) n++;
	}
	for (m = 0; m < month; m++)
	    n += md[m] + ( ((m == 1) && leap(y))? 1 : 0);

	return (n);
}

/* Convert a broken-down time into seconds
 *
 */

static 
time_t tm_to_time (base_year, year, month, day, hours, mins, secs)
unsigned int base_year, year, month, day, hours, mins, secs;
{
	register time_t t;
	extern unsigned long ndays();
	
	t = (ndays(base_year, year, month, day) - 1L) * (unsigned long)86400L
	    + hours * (unsigned long)3600L + mins * (unsigned long)60L + secs;

	return t;
}

time_t mktime(tmptr)
struct tm *tmptr;
{
    return tm_to_time(70, tmptr->tm_year, tmptr->tm_mon, tmptr->tm_mday,
		      tmptr->tm_hour, tmptr->tm_min, tmptr->tm_sec);
}
