/*
 * getnet.c -- load a net record from disk
 *
 * 90Aug27 AA	Split off from libnet.c
 */

#include "ctdl.h"
#include "net.h"
#include "config.h"
#include "citlib.h"

/* We must find a better place for these... */
struct netBuffer netBuf;
int thisNet;
int netfl;

void
getNet(n)
int n;
{
    thisNet = n;
    dseek(netfl, ((long)n) * ((long)NB_TOTAL_SIZE), 0);
    if (dread(netfl, &netBuf, NB_SIZE) != NB_SIZE)
	crashout("getNet-read(1) failed");
    crypte((char *)&netBuf, NB_SIZE, n);
    if (dread(netfl, netBuf.shared, SR_BULK) != SR_BULK)
	crashout("getNet-read(2) failed");
}
