/* This file is part of the AHCC C Library.

   The AHCC C Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Library General Public License as
   published by the Free Software Foundation; either version 2 of the
   License, or (at your option) any later version.

   The AHCC C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   You should have received a copy of the GNU Library General Public
   License along with the GNU C Library; see the file COPYING.LIB.  If not,
   write to the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
   Boston, MA 02111-1307, USA.
   
   
   This file is DLIBS\TIME.C ported to C89
*/

/*
 * DATE/TIME FUNCTIONS:
 *
 *	To use the functions in this section, you must include "TIME.H"
 *	in your source file.
 */

#include <prelude.h>
#include <ctype.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <time.h>
#include <tos.h>
#include <ext.h>

static char
short_days[7][4] =
	{ "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat" },
short_months[12][4] =
	{ "Jan", "Feb", "Mar", "Apr", "May", "Jun",
	  "Jul", "Aug", "Sep", "Oct", "Nov", "Dec" };

long timezone = 3600;		/* MET --> GMT */
short daylight = 0;			/* currently not used */


static
bool check_tm( const _TM *t )
{
	if (t->tm_sec  < 0 or t->tm_sec  > 59) return false;
	if (t->tm_min  < 0 or t->tm_min  > 59) return false;
	if (t->tm_hour < 0 or t->tm_hour > 23) return false;
	if (t->tm_mday < 1 or t->tm_mday > 31) return false;
	if (t->tm_mon  < 0 or t->tm_mon  > 11) return false;
	if (t->tm_year < 0                   ) return false;
	return true;
}

char * asctime( const _TM *t )
{
	static char s[32];
	if (check_tm(t))
	{
		sprintf(s, "%s %s %02d %02d:%02d:%02d %d\n",
			short_days[t->tm_wday % 7],
			short_months[t->tm_mon],
			t->tm_mday, t->tm_hour, t->tm_min, t->tm_sec, t->tm_year + 1900);
	}
	else
		sprintf(s, "?? %d %d %d %d %d %d\n", *t);
	return s;
}

char * ctime( const time_t *timer )
{
	static _TM t = {0};
	seconds_to_date_and_time(*timer, &t, 70);
	return asciitime(&t);
}

struct tm *gmtime( const time_t *clock )
{
	static _TM t = {0};
	time_t tim = *clock - timezone;
	return seconds_to_date_and_time(tim, &t, 70);
}

struct tm *localtime( const time_t *clock )
{
	static _TM t = {0};
	return seconds_to_date_and_time(*clock, &t, 70);
}

time_t time( time_t *timer )
{
	FTIME ft;
	_TM t;
	time_t tim;
	ft.dt.time = Tgettime();
	ft.dt.date = Tgetdate();
	fttotm(&t, &ft);
	tim = date_and_time_to_seconds(&t, 70);
	if (timer)
		*timer = tim;
	return tim;
}

time_t mktime( struct tm *timeptr )
{
	if (check_tm(timeptr))
		return date_and_time_to_seconds(timeptr, 70);
	return -1;
}

static clock_t __clock_get;
static
Supfunc __get_clock
{
	return __clock_get = *(long *)1210L;
}

clock_t clock( void )
{
	Supexec(__get_clock);
	return __clock_get;
}

char
long_days[7][10] =
	{ "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday" },
long_months[12][10] =
	{ "January", "February", "March", "April", "May", "June",
	  "July", "August", "September", "October", "November", "December" };

#define SLD sizeof(long_days[0])
#define SSD sizeof(short_days[0])

static
char * _cpy(char *to, char *fro)
{
	while (*fro) *to++ = *fro++;
	return to;
}

#define check_s(s, plus) (s + plus < stop)

/* Weekday of each jan 1 from 1900 onward until 2043.
   In 2043 I'll be 98 years old, so I hope that this table
   will appear to be too small.
   As happens with many assumptions in the IT world :-)
 */

static
int jan1day[] =
{
/* 1900 */	0,2,3,4, 5,0,1,2, 3,5,6,0, 1,3,4,5,
/* 1916 */	6,1,2,3, 4,6,0,1, 2,4,5,6, 0,2,3,4,
/* 1932 */	5,0,1,2, 3,5,6,0, 1,3,4,5, 6,1,2,3,
/* 1948 */	4,6,0,1, 2,4,5,6, 0,2,3,4, 5,0,1,2,
/* 1964 */	3,5,6,0, 1,3,
/* 1970 */               4,5, 6,1,2,3, 4,6,0,1,
/* 1980 */	2,4,5,6, 0,2,3,4, 5,0,1,2, 3,5,6,0,
/* 1996 */	1,3,4,5, 6,1,2,3, 4,6,0,1, 2,4,5,6,
/* 2012 */	0,2,3,4, 5,0,1,2, 3,5,6,0, 1,3,4,5,
/* 2028 */	6,1,2,3, 4,6,0,1, 2,4,5,6, 0,2,3,4,
};

