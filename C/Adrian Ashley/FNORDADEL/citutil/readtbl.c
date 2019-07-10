/*
 * readtbl.c -- Read in cfg, roomTab, netTab, and logTab
 *
 * 90Jan31 AA	Modified readSysTab() to handle variable-sized structs
 * 87Jun18 orc	Created.
 */ 

#include "ctdl.h"
#include "net.h"
#include "config.h"
#include "room.h"
#include "log.h"

/*
 * readSysTab() - load cfg, logTab, netTab, roomTab
 */

struct config	cfg;			/* A buncha variables		*/
struct lTable	*logTab = NULL;
struct netTable *netTab = NULL;
struct rTable	*roomTab = NULL;

char *indextable = "ctdltabl.sys";

struct {
    unsigned cfgSize;
    unsigned logSize;
    unsigned roomSize;
    unsigned evtSize;
} sysHeader;

/****************************************************************
 *	ltread() reads in from file the important stuff		*
 *	returns:	TRUE on success, else FALSE		*
 ****************************************************************/
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

/*
 ****************************************************************
 * readSysTab()		load cfg, logTab, netTab, roomTab	*
 ****************************************************************
 */
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
/* "return FALSE;" changed to "exit(1);" by RH 90Mar20 */
	exit(1);
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
    dclose(fd);
    return TRUE;
}
