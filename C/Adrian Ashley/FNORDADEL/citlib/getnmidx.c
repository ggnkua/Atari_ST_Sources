/*
 * getnmidx.c -- load a log entry for named person
 *
 * 90Aug27 AA	Split off from liblog.c
 */

#include "ctdl.h"
#include "log.h"
#include "config.h"
#include "citlib.h"

void getlog();

/* returns the logTab[] index (NOT the log slot on disk!) of the named user */
int
getnmidx(name, log, file)
char *name;
struct logBuffer *log;
int file;
{
    register namehash, i;

    namehash = hash(name);
    for (i = 0; i < cfg.logsize; i++)
	if (logTab[i].ltnmhash == namehash) {
	    getlog(log, logTab[i].ltlogSlot, file);
	    if (labelcmp(name, log->lbname) == 0)
		return i;
	}
    return ERROR;
}

/* returns the named user's log slot on disk, or ERROR */
int
getnmlog(name, log, file)
char *name;
struct logBuffer *log;
int file;
{
    register i = getnmidx(name, log, file);

    return (i == ERROR) ? i : logTab[i].ltlogSlot;
}
