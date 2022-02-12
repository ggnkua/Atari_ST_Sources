#include <lib.h>
#include <time.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>

#define toint(X)  (X - '0')

PRIVATE char      timebuf[26];

PRIVATE char      *day[]   = {"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"};
PRIVATE char      *month[] = {"Jan", "Feb", "Mar", "Apr", "May", "Jun",
                              "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"};
void tzset();

char *asctime(time)
register _CONST struct tm *time;
/*
 *      Convert <time> structure value to a string.  The same format, and
 *      the same internal buffer, as for ctime() is used for this function.
 */
{
	if (time == (struct tm *)NULL)
	     strcpy(timebuf, "??? ??? ?? ??:??:?? ????\n");
	else
             sprintf(timebuf, "%.3s %.3s%3d %02d:%02d:%02d %04d\n",
                day[time->tm_wday], month[time->tm_mon], time->tm_mday,
                time->tm_hour, time->tm_min, time->tm_sec, 1900+time->tm_year);
        return(timebuf);
}

char *ctime(rawtime)
_CONST time_t *rawtime;
/*
 *      Convert <rawtime> to a string.  A 26 character fixed field string
 *      is created from the raw time value.  The following is an example
 *      of what this string might look like:
 *              "Wed Jul 08 18:43:07 1987\n\0"
 *      A 24-hour clock is used, and due to a limitation in the ST system
 *      clock value, only a resolution of 2 seconds is possible.  A pointer
 *      to the formatted string, which is held in an internal buffer, is
 *      returned.
 */
{
        return(asctime(localtime(rawtime)));
}

/* mktime, localtime, gmtime */
/* written by ERS and placed in the public domain */

#define SECS_PER_MIN    (60L)
#define SECS_PER_HOUR   (60*SECS_PER_MIN)
#define SECS_PER_DAY    (24*SECS_PER_HOUR)
#define SECS_PER_YEAR   (365*SECS_PER_DAY)
#define SECS_PER_LEAPYEAR (SECS_PER_DAY + SECS_PER_YEAR)

PRIVATE
int days_per_mth[12] = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 };

PRIVATE _PROTOTYPE( time_t tzoffset, (char *s, int *hasdst));
PRIVATE _PROTOTYPE( int indst, (_CONST struct tm *t));

time_t timezone = -1;	/* holds # seconds west of GMT */
PRIVATE int dst = -1;	/* whether dst holds in current timezone */

/*
 * FIXME: none of these routines is very efficient. Also, none of them
 * handle dates before Jan 1, 1970.
 *
 */

/*
 * mktime: take a time structure representing the local time (such as is
 *  returned by localtime() and convert it into the standard representation
 *  (as seconds since midnight Jan. 1 1970, GMT).
 *
 */

time_t mktime(t)
_CONST struct tm *t;
{
        time_t s;
        int y;

        y = t->tm_year - 70;
        if (y < 0)      /* year before 1970 */
                return (time_t) -1;
        s = (SECS_PER_YEAR * y) + ( ((y+1)/4) * SECS_PER_DAY);
                /* extra days for leap years */
        if ( (y+2)%4 )
                days_per_mth[1] = 28;
        else
                days_per_mth[1] = 29;

        for (y = 0; y < t->tm_mon; y++)
                s += SECS_PER_DAY * days_per_mth[y];

        s += (t->tm_mday - 1) * SECS_PER_DAY;
        s += t->tm_hour * SECS_PER_HOUR;
        s += t->tm_min * SECS_PER_MIN;
        s += t->tm_sec;

/* Now adjust for the time zone and possible daylight savings time */
	if (timezone == -1)
		tzset();
        s += timezone;
        if (dst == 1 && indst(t))
                s -= SECS_PER_HOUR;

        return s;
}


PRIVATE struct tm the_time;

struct tm *gmtime(t)
_CONST time_t *t;
{
        struct tm       *stm = &the_time;
        time_t  time = *t;
        int     year, mday, i;

        if (time < 0)   /* negative times are bad */
                return 0;
        stm->tm_wday = ((time/SECS_PER_DAY) + 4) % 7;

        year = 70;
        for (;;) {
                if (time < SECS_PER_YEAR) break;
                if ((year % 4) == 0) {
                        if (time < SECS_PER_LEAPYEAR)
                                break;
                        else
                                time -= SECS_PER_LEAPYEAR;
                }
                else
                        time -= SECS_PER_YEAR;
                year++;
        }
        stm->tm_year = year;
        mday = stm->tm_yday = time/SECS_PER_DAY;
        days_per_mth[1] = (year % 4) ? 28 : 29;
        for (i = 0; mday >= days_per_mth[i]; i++)
                mday -= days_per_mth[i];
        stm->tm_mon = i;
        stm->tm_mday = mday + 1;
        time = time % SECS_PER_DAY;
        stm->tm_hour = time/SECS_PER_HOUR;
        time = time % SECS_PER_HOUR;
        stm->tm_min = time/SECS_PER_MIN;
        stm->tm_sec = time % SECS_PER_MIN;
        stm->tm_isdst = 0;

        return stm;
}