/*
	%a abgekrzter Wochentag
	%A ausgeschriebener Wochentag
	%b abgekrzter Monatsname
	%B voller Monatsname
	%c Datum und Uhrzeit
	%d Tag im Monat (1-31)
	%H Stunde (0-23)
	%I Stunde (0-12)
	%j Tag im Jahr (1-366)
	%m Monat (1-12)
	%M Minute (00-59)
	%p AM/PM
	%S Sekunde (00-59)
	%w Wochentag (0-6)
	%W Woche im Jahr (0-52)
	%x lokale Datumsdarstellung
	%X lokale Zeit-Darstellung
	%y Jahr ohne Jahrhundert (0-99)
	%Y Jahr mit Jahrhundertangabe
	%Z Name der Zeitzone (z.B. MEZ)
	%% das ¯%®-Zeichen
*/

size_t strftime(char *s, size_t max, const char *f, const _TM *t)
{
	uchar c;
	char *start = s, *stop = s + max;

	if (!check_tm(t))
		s += sprintf(s, "?? s%d m%d h%d d%d m%d y%d w%d\n", *t);
	else
	while ((c = *f++) ne 0)
	{
		if (c ne '%')
		{
			if (check_s(s, 1)) *s++ = c;
		othw
			c = *f;

			switch(c)
			{
			case 'a':
				if (check_s(s, SSD))
					s = _cpy(s, short_days[t->tm_wday]);
			break;
			case 'A':
				if (check_s(s, SLD))
					s = _cpy(s, long_days[t->tm_wday]);
			break;
			case 'b':
				if (check_s(s, SSD))
					s = _cpy(s, short_months[t->tm_mon]);
			break;
			case 'B':
				if (check_s(s, SLD))
					s = _cpy(s, long_months[t->tm_mon]);
			break;
			case 'c':
				if (check_s(s, 19))
					s += sprintf(s, "%2d/%02d/%d %02d:%02d:%02d",
									t->tm_mday,
									t->tm_mon + 1,
									t->tm_year + 1900,
									t->tm_hour,
									t->tm_min,
									t->tm_sec );
			break;
			case 'd':
				if (check_s(s, 2))
					s += sprintf(s, "%02d", t->tm_mday);
			break;
			case 'H':
				if (check_s(s, 2))
					s += sprintf(s, "%02d", t->tm_hour);
			break;
			case 'I':
				if (check_s(s, 2))
					s += sprintf(s, "%02d", t->tm_hour % 12);
			break;
			case 'j':
				if (check_s(s, 3))
					s += sprintf(s, "%d", t->tm_yday + 1);
			break;
			case 'm':
				if (check_s(s, 2))
					s += sprintf(s, "%02d", t->tm_mon + 1);
			break;
			case 'M':
				if (check_s(s, 2))
					s += sprintf(s, "%02d", t->tm_min);
			break;
			case 'p':
				if (check_s(s, 2))
					s = _cpy(s, t->tm_hour < 12 ? "AM" : "PM");
			break;
			case 'S':
				if (check_s(s, 2))
					s += sprintf(s, "%02d", t->tm_sec);
			break;
			case 'w':
				if (check_s(s, 1))
					*s++ = t->tm_wday + '0';
			break;
			case 'W':
				if (check_s(s, 2))
					s += sprintf(s, "%02d",
						jan1day[t->tm_year] + t->tm_yday / 7);
			break;
			case 'x':
				if (check_s(s, 10))
					s += sprintf(s, "%2d/%02d/%d",
									t->tm_mday,
									t->tm_mon + 1,
									t->tm_year + 1900 );
			break;
			case 'X':
				if (check_s(s, 8))
					s += sprintf(s, "%02d:%02d:%02d",
									t->tm_hour,
									t->tm_min,
									t->tm_sec );
			break;
			case 'y':
				if (check_s(s, 2))
					s += sprintf(s, "%02d", t->tm_year % 100);
			break;
			case 'Y':
				if (check_s(s, 4))
					s += sprintf(s, "%02d", t->tm_year + 1900);
			break;
			case 'Z':
				if (check_s(s, 3))
					s = _cpy(s, "MET");
			break;
			default:
				if (check_s(s, 1))
					*s++ = c;
			}

			f++;
		}
	}

	*s = 0;
	return start - s;
}

