/*
 * time.c - GEMDOS time and date functions
 *
 * Copyright (c) 2001 Lineo, Inc.
 *
 * This file is distributed under the GPL, version 2 or at your
 * option any later version.  See doc/license.txt for details.
 */


/*
Originally written by SCC  25 Mar 85.

NAMES

        SCC     Steven C. Cavender
        EWF     Eric W. Fleischman
        ACH     Anthony C. Hay (DR UK)
*/

#define  _MINT_OSTRUCT_H
#include <osbind.h>
#include "time.h"
#include "portab.h"
#include "gemerror.h"
#include "asm.h"

short date;
short time;

/*
 * BIOS interface  
 * I didn't put it in a header because only this file is interested.
 */

/* the address of the vector in TOS vars */
#define etv_timer	(((void (**)()) 0x400L))


/*
 * private declarations
 */

static void tikfrk(int n);

static short nday[] = {0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};

/* static long uptime; */

static short msec;

/****************************/
/* Function 0x2A:  Get date */
/****************************/

long    xgetdate(void)
{
    short date_xbios = (short)((Gettime() >> 16) & 0xFFFF);
    if(date_xbios != 0)
        date = date_xbios;   
    return date;
}


/****************************/
/* Function 0x2B:  Set date */
/****************************/


#define DAY_BM          0x001F
#define MTH_BM          0x01E0
#define YRS_BM          0xFE00


long    xsetdate(short d)
{
    short curmo, day;
    long time;
    
    curmo = ((d >> 5) & 0x0F);
    day = d & DAY_BM;

    if ((d >> 9) > 119)                 /* Warranty expires 12/31/2099 */
        return ERR;

    if (curmo > 12)                     /* 12 months a year */
        return ERR;

    if ((curmo == 2) && !(d & 0x0600))  /* Feb && Leap */
    {
        if (day > 29)
            return ERR;
    }
    else
        if (day > nday[curmo])
            return ERR;

    date = d;                           /* ok, assign that value to date */
    
    time = Gettime() & 0xFFFF;
    time |= ((long)date << 16);
    
    Settime(time);                      /* tell bios about new date */

    return E_OK;
}


/****************************/
/* Function 0x2C:  Get time */
/****************************/

long    xgettime(void)
{
    short time_xbios = (short)(Gettime() & 0xFFFF);   /* bios may update time if it wishes */
    if(time_xbios != 0)
        time = time_xbios;
    return time;
}


/****************************/
/* Function 0x2D:  Set time */
/****************************/


/* Bit masks for the various fields in the time variable. */
#define SEC_BM          0x001F
#define MIN_BM          0x07E0
#define HRS_BM          0xF800


long    xsettime(short t)
{
    long t2;
    
    if ((t & SEC_BM) >= 30)
        return ERR;

    if ((t & MIN_BM) >= (60 << 5))      /* 60 max minutes per hour */
        return ERR;

    if ((t & HRS_BM) >= (24 << 11))     /* max of 24 hours in a day */
        return ERR;

    time = t;
    t2 = (Gettime() & 0xFFFF0000) + (long)t;
    
    Settime(t2);                        /* tell bios about new time */

    return E_OK;
}


/*
 *  time_init
 */


void time_init(void)
{

#if 1
		xgetdate();
		xgettime();
#else
    Settime(((long)date << 16) + ((long)time & 0xFFFF)); /* why ??? */
#endif

    *etv_timer = tikfrk;
}


/*
 *  tikfrk -
 */

static void tikfrk(int n)
{
    short curmo;

/*  uptime += n; */

    msec += n;
    if (msec >= 2000)
    {
        /* update time */

        msec -= 2000;
        time++;

        if ((time & 0x1F) != 30)
            return;

        time &= 0xFFE0;
        time += 0x0020;

        if ((time & 0x7E0) != (60 << 5))
            return;

        time &= 0xF81F;
        time += 0x0800;

        if ((time & 0xF800) != (24 << 11))
            return;

        time = 0;

        /* update date */

        if ((date & 0x001F) == 31)
            goto datok;

        date++;                 /* bump day */

        if ((date & 0x001F) <= 28)
            return;

        if ((curmo = (date >> 5) & 0x0F) == 2)
        {
            /* 2100 is the next non-leap year divisible by 4, so OK */
            if (!(date & 0x0600)) {
                if ((date & 0x001F) <= 29)
                    return;
                else
                    goto datok;
            }
        }

        if ((date & 0x001F) <= nday[curmo])
            return;

    datok:
        date &= 0xFFE0;         /* bump month */
        date += 0x0021;

        if ((date & 0x01E0) <= (12 << 5))
            return;

        date &= 0xFE00;         /* bump year */
        date += 0x0221;
    }
}


