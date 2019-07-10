/*
 * getdiren.c -- return a direntry
 *
 * 90Dec05 AA	Changed some dta and time stuff
 * 90Aug28 AA	Moved from citmain.
 */
#include <stdio.h>
#include "dirlist.h"
#include <time.h>
#include <osbind.h>

struct dirList *
getdirentry(pattern)
char *pattern;
{
    static struct dirList tmp;
    static struct _dta dta;
    int status;

    Fsetdta(&dta);
    if (pattern)
	status = Fsfirst(pattern, 0);
    else
	status = Fsnext();
    if (status == 0) {
	strcpy(tmp.fd_name, dta.dta_name);
	tmp.fd_size      = dta.dta_size;
	tmp.fd_date.mday = dta.dta_date & 31;
	tmp.fd_date.year = 80 + ((dta.dta_date >> 9) & 255);
	tmp.fd_date.mon  = ((dta.dta_date >> 5) & 15) - 1;
	return &tmp;
    }
    return NULL;
}
