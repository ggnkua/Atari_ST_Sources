/*	time.c

GEMDOS time and date functions

Originally written by SCC  25 Mar 85.

MODIFICATION HISTORY

	22 Apr 85	SCC	Modified returns of xgetdate() and xgettime() to longs
				rather than ints.

	 9 May 85	EWF	Added in checking for valid date/time setting

	13 May 85	SCC	Modified xsetdate() and xsettime() to return ERR
				rather than BADDATE or BADTIME.  Also changed some
				bourdary checks in the tests and optimized some code.

	23 Jul 85	SCC	Modified xsetdate() to allow setting to 29 Feb on leap
				year (from correction from Landon Dyer @ Atari).

	24 Jul 85	SCC	Modified xsetdate().  Fix of 23 Jul 85 was not correct.

NAMES

	SCC	Steven C. Cavender
	EWF	Eric W. Fleischman

*/

extern int time, date;		/* declared in fs.c */
extern int nday[];		/* declared in sup.c */

#include "gportab.h"
#include "gemerror.h"


/****************************/
/* Function 0x2A:  Get date */
/****************************/

long
xgetdate()
{
	return(date);
}


/****************************/
/* Function 0x2B:  Set date */
/****************************/

long
xsetdate(d)
int d;
{
	int curmo, day;

	curmo = ((d >> 5) & 0x0F);
	day = d & 0x001F;

	if ((d >> 9) > 119)			/* Warranty expires 12/31/2099 */
		return(ERR);

	if (curmo > 12)				/* 12 months a year */
		return (ERR);

	if ((curmo == 2) && !(d & 0x0600))	/* Feb && Leap */
	{
		if (day > 29)
			return(ERR);
	}
	else if (day > nday[curmo])
		return (ERR);

	date = d;				/* ok, assign that value to date */

	return (E_OK);				/* the number of days & months check */ 
}


/****************************/
/* Function 0x2C:  Get time */
/****************************/

long
xgettime()
{
	return(time);
}


/****************************/
/* Function 0x2D:  Set time */
/****************************/

long
xsettime(t)
int t;
{
	if ((t & 0x001F) >= 30)
		return(ERR);

	if ((t & 0x07e0) >= (60 << 5))	/* 60 max minutes per hour */
	    return (ERR);

	if ((t & 0xf800) >= (24 << 11))	/* max of 24 hours in a day */
	    return (ERR);

	time = t;

	return (E_OK);			/* the value of the hr,min & sec check*/
}
