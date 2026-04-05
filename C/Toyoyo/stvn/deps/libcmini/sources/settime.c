/*
 * settime.c
 *
 *  Created on: 25.07.2019
 *      Author: og
 */

#include <ext.h>
#include <mint/osbind.h>


void settime(struct time* timeRec)
{
    unsigned short tos_time;

    tos_time = ((timeRec->ti_sec / 2) & 0x1f)
             | ((timeRec->ti_min & 0x3f) << 5)
             | ((timeRec->ti_hour & 0x1f) << 11)
             ;
    Tsettime(tos_time);
}
