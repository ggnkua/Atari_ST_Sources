/*
 * DATE/TIME FUNCTIONS:
 *
 *	To use the functions in this section, you must include "TIME.H"
 *	in your source file.
 */

#include <stdio.h>
#include <time.h>

static struct tm	the_time;
static struct tm	jan_1;
static char		timebuf[26] =
			"Day Mon dd hh:mm:ss yyyy\n";
static char		*day[] =
			{"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"};
static char		*month[] =
			{"Jan", "Feb", "Mar", "Apr", "May", "Jun",
			"Jul", "Aug", "Sep", "Oct", "Nov", "Dec"};

long julian_date(time)
	register struct tm *time;
/*
 *	Number of days since the base date of the Julian calendar.
 */
	{
	register long c, y, m, d;

	y = time->tm_year + 1900;	/* year - 1900 */
	m = time->tm_mon + 1;		/* month, 0..11 */
	d = time->tm_mday;		/* day, 1..31 */
	if(m > 2)
		m -= 3L;
	else
		{
		m += 9L;
		y -= 1L;
		}
	c = y / 100L;
	y %= 100L;
	return(	((146097L * c) >> 2) +
		((1461L * y) >> 2) +
		(((153L * m) + 2) / 5) +
		d +
		1721119L );
	}

time_t time(rawtime)
	register long *rawtime;
/*
 *	Get the current system clock date/time value.  Under many systems,
 *	this function returns the number of seconds since 00:00:00 GMT on
 *	Jan 1, 1970.  This implementation returns an encoded date/time
 *	value instead.  Therefore any programs which depend on this value
 *	being a number of seconds will not work properly.  However, other
 *	functions in this section which make use of the raw time value
 *	returned by time() are implemented to be compatible with this
 *	encoding, and will work properly.  In addition to returning the
 *	raw time value, if the <rawtime> pointer in not NULL, the value
 *	is stored in the long <rawtime> points to.
 */
	{
	register time_t t;

	t = (gemdos(0x2C) << 16) | (gemdos(0x2A) & 0xFFFFL);
	if(rawtime)
		*rawtime = t;
	return(t);
	}

struct tm *gmtime()
/*
 *	Can't determine Greenwich Mean Time, so return NULL
 *	as specified by ANSI standard.
 */
	{
	return(NULL);
	}

struct tm *localtime(rawtime)
	time_t *rawtime;
/*
 *	Convert <rawtime> to fill time structure fields.  A pointer to an
 *	internal structure is returned.  Refer to "TIME.H" for the values
 *	of the various structure fields.
 */
	{
	register time_t time, jdate, jjan1;
	register struct tm *t, *j;

	time = *rawtime;
	t = &the_time;
	j = &jan_1;
	t->tm_mday = (time & 0x1F);
	time >>= 5;
	t->tm_mon = (time & 0x0F) - 1;
	time >>= 4;
	t->tm_year = (time & 0x7F) + 80;
	time >>= 7;
	t->tm_sec = (time & 0x1F) << 1;
	time >>= 5;
	t->tm_min = (time & 0x3F);
	time >>= 6;
	t->tm_hour = (time & 0x1F);
	jdate = julian_date(t);
	*j = *t;
	j->tm_mon = 0;		/* set up Jan 1 */
	j->tm_mday = 1;
	jjan1 = julian_date(j);
	t->tm_wday = (jdate + 1) % 7;
	t->tm_yday = jdate - jjan1;
	t->tm_isdst = (-1);
	return(t);
	}

char *asctime(time)
	register struct tm *time;
/*
 *	Convert <time> structure value to a string.  The same format, and
 *	the same internal buffer, as for ctime() is used for this function.
 */
	{
	sprintf(timebuf, "%.3s %.3s%3d %02d:%02d:%02d %04d\n",
		day[time->tm_wday], month[time->tm_mon], time->tm_mday,
		time->tm_hour, time->tm_min, time->tm_sec, 1900+time->tm_year);
	return(timebuf);
	}

char *ctime(rawtime)
	time_t *rawtime;
/*
 *	Convert <rawtime> to a string.  A 26 character fixed field string
 *	is created from the raw time value.  The following is an example
 *	of what this string might look like:
 *		"Wed Jul 08 18:43:07 1987\n\0"
 *	A 24-hour clock is used, and due to a limitation in the ST system
 *	clock value, only a resolution of 2 seconds is possible.  A pointer
 *	to the formatted string, which is held in an internal buffer, is
 *	returned.
 */
	{
	char *asctime();
	struct tm *localtime();

	return(asctime(localtime(rawtime)));
	}
