#include <time.h>
#include <mint/osbind.h>
#include <sys/time.h>


/* year range is from 1901 to 2038, so no century can occur which is not a leap year
#define is_leap(y)  ((y) % 4 == 0 && ((y) % 100 != 0 || (y) % 400 == 0))
*/
#define is_leap(y)  ((y) % 4 == 0)


const int _month_days[] = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 };

enum { January, February, March, April, May, June, July, August, September, October, November, December, Months };
enum { Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Weekdays };


struct tm*
gmtime(const time_t* timep)
{
    static struct tm tm;

    time_t t   = *timep;
    int    neg = (t < 0);
    int    step;
    long   days;
    long   seconds;
    int    leap;
    int    monthdays;

    if (neg) {
        t    = -t - 1;
        step = -1;
    } else {
        step = 1;
    }

    days    = t / 86400L;
    seconds = t % 86400L;

    if (neg) {
        tm.tm_wday = (Wednesday + days) % Weekdays;
        tm.tm_year = 1969;
        seconds    = 86399L - seconds;
    } else {
        tm.tm_wday = (Thursday + days) % Weekdays;
        tm.tm_year = 1970;
    }

    for (;;) {
        int yeardays = is_leap(tm.tm_year) ? 366 : 365;

        if (neg) {
            if (yeardays > days) {
                tm.tm_yday = yeardays - days - 1;
                break;
            }
        } else {
            if (yeardays >= days) {
                tm.tm_yday = days;
                break;
            }
        }

        tm.tm_year += step;
        days       -= yeardays;
    }

    tm.tm_mon = neg ? 11 : 0;

    leap = is_leap(tm.tm_year);

    for (;;) {
        monthdays = _month_days[tm.tm_mon];

        if (leap && tm.tm_mon == 1) {
            ++monthdays;
        }

        if (monthdays <= days) {
            tm.tm_mon += step;
            days      -= monthdays;

            if (tm.tm_mon == 12) {
                tm.tm_mon = 0;
                ++tm.tm_year;
            }
        } else {
            tm.tm_mday = neg ? monthdays : 1;
            break;
        }
    }

    tm.tm_year -= 1900;
    tm.tm_mday += step * days;
    tm.tm_hour  = (int)(seconds / 3600L);
    tm.tm_min   = (int)((seconds % 3600L) / 60L);
    tm.tm_sec   = (int)(seconds % 60L);
    tm.tm_isdst = -1;

    return &tm;
}
