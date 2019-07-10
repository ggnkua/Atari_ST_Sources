/*
 * receive.c -- receive a character from modem (subject to timeout)
 *
 * 90Aug27 AA	Split off from libmodem.c
 */

#include <time.h>
#include "ctdl.h"

int
receive(int seconds)
{
    clock_t x;
    register long delay = (long)(CLK_TCK) * (long)(seconds);

    x = clock();
    do {
	if (MIReady())
	    return getraw();
    } while (gotcarrier() && ticksSince(x) < delay);
    return ERROR;
}
