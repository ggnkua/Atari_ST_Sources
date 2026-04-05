/*
 * getdate.c
 *
 *  Created on: 25.07.2019
 *      Author: og
 */

#include <ext.h>
#include <mint/osbind.h>


void
getdate(struct date* dateRec)
{
    unsigned short tos_date = Tgetdate();

    dateRec->da_day  = tos_date & 0x1f;
    dateRec->da_mon  = (tos_date >> 5) & 0xf;
    dateRec->da_year = (tos_date >> 9) + 1980;
}