#ifndef __NO_FLOAT__
double difftime( time_t time2, time_t time1 )
{
	return time2 - time1;
}
#endif

static
int summeddays[] =
{
	0,31,59,90,
	120,151,181,212,
	243,273,304,334
};

static
int summedleap[] =
{
	0,31,60,91,
	121,152,182,213,
	244,274,305,335
};

#define secsphour (60L * 60)
#define secspday  (24L * secsphour)

time_t date_and_time_to_seconds(_TM *t, short startyear)
{
	int *leap;
	short y = t->tm_year,
	      m = t->tm_mon,
	      d = t->tm_mday - 1;

	if (    d >= 0
	    and m >= 0
	    and m <  12
	    and y >= 0
	    and startyear < y
	    and y - startyear < 63
	   )
	{
		long days = 0, seconds;

		while (y > startyear)
		{
			days += 365;
			if (y)				/* 1900 is not a leap year */
				if ((y & 3) eq 0)
					days += 1;

			y -= 1;
		}

		leap = t->tm_year and (t->tm_year & 3)
				? summeddays : summedleap;

		days += leap[m];
		days += d;

		seconds = days * secspday;

		seconds += t->tm_hour * secsphour;
		seconds += t->tm_min  * 60;
		seconds += t->tm_sec;

		return seconds;
	}

	return -1;
}

_TM * seconds_to_date_and_time
		(time_t timer, _TM *ti, short startyear)
{
	int *leap;
	long days, lastday, t = timer, weekday;
	short y = startyear, m = 0;

	days = t / secspday;
	lastday = t % secspday;
	weekday = days % 7;

	while (days > 365)
	{
		days -= 365;

		if (y)					/* 1900 is not a leap year */
			if ((y&3) eq 0)
				days -= 1;
		y++;
	}

	ti->tm_yday = days;

	leap = y and (y & 3) ? summeddays : summedleap;
	while (days > leap[m]) m++;
	days -= leap[--m];

	ti->tm_year = y;
	ti->tm_mon  = m;
	ti->tm_mday = days + 1;
	ti->tm_hour = lastday /  secsphour;
	              lastday %= secsphour;
	ti->tm_min  = lastday / 60;
	ti->tm_sec  = lastday % 60;
	ti->tm_wday = (weekday + jan1day[startyear]) % 7;
	return ti;
}

void fttotm(_TM *t, FTIME *ft)
{
	t->tm_sec  = ft->ft.tsec * 2;
	t->tm_min  = ft->ft.min;
	t->tm_hour = ft->ft.hour;
	t->tm_mday = ft->ft.day;
	t->tm_mon  = ft->ft.month - 1;
	t->tm_year = ft->ft.year + 80;
}

time_t ftimtosec(FTIME *ft)
{
	static _TM t = {0};
	fttotm(&t, ft);
	return date_and_time_to_seconds(&t, 70);
}

void stime(time_t *rawtime)
{
	time_t t = *rawtime;
	int *tp = (int *) &t, tt;

	Tsettime(tt = tp[0]);			/* set time from high word */
	Tsetdate(tp[0] = tp[1]);		/* set date from low word */
	tp[1] = tt;						/* finish swapping words */
	Settime(*rawtime);				/* set keyboard clock also */
}

short utime(char *pathname, time_t *rawtime)
{
	short h;
	time_t raw;

	if (!rawtime)
	{
		rawtime = &raw;				/* current */
		time(rawtime);				/*  time   */
	}

	h = Fopen(pathname, 2);			/* open */
	if (h < 0)
		return errno = h;			/* FAILURE */

	Fdatime((DOSTIME *)rawtime, h, 1);	/* timestamp */
	h = Fclose(h);						/* close */
	return errno = h;
}

clock_t start_timer(clock_t *t)
{
	return *t = clock();
}

clock_t time_since(clock_t *t)
{
	return clock() - *t;
}

void sleep(unsigned short dt)
/*
 *	Suspend operation for <dt> seconds.  This is implemented as a
 *	start_timer()/time_since() tight loop waiting for the specified
 *	amount of time to pass.  In a multi-tasking environment, this
 *	function should be replaced by a call which will de-activate
 *	this task for a period of time, allowing other tasks to run.
 */
{
	clock_t t;
	register clock_t tt;

	tt = ((clock_t) dt) * CLK_TCK;
	start_timer(&t);
	while(time_since(&t) < tt)
		;
}
