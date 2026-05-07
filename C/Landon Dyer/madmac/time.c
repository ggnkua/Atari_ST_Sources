/*
 *  Get DOS-format time and date
 *  Compute time-string from time,
 *  Compute date-string from date.
 *
 */
#include "as.h"

#ifdef BSD
#include <sys/time.h>
#endif

#ifdef ST
#include <osbind.h>
#endif


/*
 *  Return GEMDOS-format date
 *
 */
VALUE dos_date()
{
	register VALUE v;
	register struct tm *tm;

#ifdef BSD
	long tloc;

	time(&tloc);
	tm = localtime(&tloc);
	v = ((tm->tm_year - 80) << 9) |
		  ((tm->tm_mon+1) << 5) |
		  tm->tm_mday;
#endif

#ifdef ST
	v = Tgetdate();
#endif

	return v;
}


/*
 *  Return GEMDOS-format time
 *
 */
VALUE dos_time()
{
	register VALUE v;
	register struct tm *tm;

#ifdef BSD
	long tloc;

	time(&tloc);
	tm = localtime(&tloc);
	v = (tm->tm_hour << 11) | (tm->tm_min) << 5 | tm->tm_sec;
#endif

#ifdef ST
	v = Tgettime();
#endif

	return v;
}


time_string(buf, time)
char *buf;
register VALUE time;
{
	register int hour;
	char *ampm;

	hour = (time >> 11);
	if (hour > 12) {
		hour -= 12;
		ampm = "pm";
	} else ampm = "am";

	sprintf(buf, "%d:%02d:%02d %s",
			hour, 
			(int)((time >> 5) & 0x3f),
			(int)((time & 0x1f) << 1),
			ampm);
}


static char *month[16] = {
	"",
	"Jan",
	"Feb",
	"Mar",
	"Apr",
	"May",
	"Jun",
	"Jul",
	"Aug",
	"Sep",
	"Oct",
	"Nov",
	"Dec",
	"",
	"",
	""
};

date_string(buf, date)
char *buf;
register VALUE date;
{
	sprintf(buf, "%d-%s-%d",
			(int)(date & 0x1f),
			month[(date >> 5) & 0xf],
			(int)((date >> 9) + 1980));
}
