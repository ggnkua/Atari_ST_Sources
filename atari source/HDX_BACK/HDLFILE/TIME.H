/* Copyright 1987 Manx Software Systems, Inc */
#ifndef _TIME_H
#define _TIME_H
#define NULL ((void *)0)
# ifndef _SIZE_T
# define _SIZE_T
  typedef unsigned int size_t;
# endif

#define CLK_TCK 200	/* clock() ticks per second */
typedef unsigned long clock_t;
# ifndef _TIME_T
# define _TIME_T
  typedef unsigned long time_t;
#endif

#define _TINY_TIME_T ((time_t)0x210000)		/* Tue Jan  1 00:00:00 1980 */
#define _HUGE_TIME_T ((time_t)0xef9fbf7d)	/* Thu Dec 31 23:59:58 2099 */

struct tm {
	int tm_sec;		/* seconds after the minute [0,59] */
	int tm_min;		/* minutes after the hour [0,59] */
	int tm_hour;	/* hours since midnight [0,23] */
	int tm_mday;	/* day of the month [1,31] */
	int tm_mon;		/* months since jan [0,11] */
	int tm_year;	/* years since 1900 */
	int tm_wday;	/* days since sunday [0,6] */
	int tm_yday;	/* days since jan 1 [0,365] */
	int tm_isdst;	/* pos if DST in effect; 0 if not; neg if can't tell */
	int tm_hsec;	/* hundreths of second; not in ANSI C */
};

clock_t clock();
double difftime();
time_t mktime(), time();
char *asctime(), *ctime();
struct tm *gmtime(), *localtime();
size_t strftime();
#endif
