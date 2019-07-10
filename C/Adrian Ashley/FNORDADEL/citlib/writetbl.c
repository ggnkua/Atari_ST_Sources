/*
 * writetbl.c -- write the system tables file to disk
 *
 * 90Aug27 AA	Split off from libtabl.c
 */

#include "ctdl.h"
#include "net.h"
#include "event.h"
#include "zaploop.h"
#include "archiver.h"
#include "log.h"
#include "config.h"
#include "room.h"
#include "citlib.h"

extern char *indextable;

static struct {
    unsigned cfgSize;
    unsigned logSize;
    unsigned roomSize;
    unsigned evtSize;
} sysHeader;

int
writeSysTab()
{
    int table, totwrote, i;

    dunlink(indextable);
    if ((table = dcreat(indextable)) < 0) {
	printf("Can't create %s!\n", indextable);
	return ERROR;
    }

    /* Write out some key stuff so we can detect bizarreness: */
    sysHeader.cfgSize = sizeof cfg;
    sysHeader.logSize = sizeof(*logTab) * cfg.logsize;
    sysHeader.roomSize = sizeof(*roomTab) * MAXROOMS;
    sysHeader.evtSize = cfg.evtCount;

    totwrote  = dwrite(table, &sysHeader, sizeof sysHeader);
    totwrote += dwrite(table, &cfg, sizeof cfg);
    totwrote += dwrite(table, logTab, (sizeof(*logTab) * cfg.logsize));
    totwrote += dwrite(table, roomTab, (sizeof(*roomTab) * MAXROOMS));
    for (i=0; i<cfg.netSize; i++) {
	totwrote += dwrite(table, &netTab[i], NT_SIZE);
	totwrote += dwrite(table, netTab[i].Tshared, SR_BULK);
    }
    if (cfg.evtCount > 0)
	totwrote += dwrite(table, evtTab, (sizeof(*evtTab) * cfg.evtCount));
    if (cfg.poll_count > 0)
	totwrote += dwrite(table, pollTab, (sizeof(*pollTab) * cfg.poll_count));
    if (cfg.zap_count > 0)
	totwrote += dwrite(table, zap, (sizeof(*zap) * cfg.zap_count));
    if (cfg.arch_count > 0)
	totwrote += dwrite(table, archTab, (sizeof(*archTab) * cfg.arch_count));

    dclose(table);
    return totwrote;
}
