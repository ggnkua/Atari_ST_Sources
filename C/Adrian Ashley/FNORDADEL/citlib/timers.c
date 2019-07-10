/*
 * timers.c -- General timers for citadel/et al
 *
 * 90Nov05 AA	Hacks for ANSI clock_t instead of old scheme
 * 90Aug27 AA	Renamed from libtimer.c
 * 88Jan29 orc	Created.
 */

#include "ctdl.h"

/*
 * TIMERS:
 *
 * Basically, the idea here is that two functions are available to the rest of
 * Citadel.  One starts a timer.  The other allows checking that timer, to see
 * how much time has passed since that timer was started.
 */

static clock_t myclock;

void
startTimer()
{
    myclock = clock();
}

long	/* RETURNS: Time in seconds since last call to startTimer(). */
chkTimeSince()
{
    return timeSince(myclock);
}
