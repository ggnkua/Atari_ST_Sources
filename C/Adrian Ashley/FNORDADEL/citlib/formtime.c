/*
 * formtime.c -- format time and date into standard formats
 *
 * 90Aug27 AA	Split off from libmisc.c
 */

#include <time.h>

char *monthTab[] = {"", "Jan", "Feb", "Mar",
			"Apr", "May", "Jun",
			"Jul", "Aug", "Sep",
			"Oct", "Nov", "Dec" };

char *_day[] = { "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat" };

/* For oldstyle days processing (netBuf.poll_day): */
char *_alt_day[] = { "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun" };

struct tm now;		/* global clock used by all clock routines */

void timeis();

char *
tod(int stdTime)
{
    static char timeBuf[20];
    int hr;
    char m;

    timeis(&now);
    if (stdTime) {
	hr = now.tm_hour;
	m = (hr >= 12) ? 'p' : 'a';
	if (hr >= 13)
	    hr -= 12;
	if (hr == 0)
	    hr = 12;
	sprintf(timeBuf, "%d:%02d %cm", hr, now.tm_min, m);
    }
    else
	sprintf(timeBuf, "%d:%02d", now.tm_hour, now.tm_min);
    return timeBuf;
}

char *
formDate(void)
{
    static char dateBuf[10];

    timeis(&now);
    sprintf(dateBuf, "%02d%s%02d", now.tm_year, monthTab[now.tm_mon + 1],
	now.tm_mday);
    return dateBuf;
}

/* day_of_week(): return the ASCII name for today. */
char *
day_of_week(struct tm *clk)
{
    return _day[clk->tm_wday];
}