/* given a standard time, convert it to a local time */

struct tm *localtime(t)
_CONST time_t *t;
{
        struct tm *stm;
        time_t offset;  /* seconds between local time and GMT */

	if (timezone == -1) tzset();
        offset = *t - timezone;
        stm = gmtime(&offset);
	if (stm == (struct tm *)NULL) return stm; /* check for illegal time */
        stm->tm_isdst = (dst == -1) ? -1 : 0;

        if (dst == 1 && indst(stm)) {   /* daylight savings time in effect */
                stm->tm_isdst = 1;
                if (++stm->tm_hour > 23) {
                        stm->tm_hour -= 24;
                        stm->tm_wday = (stm->tm_wday + 1) % 7;
                        stm->tm_yday++;
                        stm->tm_mday++;
                        if (stm->tm_mday > days_per_mth[stm->tm_mon]) {
                                stm->tm_mday = 1;
                                stm->tm_mon++;
                        }
                }
        }
        return stm;
}

/* set the timezone and dst flag to the local rules */

void tzset()
{
	timezone = tzoffset(getenv("TZ"), &dst);
}

/*
 * determine the difference, in seconds, between the given time zone
 * and Greenwich Mean. As a side effect, the integer pointed to
 * by hasdst is set to 1 if the given time zone follows daylight
 * savings time, 0 if there is no DST.
 *
 * Time zones are given as strings of the form
 * "[TZNAME][h][:m][TZDSTNAME]" where h:m gives the hours:minutes
 * east of GMT for the timezone (if [:m] does not appear, 0 is assumed).
 * If the final field, TZDSTNAME, appears, then the time zone follows
 * daylight savings time.
 *
 * Example: EST5EDT would represent the N. American Eastern time zone
 *          CST6CDT would represent the N. American Central time zone
 *          NFLD3:30NFLD would represent Newfoundland time (one and a
 *              half hours ahead of Eastern).
 *          OZCST-9:30 would represent the Australian central time zone.
 *              (which, so I hear, doesn't have DST).
 *
 * NOTE: support for daylight savings time is currently very bogus.
 * It's probably best to do without, unless you live in North America.
 *
 */

PRIVATE time_t tzoffset(s, hasdst)
char *s;
int  *hasdst;
{
        time_t off = 0;
        int x, sgn = 1;

        *hasdst = -1;                   /* Assume unknown */
        if (!s || !*s)
                return 0;               /* Assume GMT */
        *hasdst = 0;

        while (isalpha(*s)) s++;        /* skip name */
        x = 0;
        if (*s == '-') {
                sgn = -1;
                s++;
        }
        while (isdigit(*s)) {
                x = 10 * x + toint(*s);
                s++;
        }
        off = x * SECS_PER_HOUR;
        if (*s == ':') {
                x = 0;
                s++;
                while (isdigit(*s)) {
                        x = 10 * x + toint(*s);
                        s++;
                }
	        off += (x * SECS_PER_MIN);
        }
        if (isalpha(*s))
                *hasdst = 1;
        return sgn * off;
}

/*
 * Given a tm struct representing the local time, determine whether
 * DST is currently in effect. This should only be
 * called if it is known that the time zone indeed supports DST.
 *
 * FIXME: For now, assume that everyone follows the North American
 *   time zone rules, all the time. This means daylight savings
 *   time is assumed to be in effect from the first Sunday in April
 *   to the last Sunday in October. Prior to 1987, the old rules
 *   (last Sunday in April to last Sunday in Oct.) are used, even when
 *   (as in 1974) they're not applicable. Sorry.
 *
 */

PRIVATE int indst(t)
_CONST struct tm *t;
{
        if (t->tm_mon == 3) {           /* April */
/* before 1987, see if there's another sunday in the month */
                if (t->tm_year < 87 && t->tm_wday + 30 - t->tm_mday < 7)
                        return 1;       /* no there isn't */
/* after 1987, see if a sunday has happened yet */
                if (t->tm_wday - t->tm_mday < 0)
                        return 1;       /* yep */
                return 0;
        }
        if (t->tm_mon == 9) {           /* October */
                if (t->tm_wday + 31 - t->tm_mday < 7)
                        return 0;       /* there are no more sundays */
                return 1;
        }
/* Otherwise, see if it's a month between April and October exclusive */
        return (t->tm_mon > 3 && t->tm_mon < 9);
}

/* return difference between two time_t types -- ERS*/

double difftime(t1, t2)
time_t t1, t2;
{
	return (double) (t2 - t1);
}
