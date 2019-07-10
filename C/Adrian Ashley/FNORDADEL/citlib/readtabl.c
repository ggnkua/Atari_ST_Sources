/*
 * readtabl.c -- read the system tables file
 *
 * 90Aug27 AA	Split off from libtabl.c
 */

#include "ctdl.h"
#include "net.h"
#include "event.h"
#include "zaploop.h"
#include "archiver.h"
#include "config.h"
#include "room.h"
#include "log.h"
#include "citlib.h"

/* We need a better place for these... */
struct config	cfg;			/* A buncha variables		*/
struct lTable	*logTab  = NULL;
struct netTable *netTab  = NULL;
struct rTable	*roomTab = NULL;	/* was roomTab[MAXROOMS]	*/
struct evt_type *evtTab  = NULL;
struct poll_t   *pollTab = NULL;
struct zaphash	*zap     = NULL;
struct archiver *archTab = NULL;

char *indextable = "ctdltabl.sys";

struct {
    unsigned cfgSize;
    unsigned logSize;
    unsigned roomSize;
    unsigned evtSize;
} sysHeader;

static int
ltread(block, size, fd)
char *block;
unsigned size;
int fd;
{
    if (dread(fd, block, size) != size) {
	fprintf(stderr,"could not read %u bytes\n",size);
	dclose(fd);		/* orc 2-jan-87 */
	return FALSE;
    }
    return TRUE;
}

int
readSysTab(kill)
int kill;
{
    int fd, i;

    if ((fd = dopen(indextable, O_RDONLY)) < 0) {
	printf("No %s\n", indextable);	  /* Tsk, tsk! */
	return FALSE;
    }

    if (dread(fd,&sysHeader,sizeof sysHeader) != sizeof sysHeader) {
	printf("%s header read\n",indextable);
	dclose(fd);
	return FALSE;
    }

    if (!ltread(&cfg, (sizeof cfg), fd))
	return FALSE;

    if (sysHeader.cfgSize != sizeof cfg
		    || sysHeader.evtSize != cfg.evtCount
		    || sysHeader.roomSize != sizeof(*roomTab) * MAXROOMS
		    || sysHeader.logSize != sizeof(*logTab) * cfg.logsize) {
	printf("size mismatch in %s\n",indextable);
	dclose(fd);
	exit(255);
    }

    logTab = (struct lTable *) xmalloc(sysHeader.logSize);
    if (!ltread(logTab, sysHeader.logSize, fd))
	return FALSE;

    roomTab = (struct rTable *) xmalloc(sysHeader.roomSize);
    if (!ltread(roomTab, sysHeader.roomSize, fd))
	return FALSE;

    netTab = (struct netTable *) xmalloc(sizeof (*netTab) * cfg.netSize);
    if (cfg.netSize > 0) {
	for (i=0; i<cfg.netSize; i++) {
	    if (!ltread(&netTab[i], NT_SIZE, fd))
		return FALSE;
	    netTab[i].Tshared = (struct netroom *) xmalloc(SR_BULK);
	    if (!ltread(netTab[i].Tshared, SR_BULK, fd))
		return FALSE;
	}
    }

    evtTab = (struct evt_type *) xmalloc(sizeof (*evtTab) * cfg.evtCount);
    if (cfg.evtCount > 0)
	if (!ltread(evtTab, (sizeof(*evtTab) * cfg.evtCount), fd))
	    return FALSE;

    pollTab = (struct poll_t *)xmalloc(sizeof(*pollTab) * cfg.poll_count);
    if (cfg.poll_count > 0)
	if (!ltread(pollTab, (sizeof(*pollTab) * cfg.poll_count), fd))
	    return FALSE;

    zap = (struct zaphash *)xmalloc(sizeof(*zap) * cfg.zap_count);
    if (cfg.zap_count > 0)
	if (!ltread(zap, (sizeof(*zap) * cfg.zap_count), fd))
	    return FALSE;

    archTab = (struct archiver *)xmalloc(sizeof(*archTab) * cfg.arch_count);
    if (cfg.arch_count > 0)
	if (!ltread(archTab, (sizeof(*archTab) * cfg.arch_count), fd))
	    return FALSE;

    dclose(fd);
    if (kill)
	dunlink(indextable);
    return TRUE;
}
