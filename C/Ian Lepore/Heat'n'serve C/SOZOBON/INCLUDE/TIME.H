/*
 *  TIME.H      Date/Time related definitions
 */

#pragma idempotent                      // include this header only once

#ifndef _TIME_H
#define _TIME_H

#ifndef   _TIME_T_DEFINED
  #define _TIME_T_DEFINED
  typedef unsigned long   time_t;       /* raw date/time */
#endif

#ifndef   _CLOCK_T_DEFINED
  #define _CLOCK_T_DEFINED
  typedef unsigned long   clock_t;      /* 200Hz clock ticks */
#endif

#define CLK_TCK     ((clock_t)200L)     /* clock ticks per second */

struct tm
    {
    int tm_sec;     /* seconds (0..59) */
    int tm_min;     /* minutes (0..59) */
    int tm_hour;    /* hours (0..23) */
    int tm_mday;    /* day of month (1..31) */
    int tm_mon;     /* month (0..11) */
    int tm_year;    /* year - 1900 */
    int tm_wday;    /* day of week (0=Sun..6=Sat) */
    int tm_yday;    /* day of year (0..365) */
    int tm_isdst;   /* daylight saving? (always -1=unknown) */
    };

extern  char        *asctime();
extern  struct tm   *gmtime();      /* always returns NULL */
extern  struct tm   *localtime();
extern  time_t      time();
extern  char        *ctime();
extern  time_t      mktime();
extern  void        stime();
extern  int         utime();
extern  long        julian_date();

/* extern   long        difftime(); */
/* extern   int     strftime(); */

extern  clock_t     clock();
extern  clock_t     start_timer();
extern  clock_t     time_since();
extern  void        sleep();

#endif _TIME_H
