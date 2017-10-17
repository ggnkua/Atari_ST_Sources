/******************************************************************************
 *	Time.c		Timer operations
 ******************************************************************************
 */

#include	<sys/types.h>
#include	<sys/times.h>
#include	<sys/timeb.h>
#include	<time.h>
#include	"time.h"

int timezone = 0,dstflag = 1;	/* default GMT and british summer time */
struct tm lastclock;
time_t	lasttime;

time_t get_clock(), new_clock(), time();
void _gclock(), _sclock();	/* get and set the real-time clock */

/*	Number of days into normal year per month */
static int	dpm[12] = {
	0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334
};

/*
 *	Time_init()	Initialises all time related bits
 */
time_init(){
	_iclock();		/* Initialises timer chip */
}

time_t get_clock(tmptime)
struct tm *tmptime;{

	int	c, daynum;
	time_t	clockn;

	/*
	 *	the struct passed to the gclock routine is
	 *	same one as used in the ctime (3) stuff with
	 *	the same defs [eg months run from 0 (January)
	 *	to 11 (December)] so this routine must mod the 
	 *	entries in tmptime to give a valid time etc
	 *	NB most RTC chips use BCD so don't forget to
	 *	convert the values to binary first before
	 *	stuffing them into the relevant orifice in
	 *	tmptime.
	 */

	_gclock(tmptime);

/*
 * Calculates time in seconds from UNIX DAY 1 JAN 1970
 * Uses real time from real time clock IC
 * First calculates number of days into year 
 */
	/* Number of days due to month*/
	daynum = dpm[tmptime->tm_mon];

	/* If beyond Feb add 1 if leap year */
	if(tmptime->tm_mon > 1) daynum += leap(tmptime->tm_year);

	/* Add number of days into month */
	daynum += tmptime->tm_mday - 1;

	/* Add number of days for current year from EPOCH */
	for(c = EPOCH; c < tmptime->tm_year; c++)
		daynum += YEAR + leap(c);

	/* Calculate real time in seconds */
	clockn = tmptime->tm_sec + (tmptime->tm_min * MIN)
		+ (tmptime->tm_hour * HOUR) + (daynum * DAY) + FIDLE;

	return clockn;
}


/* calculate if leap year */

leap(year)
int year;{
	if(year % 4 == 0 && year % 100 != 0 || year % 400 == 0)
		return 1;
	else
		return 0;
}


setftime(tp)
struct timeb *tp;{
	/*
		sets the global containing things like the dst
		flag and timezone
	 */

	if(tp){
		timezone = tp->timezone;
		dstflag = tp->dstflag;
	}
	else{
		timezone = 0;	/* default to GMT */
		dstflag = 1;	/* and british summer time */
	}
}

ftime(tp)
struct timeb *tp;{

	tp->time = lasttime = get_clock(&lastclock);
	tp->millitm = 0;		/* Millisecond timer not used */
	tp->timezone = timezone;	/* we are on GMT */
	tp->dstflag = dstflag;	/* british summer time? */
	return 0;
}

/*
 * Time - returns current time.
 */
time_t time(){

	if(lasttime == 0)
		/*
			init the locals and return
			the calculated time from jan 1 1970
		 */
		/* Gets time from timer chip */
		return (lasttime = get_clock(&lastclock));

	else
		/*
			compare the cuurent value of the rtc
			with whats in lastclock and change the
			time accordingly
		 */
		return new_clock();
}

time_t new_clock(){
	/*
		this compares the values in lastclock
		to the real time returned from the rtc
		and if different modifies lasttime
		and lastclock accordingly
	 */

	struct tm tmptime;
	register time_t secs1, secs2;

	_gclock(&tmptime);	/* get current time */
			
	if(lastclock.tm_mday != tmptime.tm_mday)
		/*
			if day date is different then update 
			properly
		 */
		return (lasttime = get_clock(&lastclock));
	else{
		/*
			assume only the hour minute
			and second fields are different
		 */

		secs1 = lastclock.tm_sec + (lastclock.tm_min * 60) + (lastclock.tm_hour * 3600);
		secs2 = tmptime.tm_sec + (tmptime.tm_min * 60) + (tmptime.tm_hour * 3600);

		lasttime += (secs2 - secs1);
		lastclock.tm_sec = tmptime.tm_sec;
		lastclock.tm_min = tmptime.tm_min;
		lastclock.tm_hour = tmptime.tm_hour;
		return lasttime;
	}
}
/*
 * Setime - sets time 
 */
setime(tim)
long tim;{

	struct tm *gmtime(), *tmp;

	/*
	 *	just like _gclock the tm struct
	 *	generated from gmtime is used to 
	 *	set the RTC
	 */

	_sclock(gmtime(&tim));
}
/*
 * Times - Returns accounting information (not yet implemented)
 */
times(tim)
struct tms *tim;{
	tim->tms_utime = 1;
	tim->tms_stime = 1;
	tim->tms_cutime = 1;
	tim->tms_cstime = 1;
	return 0;
}
