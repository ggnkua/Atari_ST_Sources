/*
 * clock.c -- various timers and stuff for Fnordadel
 *
 * 90Nov05 AA	ANSIfied for gcc
 * 90Aug27 AA	Split from libdep.c
 */

#include "ctdl.h"

#define CLKSHIFT	0x40000000L	/* in case start > end on a timer */
#define elapsed(x)	((x < 0L) ? (x + CLKSHIFT) : (x))

/* upTime(): Return # seconds since the system came up.	*/
long
upTime(void)
{
    return clock()/CLK_TCK;
}

/* ticksSince(): Calculate how many system ticks have passed. */
clock_t
ticksSince(clock_t then)
{
    register clock_t nt;

    nt = clock() - then;
    return elapsed(nt);		/* and return the # of ticks */
}

/* pause(): busy-waits I/100 seconds */
void
pause(int i)
{
    clock_t x, delay;

    delay = (clock_t)(CLK_TCK / 100 * i);
    for (x = clock(); (clock() - x) < delay; )
	;
}

/* timeSince(): return # seconds since timer started. */
long
timeSince(clock_t x)
{
    return (clock() - x) / CLK_TCK;
}

/* timeLeft(): return # seconds left in this timer. */
long
timeLeft(long p)
{
    return p - upTime();
}
