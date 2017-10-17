/******************************************************************************
 *	Rtc.h		Real time clock chip operation routines
 ******************************************************************************
 */

#include "rtc.h"
#include <time.h>

/*
 *	_iclock()	Initialises timmer for use (20ms tick on)
 */
_iclock(){
	struct timechip rtc;

	get_rtc(&rtc);
	rtc.status = 01;
	set_rtc(&rtc);
}

/*	Get_rtc()	Gets the time information from the Eltecs
 *			on board clock into the structure pointer given
 */

get_rtc(rtc)
struct	timechip *rtc;
{
	char *pos;
	int c;

	while(1){			/* Wait untill timer chip is ready */
		if(!(*M3000&0xF)){
			delay10u(3);
			if(!(*M3000&0xF)) break;
		}
	}
	pos = (char *)rtc;	/* Sets position to start of structure */
	for(c=0; c<sizeof(struct timechip); c++){
		*M3000 = c;			/* Sends address */
		*pos=((*M3000&0xF)*10);		/* Gets Ten's */
		*pos+=(*M3000&0xF);		/* Gets units */
		pos++;
	}
}

set_rtc(rtc)
struct	timechip *rtc;
{
	char *pos;
	int c,tmp;

	while(1){			/* Wait untill timer chip is ready */
		if(!(*M3000&0xF)){
			delay10u(3);
			if(!(*M3000&0xF)) break;
		}
	}
	pos=(char *)rtc;	/* Sets position to start of structure */
	for(c=0; c<sizeof(struct timechip); c++){
		*M3000 = c;			/* Sends address */
		*M3000 = tmp=(*pos)/10;		/* Sets Ten's */
		*M3000 = (*pos)-(tmp*10);	/* Sets Units */
		pos++;
	}
}
delay10u(delay)
int delay;
{
	while(delay--) delay = delay;
}
	
/*
 *	_gclock()	gets the time from the RTC and converts to binary
 *			and puts needed values into (ptr)
 */

_gclock(ptr)
struct tm *ptr;
{
	struct timechip rtc;

	get_rtc(&rtc);
	ptr->tm_mon = rtc.month - 1; /* Jan is 0 */
	ptr->tm_mday = rtc.date;
	ptr->tm_year = rtc.year;
	ptr->tm_sec = rtc.seconds;
	ptr->tm_min = rtc.minutes;
	ptr->tm_hour = rtc.hours;

}

/*
 *	_sclock()	sets the time in the RTC from the data passed in
 *			the tm struct as defined by ctime(3)
 */
_sclock(ptr)
struct tm *ptr;
{
	struct timechip rtc;

	get_rtc(&rtc);
	rtc.month = ptr->tm_mon + 1; /* cos for tm jan == 0 */
	rtc.date = ptr->tm_mday;
	rtc.year = ptr->tm_year;
	rtc.seconds = ptr->tm_sec;
	rtc.minutes = ptr->tm_min;
	rtc.hours = ptr->tm_hour;
	set_rtc(&rtc);
}
