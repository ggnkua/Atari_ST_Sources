/*
 *		Cross Development System for Atari ST 
 *     Copyright (c) 1988, Memorial University of Newfoundland
 *
 *   Some simple sleep routines - use a busy wait loop for the system counter
 * to catch up with us.  usleep() is the same as sleep() except that it takes
 * micro seconds (us) instead (note that the resolution is only 5ms).
 *
 * $Header: sleep.c,v 1.1 88/02/03 22:46:50 m68k Exp $
 *
 * $Log:	sleep.c,v $
 * Revision 1.1  88/02/03  22:46:50  m68k
 * Initial revision
 * 
 */
#include	<osbind.h>
#include	<sysvars.h>
#include	<types.h>

#define	HZ		200
#define	USEC_TO_HZ(us)	(((us) + 1000000/HZ - 1) / 1000000/HZ)

static long	time_now();

void
sleep(n)
	int	n;
{
	long	stop;

	stop = Supexec(time_now) + n * HZ;
	while (Supexec(time_now) < stop)
		;
}

/*
 * Same as long but has in units of 1/HZ of second
 */
void
usleep(usec)
	u_long	usec;
{
	long	stop;

	stop = Supexec(time_now) + USEC_TO_HZ(usec);
	while (Supexec(time_now) < stop)
		;
}

static long
time_now()
{
	return *_hz_200;
}
