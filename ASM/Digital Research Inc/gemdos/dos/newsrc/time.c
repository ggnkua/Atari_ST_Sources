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

	26 Jun 87	ACH	Introduced new bios function to support 
				hardware real-time clock calendars.

NAMES

	SCC	Steven C. Cavender
	EWF	Eric W. Fleischman
	ACH	Anthony C. Hay (DR UK)
*/

extern 	int 	time, date;		/* declared in fs.c */
extern 	int 	nday[];			/* declared in sup.c */

#include "gportab.h"
#include "gemerror.h"
#include "bios.h"

extern 	long	trap13();		/* direct bios calls */


/****************************/
/* Function 0x2A:  Get date */
/****************************/

long	xgetdate()
{
    date_time(GET_DATE, &date);		/* allow bios to update date */
    return date;
}


/****************************/
/* Function 0x2B:  Set date */
/****************************/


#define	DAY_BM		0x001F
#define	MTH_BM		0x01E0
#define	YRS_BM		0xFE00


long	xsetdate(d)
int 	d;
{
int 	curmo, day;

    curmo = ((d >> 5) & 0x0F);
    day = d & DAY_BM;

    if ((d >> 9) > 119)			/* Warranty expires 12/31/2099 */
	return ERR;

    if (curmo > 12)			/* 12 months a year */
	return ERR;

    if ((curmo == 2) && !(d & 0x0600))	/* Feb && Leap */
    {
	if (day > 29)
	    return ERR;
    }
    else
    	if (day > nday[curmo])
	    return ERR;

    date = d;				/* ok, assign that value to date */
    date_time(SET_DATE, &date);		/* tell bios about new date */

    return E_OK;
}


/****************************/
/* Function 0x2C:  Get time */
/****************************/

long	xgettime()
{
    date_time(GET_TIME, &time);		/* bios may update time if it wishes */
    return time;
}


/****************************/
/* Function 0x2D:  Set time */
/****************************/


/* Bit masks for the various fields in the time variable. */
#define	SEC_BM		0x001F
#define	MIN_BM		0x07E0
#define	HRS_BM		0xF800


long	xsettime(t)
int 	t;
{
    if ((t & SEC_BM) >= 30)
	return ERR;

    if ((t & MIN_BM) >= (60 << 5))	/* 60 max minutes per hour */
	return ERR;

    if ((t & HRS_BM) >= (24 << 11))	/* max of 24 hours in a day */
	return ERR;

    time = t;
    date_time(SET_TIME, &time);		/* tell bios about new time */

    return E_OK;
}
