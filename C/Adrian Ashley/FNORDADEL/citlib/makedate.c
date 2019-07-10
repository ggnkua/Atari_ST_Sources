/*
 * makedate.c -- turn a time_t into a standard citadel date string
 * 
 * 91Jan08 AA	Created.
 */

#include "ctdl.h"
#include "citlib.h"

/*
 * makedate() - form time_t into `90Jan02'-like date, plus time (optionally)
 */
char *
makedate(time_t msgt, int time_too)
{
    static char buffer[20];
    register struct tm *date;

    if ((date = localtime(&msgt)) == NULL)
	return "";
    sprintf(buffer, "%02d%s%02d", date->tm_year, monthTab[date->tm_mon + 1],
	date->tm_mday);
    if (time_too) {
	char timebuf[10], m;
	register int hour = date->tm_hour;

	m = (hour >= 12) ? 'p' : 'a';
	if (hour > 12)
	    hour -= 12;
	if (hour == 0)
	    hour = 12;
	sprintf(timebuf, " %d:%02d %cm", hour, date->tm_min, m);
	strcat(buffer, timebuf);
    }
    return buffer;
}
