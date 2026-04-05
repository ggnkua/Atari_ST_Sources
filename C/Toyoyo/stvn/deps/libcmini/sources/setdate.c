/*
 * setdate.c
 *
 *  Created on: 25.07.2019
 *      Author: og
 */

#include <ext.h>
#include <mint/osbind.h>


void
setdate(struct date* dateRec)
{
    unsigned short tos_date;

    tos_date = (dateRec->da_day & 0x1f)
             | ((dateRec->da_mon & 0x1f) << 5)
             | ((dateRec->da_year - 1980) << 9)
             ;

	Tsetdate(tos_date);
}
