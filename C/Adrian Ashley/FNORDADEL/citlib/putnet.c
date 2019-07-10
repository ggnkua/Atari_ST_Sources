/*
 * putnet.c -- put a net record to disk
 *
 * 90Aug27 AA	Split off from libnet.c
 */

#include "ctdl.h"
#include "net.h"
#include "config.h"
#include "citlib.h"

void
putNet(n)
register int n;
{
    netTab[n].flags = netBuf.flags;
    netTab[n].ld = netBuf.ld;
    netTab[n].dialer = netBuf.dialer;
    netTab[n].poll_day = netBuf.poll_day;
    netTab[n].what_net = netBuf.what_net;

    memcpy(netTab[n].Tshared, netBuf.shared, SR_BULK);

    thisNet = n;

    crypte((char *)&netBuf, NB_SIZE, n);

    dseek(netfl, ((long)n) * ((long)NB_TOTAL_SIZE), 0);
    if (dwrite(netfl, &netBuf, NB_SIZE) != NB_SIZE)
	crashout("putNet-write(1) failed");
    if (dwrite(netfl, netBuf.shared, SR_BULK) != SR_BULK)
	crashout("putNet-write(2) failed");

    crypte((char *)&netBuf, NB_SIZE, n);
}
