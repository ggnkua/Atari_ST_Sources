/*
 * ctime - convers the calendar time to a string
 */
/* $Header: ctime.c,v 1.1 89/06/12 15:21:16 eck Exp $ */

#include	<time.h>

char *
ctime(const time_t *timer)
{
	return asctime(localtime(timer));
}
