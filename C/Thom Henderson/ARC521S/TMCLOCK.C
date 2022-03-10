/*
 * Stolen from Jef Poskanzer's tws time library, which was stolen from
 * Marshall Rose's MH Message Handling system...
 *
 * tmclock() will convert time from a tm struct back to a clock value.
 * tmjuliandate() converts a tm struct to its julian day number.
 * tmsubdayclock() takes hours, minutes, and seconds from a tm struct
 * and returns the number of seconds since midnight of that day. (?)
 *  -- Howard Chu, August 1 1988      hyc@umix.cc.umich.edu, umix!hyc
 */

/* $Header: tmclock.c,v 1.3 88/08/02 14:15:58 hyc Exp $ */

/* Julian day number of the Unix* clock's origin, 01 Jan 1970. */
#define JD1970 2440587L
#define	CENTURY	19
#if	BSD
#include <sys/time.h>
int	daylight;
#else
#include <time.h>
#endif

long	tzone;

long
tmjuliandate( tm )
struct tm *tm;
    {
    register int mday, mon, year;
    register long a, b;
    double jd;

    if ( (mday = tm -> tm_mday) < 1 || mday > 31 ||
	    (mon = tm -> tm_mon + 1) < 1 || mon > 12 ||
	    (year = tm -> tm_year) < 1 || year > 10000 )
	return ( -1L );
    if ( year < 100 )
	year += CENTURY * 100;

    if ( mon == 1 || mon == 2 )
	{
	--year;
	mon += 12;
	}
    if ( year < 1583 )
	return ( -1L );
    a = year / 100;
    b = 2 - a + a / 4;
    b += (long) ( (double) year * 365.25 );
    b += (long) ( 30.6001 * ( (double) mon + 1.0 ) );
    jd = mday + b + 1720994.5;
    return ( (long) jd );
    }


long
tmsubdayclock( tm )
struct tm *tm;
    {
    register int sec, min, hour;
    register long result;
#if	BSD
    {
       struct timeval tp;
       struct timezone tzp;

       gettimeofday(&tp, &tzp);
       daylight=tzp.tz_dsttime;
       tzone=tzp.tz_minuteswest*(-60);
    }
#else
    tzone=timezone;	/* declared as extern in SYSV <time.h> */
#endif
    if ( (sec = tm -> tm_sec) < 0 || sec > 59 ||
	    (min = tm -> tm_min) < 0 || min > 59 ||
	    (hour = tm -> tm_hour) < 0 || hour > 23 )
	return ( -1L );

    result = ( hour * 60 + min ) * 60 + sec;
    result -= tzone;
    if ( daylight )
	result -= 60 * 60;

    return ( result );
    }


long
tmclock( tm )
struct tm *tm;
    {
    register long jd, sdc, result;

    if ( ( jd = tmjuliandate( tm ) ) == -1L )
	return ( -1L );
    if ( ( sdc = tmsubdayclock( tm ) ) == -1L )
	return ( -1L );

    result = ( jd - JD1970 ) * 24 * 60 * 60 + sdc;

    return ( result );
    }
