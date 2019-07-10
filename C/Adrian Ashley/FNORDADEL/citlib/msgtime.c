/*
 * msgtime.c -- parse date and/or time into a time_t
 *
 * 91Jan08 AA	Created.
 */

#include "ctdl.h"
#include "citlib.h"

/*
 * msgtime() - parse date/time into time_t
 *
 * Takes a date string and/or a time string in standard citadel format and
 * turns it into a time_t.  If year is absent from date string the current
 * year will be used; if the date is absent the entire current date will be
 * used; if the time is absent the current time will be used.  Returns ERROR
 * if anything was in a bad format or out-of-range.
 */

time_t
msgtime(register char *date, register char *thyme)
{
    struct tm msgt, *curt;
    time_t curtime;
    int year = 0, mon, mday = 0, hour, min, sec;
    char apm;
    int count;

    curtime = time(NULL);
    curt = localtime(&curtime);		/* load current time into curt */

    zero_struct(msgt);

    if (*date) {
	if (!isdigit(*date))		/* there is no year */
	    year = curt->tm_year;
	else
	    while (isdigit(*date)) {	/* parse the year portion */
		year = (year * 10) + (*date - '0');
		date++;
	    }
	mon = 1;
	while (strnicmp(date, monthTab[mon], 3) && ++mon <= 12)
	    ;
	if (mon > 12)
	    return ERROR;
	while (!isdigit(*date))		/* skip over month */
	    date++;
	while (isdigit(*date)) {	/* parse the day portion */
	    mday = (mday * 10) + (*date - '0');
	    date++;
	}
	if (mday < 1 || mday > 31)
	    return ERROR;
    }
    else {				/* no date supplied, so use today */
	year = curt->tm_year;
	mon = curt->tm_mon + 1;
	mday = curt->tm_mday;
    }

    if (*thyme) {
	count = sscanf(thyme, "%d:%d:%d", &hour, &min, &sec);
	if (count < 3) {
	    sec = 0;
	    count = sscanf(thyme, "%d:%d %cm", &hour, &min, &apm);
	    if (count < 2)
		return ERROR;
	    if (count == 3) {
		if (hour == 12)	/* allow for 12:xx */
		    hour = 0;
		if (apm == 'p')
		    hour += 12;
		else if (apm != 'a')
		    return ERROR;
	    }
	}
    }
    else {			/* no time supplied, so use 'now' */
	hour = curt->tm_hour;
	min = curt->tm_min;
	sec = curt->tm_sec;
    }

    msgt.tm_year = year;
    msgt.tm_mon = mon - 1;
    msgt.tm_mday = mday;
    msgt.tm_hour = hour;
    msgt.tm_min = min;
    msgt.tm_sec = sec;
    return mktime(&msgt);
}
