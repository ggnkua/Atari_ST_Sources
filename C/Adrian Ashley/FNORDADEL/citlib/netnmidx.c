/*
 * netnmidx.c -- search for a net record with given name
 *
 * 90Aug27 AA	Split off from libnet.c
 */

#include "ctdl.h"
#include "net.h"
#include "config.h"
#include "citlib.h"

int
netnmidx(name)
char *name;
{
    register unsigned i, h;

    h = hash(name);

    for (i=0; i < cfg.netSize; i++) {
	if ((h == netTab[i].ntnmhash) && readbit(netTab[i],N_INUSE)) {
	    getNet(i);
	    if (labelcmp(netBuf.netName, name) == 0)
		return i;
	}
    }
    return ERROR;
}
