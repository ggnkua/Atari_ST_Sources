/*
 * ftimtotm.c
 *
 *  Created on: 25.07.2019
 *      Author: og
 */

#include <ext.h>
#include <time.h>


static int get_yearday(const struct tm* tm);
static int get_weekday(const struct tm* tm);


struct tm*
ftimtotm(struct ftime* f)
{
	static struct tm tm;

	tm.tm_hour  = f->ft_hour;
	tm.tm_min   = f->ft_min;
	tm.tm_sec   = f->ft_tsec  * 2;
	tm.tm_year  = f->ft_year  + 80;
	tm.tm_mon   = f->ft_month - 1;
	tm.tm_mday  = f->ft_day;
	tm.tm_isdst = -1;

	/* yearday first! */
	tm.tm_yday  = get_yearday(&tm);
	tm.tm_wday  = get_weekday(&tm);

	return &tm;
}


/* year range is from 1980 to 2108, so no century can occur which is not a leap year */
#define is_leap(y)  ((y) % 4 == 0 && ((y) % 100 != 0 || (y) % 400 == 0))
/*
#define is_leap(y)  ((y) % 4 == 0)
*/


int
get_yearday(const struct tm* tm)
{
	extern const long _month_days[]; /* defined in gmtime.c */
	register int m;
	const int leap_year = is_leap(1900 + tm->tm_year);
	int yday;

	yday = tm->tm_mday;

	for (m = 0; m < tm->tm_mon; ++m) {
		yday += _month_days[m];

		if (m == 1 && leap_year) {
			++yday;
		}
	}

	return yday;
}


int
get_weekday(const struct tm* tm)
{
	// Caution: This function relies on tm->tm_yday, so make sure to set that first!

	int full_years;
	int leap_years;
	int days;

	full_years = tm->tm_year - 70;
	leap_years = (full_years - 2) / 4;

	if (tm->tm_year > 200) {
		// 2100 is not a leap year!
		--leap_years;
	}

	days = 365 * full_years + leap_years + tm->tm_yday - 1;

	return (4 + days) % 7;
}
