/*
 * gettime.c
 *
 *  Created on: 25.07.2019
 *      Author: og
 */

#include <ext.h>
#include <mint/osbind.h>


void
gettime(struct time* timeRec)
{
    unsigned short tos_time = Tgettime();

    timeRec->ti_sec  = (tos_time & 0x1f) * 2;
    timeRec->ti_min  = (tos_time >> 5) & 0x3f;
    timeRec->ti_hour = (tos_time >> 11) & 0x1f;
    timeRec->ti_hund = 0;
}
