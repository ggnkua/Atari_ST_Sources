/*
 * time.h -- time and date services.
 *
 * Copyright (c) 1981-1988, Mark Williams Company, Chicago
 * This file and its contents may not be copied or distributed
 * without permission.
 */

#ifndef TIME_H
#define TIME_H

/*
 * Clock function for process timing.
 * This returns raw ticks, CLK_TCK per second,
 * for the process's personal interpretation.
 */
#if GEMDOS
#define CLK_TCK	200		/* 200 hz timer */
typedef unsigned long clock_t;	/* 200 hz timer ticks */
#endif
clock_t clock();		/* (void) */

/*
 * Time difference as a double.
 */
double difftime();		/* (time_t time1, time_t time2) */

/*
 * Time function for calendar time.
 * Draft ANSI standard leaves time_t implementation-dependent:
 * ours is time_t is 32 bits of seconds,
 * beginning January 1, 1970, 0h00m00s GMT.
 */
typedef unsigned long time_t;
time_t time();			/* (time_t *timer) */

/*
 * Time fields structure: struct "tm",
 * aliased to "tm_t" for neatness.
 * This structure is filled in by localtime() and gmtime().
 * Note that "tm_mon" is 0 through 11,
 * and "tm_year" is number of years since 1900.
 */
typedef struct	tm {
	int	tm_sec;		/* Seconds (0-59) */
	int	tm_min;		/* Minutes (0-59) */
	int	tm_hour;	/* Hours (0-23); 0 = midnight */
	int	tm_mday;	/* Day of month (1..28,29,30,31) */
	int	tm_mon;		/* Month (0-11); 0 = January */
	int	tm_year;	/* Year AD since 1900 */
	int	tm_wday;	/* Day of week (0-6): 0 = Sunday */
	int	tm_yday;	/* Day of year (0-365,366) */
	int	tm_isdst;	/* Daylight savings time flag: */
				/* Non-standard, they make negative==NA */
} tm_t;

/*
 * Calendar time conversion functions:
 */
char	*asctime();	/* tm_t fields to ascii string */
char	*ctime();	/* time_t * to ascii string */
tm_t	*gmtime();	/* time_t * to standard time fields */
tm_t	*localtime();	/* time_t * to local time fields */

/*
 * Mark Williams extensions to the draft ANSI standard:
 */
/*
 * Timezone and daylight savings time implementation.
 * localtime() parses the TIMEZONE environmental parameter
 * or default values to set timezone, tzname[][], and daylight
 * savings time parameters.
 */
extern	long	timezone;	/* Seconds subtracted from standard time */
extern	int	dstadjust;	/* Seconds added to local standard */
extern	char	tzname[2][32];	/* Names of local standard and daylight zone */

/*
 * Calendar utilities:
 * Gregorian calendar counted from October 1582; Julian calendar
 * before that.
 * The month of Gregorian adjustment isn't right.
 */
int	isleapyear();		/* (year) AD */
int	dayspermonth();		/* (month, year) [1..12], AD */

/*
 * Julian day structure consists of the days and seconds since
 * Greenwich mean noon of January 1st 4713 BC.
 * COHERENT time_t is a variation of Julian time:
 * it counts seconds from Julian day 2,440,587.5 (January 1, 1970).
 */
typedef struct { long j_d, j_s; } jday_t;
#define COHEPOCH 2440587L		/* Julian day 1969.12.31 12h00m00s */

jday_t time_to_jday();			/* COHERENT time into Julian date */
time_t jday_to_time();			/* Julian date to coherent time */
jday_t tm_to_jday();			/* tm_t structure into Julian date */
tm_t *jday_to_tm();			/* Julian date into tm_t structure */

#if GEMDOS
/*
 * Atari ST support.
 * TOS time & date: packed binary date and time
 * A "tetd_t" object is the object of xbios functions Gettime() and Settime().
 * The halves are the objects of gemdos Tgettime(), Tgetdate(), Tsettime(),
 * Tsetdate().
 * The file time and date stamps that Fdatime(), Fsfirst(),
 * and Fsnext() maintain are rtetd_t format:
 * they reverse the order of the time
 * and date fields from the utetd_t format used by Gettime() and Settime().
 */
typedef unsigned long tetd_t;
typedef struct { unsigned g_date, g_time; } utetd_t;
typedef struct { unsigned g_rtime, g_rdate; } rtetd_t;

tetd_t tm_to_tetd();		/* tm_t structure into TOS time and date */
tm_t *tetd_to_tm();		/* TOS time and date into tm_t */
#define tetd_to_jday(td)	tm_to_jday(tetd_to_tm(td))
#define jday_to_tetd(jd)	tm_to_tetd(jday_to_tm(jd))
#define tetd_to_time(td)	jday_to_time(tetd_to_jday(td))
#define time_to_tetd(t)		jday_to_tetd(time_to_jday(t))

/*
 * The intelligent keyboard keeps time to the second
 * which neither xbios or gemdos support.
 * These two functions operate on tm_t objects.
 */
tm_t *Kgettime();	/* (void) */
int Ksettime();		/* (tm_t *timep) */

/*
 * Similar routines for the XBIOS time.
 * These two functions operate on tm_t objects.
 */
tm_t *Sgettime();	/* (void) */
int Ssettime();		/* (tm_t *timep) */
#endif
#endif

/* end of time.h */
