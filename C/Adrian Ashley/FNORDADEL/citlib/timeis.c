/*
 * timeis.c -- get raw time & date from GEMDOS
 *
 * 90Nov05 AA	Modified for struct tm
 * 90Aug27 AA	Split from libdep.c
 */

#include <osbind.h>
#include <time.h>

struct tm *
timeis(struct tm *clk)
{
    time_t today;
    struct tm *foo_tm;
#if 0
    unsigned short time, date;

    time = (unsigned short) Tgettime();
    date = (unsigned short) Tgetdate();

    clk->tm_year = ((date & 0xFE00) >> 9) + 80;
    clk->tm_mon = ((date & 0x01E0) >> 5) - 1;
    clk->tm_mday = (date & 0x001F);

    clk->tm_hour = (time & 0xF800) >> 11;
    clk->tm_min = (time & 0x07E0) >> 5;
    clk->tm_sec = (time & 0x001F) * 2;
#else
    today = time(NULL);		/* Get current time */
    foo_tm = localtime(&today);	/* Convert to struct tm */
    memcpy(clk, foo_tm, sizeof(struct tm));	/* Copy to desired variable */
#endif
    return clk;
}
