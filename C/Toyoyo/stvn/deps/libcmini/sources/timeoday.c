#include <time.h>
#include <string.h>
#include <mint/osbind.h>
#include <sys/time.h>

int gettimeofday(struct timeval *tp, struct timezone *tzp)
{
	unsigned short tos_time;
	unsigned short tos_date;
	struct tm now;

	tos_time = Tgettime();
	tos_date = Tgetdate();

	now.tm_sec = (tos_time & 0x1f) * 2;
	now.tm_min = (tos_time >> 5) & 0x3f;
	now.tm_hour = tos_time >> 11;
	now.tm_mday = tos_date & 0x1f;
	now.tm_mon = ((tos_date >> 5) & 0xf) - 1;
	now.tm_year = (tos_date >> 9) + 80;
	now.tm_isdst = -1;

	if (tp != NULL)
	{
		tp->tv_sec = mktime(&now);
		tp->tv_usec = 0;
	}

	if (tzp != NULL)
	{
		tzset();
		tzp->tz_minuteswest = (int)(-timezone / 60);
		tzp->tz_dsttime = strcmp(tzname[0], tzname[1]);
	}

	return 0;
}
