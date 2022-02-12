/*
 * tzset - set timezone information
 */
/* $Header: tzset.c,v 1.3 91/04/22 13:21:11 ceriel Exp $ */

/* This function is present for System V && POSIX */

#include	<time.h>
#include	"loc_time.h"

void
tzset(void)
{
	_tzset();	/* does the job */
}
