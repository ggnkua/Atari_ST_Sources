/*
 * difftime - compute the difference between two calendar times
 */
/* $Header: difftime.c,v 1.4 90/09/11 10:18:44 eck Exp $ */

#include	<time.h>

double
difftime(time_t time1, time_t time0)
{
	/* be careful: time_t may be unsigned */
	if ((time_t)-1 > 0 && time0 > time1) {
		return - (double) (time0 - time1);
	} else {
		return (double)(time1 - time0);
	}
}
