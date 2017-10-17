/******************************************************************************
 *	Time.c		Timer operations
 ******************************************************************************
 */

#include	<sys/types.h>
#include	<sys/times.h>
#include	<sys/timeb.h>
#include	<time.h>

extern	long	systime;	/* System time register */

int timezone = 0,dstflag = 1;	/* default GMT and british summer time */

time_t  time();

/*
 *	Time_init()	Initialises all time related bits
 */
time_init(){
}

ftime(tp)
struct timeb *tp;
{
	tp->time = systime;
	tp->millitm = 0;		/* Millisecond timer not used */
	tp->timezone = timezone;	/* we are on GMT */
	tp->dstflag = dstflag;	/* british summer time? */
	return 0;
}

/*
 * Time - returns current time.
 */
time_t time(){
	return	systime;
}

/*
 * Setime - sets time 
 */
setime(tim)
long tim;
{
	systime = tim;
	return 0;
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
